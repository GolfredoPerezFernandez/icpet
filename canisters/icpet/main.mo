import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Iter "mo:base/Iter";
import Nat32 "mo:base/Nat32";

import Text "mo:base/Text";
import Principal "mo:base/Principal";
import Debug "mo:base/Debug";

actor ICPET {

	type PetId = Nat32;
	type Pet = {
		creator: Text;
		ascii: Text;
		name: Text;
		health: Nat;
		energy: Nat;
		happiness: Nat;
		cleaning: Nat;
		status: Text;		
		delay: Nat;	
		color: Text;
	};

	stable var petId: PetId = 0;
	let petList = HashMap.HashMap<Text, Pet>(0, Text.equal, Text.hash);

	private func generatePetId() : Nat32 {
		petId += 1;
		return petId;
	};
    private func max(a: Nat, b: Nat) : Nat {
    if (a > b) {
        return a;
    } else {
        return b;
    };
};

    private func min(a: Nat, b: Nat) : Nat {
     if (a < b) {
        return a;
    } else {
        return b;
    };
};
	public query ({caller}) func whoami() : async Principal {
		return caller;
	};
    public shared (msg) func createPet(name: Text) : async () {
        let user: Text = Principal.toText(msg.caller);

        let pet : Pet = {
            creator=user; 
            name=name; 
            ascii="asdasd"; 
            health=80; 
            energy=80; 
            happiness=80; 
            cleaning=80; 
            status="idle"; 
            color="80"
        };

        petList.put(Nat32.toText(generatePetId()), pet);
        Debug.print("New pet created! ID: " # Nat32.toText(petId));
				return ();

    };

	public query func getPets () : async [(Text, Pet)] {
		let petIter : Iter.Iter<(Text, Pet)> = petList.entries();
		let petArray : [(Text, Pet)] = Iter.toArray(petIter);

		return petArray;
	};

	public query func getPet (id: Text) : async ?Pet {
		let pet: ?Pet = petList.get(id);
		return pet;
	};



	public func deletePost (id: Text) : async Bool {
		let post : ?Pet = petList.get(id);
		switch (post) {
			case (null) {
				return false;
			};
			case (_) {
				ignore petList.remove(id);
				Debug.print("Delete post with ID: " # id);
				return true;
			};
		};
	};
public shared (msg) func playWithPet(id: Text) : async Bool {
    let pet: ?Pet = petList.get(id);
    switch (pet) {
        case (null) {
            Debug.print("Mascota no encontrada. 😞");
            return false;
        };
        case (?currentPet) {
            if (currentPet.energy < 20) {
                Debug.print("La mascota está demasiado cansada para jugar. 😴");
                return false;
            } else {
                let updatedPet: Pet = {
                    creator = currentPet.creator;
                    ascii = currentPet.ascii;
                    name = currentPet.name;
                    health = currentPet.health - 5; // Jugar puede disminuir un poco la salud
                    energy = max(0, currentPet.energy - 30);
                    happiness = min(100, currentPet.happiness + 25);
                    cleaning = currentPet.cleaning;
                    status = "¡Jugando! 😃";
                    delay = currentPet.delay;
                    color = currentPet.color;
                };
                petList.put(id, updatedPet);
                Debug.print("Jugando con la mascota. 🎾");
                return true;
            }
        };
    };
};

public shared (msg) func feedPet(id: Text) : async Bool {
    let pet: ?Pet = petList.get(id);
    switch (pet) {
        case (null) {
            Debug.print("Mascota no encontrada. 😞");
            return false;
        };
        case (?currentPet) {
            let updatedPet: Pet = {
                creator = currentPet.creator;
                ascii = currentPet.ascii;
                name = currentPet.name;
                health = min(100, currentPet.health + 20);
                energy = min(100, currentPet.energy + 10);
                happiness = currentPet.happiness;
                cleaning = currentPet.cleaning - 5; // La limpieza puede disminuir al comer
                status = "¡Comido! 😋";
                delay = currentPet.delay;
                color = currentPet.color;
            };
            petList.put(id, updatedPet);
            Debug.print("Mascota alimentada con éxito. 🍽️");
            return true;
        };
    };
};

	public shared (msg) func sleepPet(id: Text) : async Bool {
    let pet: ?Pet = petList.get(id);
    switch (pet) {
        case (null) {
            Debug.print("Mascota no encontrada. 😞");
            return false;
        };
        case (?currentPet) {
            let updatedPet: Pet = {
                creator = currentPet.creator;
                ascii = currentPet.ascii;
                name = currentPet.name;
                health = currentPet.health + 5; // Dormir puede mejorar un poco la salud
                energy = min(100, currentPet.energy + 40);
                happiness = currentPet.happiness - 10; // Podría disminuir si no le gusta dormir mucho
                cleaning = currentPet.cleaning;
                status = "Dormido. 💤";
                delay = currentPet.delay;
                color = currentPet.color;
            };
            petList.put(id, updatedPet);
            Debug.print("La mascota está durmiendo. 🛌");
            return true;
        };
    };
};

public shared (msg) func cleanPet(id: Text) : async Bool {
    let pet: ?Pet = petList.get(id);
    switch (pet) {
        case (null) {
            Debug.print("Mascota no encontrada. 😞");
            return false;
        };
        case (?currentPet) {
            let updatedPet: Pet = {
                creator = currentPet.creator;
                ascii = currentPet.ascii;
                name = currentPet.name;
                health = min(100, currentPet.health + 10); // La limpieza mejora la salud
                energy = currentPet.energy;
                happiness = min(100, currentPet.happiness + 15); // La limpieza mejora la felicidad
                cleaning = 100; // La limpieza se maximiza
                status = "¡Limpio! 🚿";
                delay = currentPet.delay;
                color = currentPet.color;
            };
            petList.put(id, updatedPet);
            Debug.print("Mascota limpiada con éxito. ✨");
            return true;
        };
    };
};
public query func getPetStatus(id: Text) : async ?Pet {
    let pet: ?Pet = petList.get(id);
    switch (pet) {
        case (null) {
            Debug.print("Mascota no encontrada. 😞");
            return null;
        };
        case (?currentPet) {
            Debug.print("Estado actual de la mascota: " # currentPet.status);
            return currentPet;
        };
    };
};
}