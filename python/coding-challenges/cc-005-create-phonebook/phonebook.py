

people = {}                               
                              
def phonebook():
    while True:                                
                                
        print("<================>")
        print("Welcome to the phonebook application")
        print("1: Insert a phone number")
        print("2: Delete a person from the phonebook")                  
        print("3: Find phone number")
        print("4: Terminate")
        print("<================>")
        print("\n")                                 

        entry = input("Select operation on Phonebook App (1/2/3): ")                   

        if entry == "1":                                                        
            print("\n" * 50)                      
            name = input("Insert name of the person : ")                                       
            phoneNumber = input("Insert phone number of the person: ")

            if name and phoneNumber.isdigit():
                people[name] = phoneNumber
                print(people)           
            else:
                 print("Invalid input format, cancelling operation ...")           
                 continue
                               
        elif entry == "2":
             print("\n" * 50)
             name = input("Whom to delete from phonebook : ")
             if name:
                value = people.pop(name, "")
                if value:
                    print(f"{name} is deleted from the phonebook")
            
             else:
                 print(f"{name} is not in the phonebook")

        elif entry == "3":                            
            print("\n" * 50)
            name = input("Find the phone number of : ")
            if name :
                value = people.get(name, f"Couldn't find phone number of {name}")
                print(value)                         

            input("Press enter/return to continue") 

        elif entry == "4":
            print("Exiting Phonebook")
            break   
phonebook()                                                