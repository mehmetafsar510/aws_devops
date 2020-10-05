from sys import exit

phonebook = {}

def find():
    name = input('Find the phone number of : ')
    if name in phonebook.keys():
        print(phonebook[name])
    else:
        print(f"Couldn't find phone number of {name}")

def insert():
    name = input('Insert name of the person : ')
    number = input('Insert phone number of the person: ')
    if number.isdigit():
        print(f"Phone number of {name} is inserted into the phonebook")
        phonebook[name] = number

    else:
        print(f"Invalid input format, cancelling operation ...")

def delete():
    name = input('Whom to delete from phonebook :')
    if name in phonebook.keys():
        del phonebook[name]  
        print(f"{name} is deleted from the phonebook")
    else:
        print(f"Couldn't find phone number of {name}")

text = """
Welcome to the phonebook application
1. Find phone number
2. Insert a phone number
3. Delete a person from the phonebook
4. Terminate
"""

print(text)
options = {'1': find, '2': insert, '3': delete, '4': exit}
while True:
    option = input("Select operation on Phonebook App (1/2/3) :")
    if option in options.keys():
        options[option]()