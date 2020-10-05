# Coding Challenge - 005 : Create Phonebook Application

Purpose of the this coding challenge is to write a program that creates a phonebook and performs certain operations on the phonebook.

## Learning Outcomes

At the end of the this coding challenge, students will be able to;

- analyze a problem, identify and apply programming knowledge for appropriate solution.

- design, implement `for` and `while` loops effectively in Python to solve the given problem.

- control loops effectively by using `if` and `control` statements.

- demonstrate their knowledge of algorithmic design principles by using function effectively.

- apply exception handling to handle errors effectively.

## Problem Statement

- Write a program that creates a phonebook, adds requested contacts to the phonebook, finds them, and removes them.

- There should be 4 options available to the user and from the options, users should be able to add, find, delete contacts, or terminate the program as shown below.

- Phonebook has users and their corresponding phone numbers.

- At the beginning of the program the phonebook will be empty and user can choose to add new contacts to the phonebook.

- Program should ask user for the input, after giving information text shown as below.

```text
Welcome to the phonebook application
1. Find phone number
2. Insert a phone number
3. Delete a person from the phonebook
4. Terminate
Select operation on Phonebook App (1/2/3) :
```

- Application should be case sensitive and run until the user types `4`.

- Example for user inputs and respective outputs

```text
Welcome to the phonebook application
1. Find phone number
2. Insert a phone number
3. Delete a person from the phonebook
4. Terminate
Select operation on Phonebook App (1/2/3) : 2
Insert name of the person : John
Insert phone number of the person: ten
Invalid input format, cancelling operation ...

1. Find phone number
2. Insert a phone number
3. Delete a person from the phonebook
4. Terminate
Select operation on Phonebook App (1/2/3) : 2
Insert name of the person : Alex
Insert phone number of the person: 1234
Phone number of Alex is inserted into the phonebook

1. Find phone number
2. Insert a phone number
3. Delete a person from the phonebook
4. Terminate
Select operation on Phonebook App (1/2/3) : 1
Find the phone number of : Alex
1234

1. Find phone number
2. Insert a phone number
3. Delete a person from the phonebook
4. Terminate
Select operation on Phonebook App (1/2/3) : 3
Whom to delete from phonebook : Alex
Alex is deleted from the phonebook

1. Find phone number
2. Insert a phone number
3. Delete a person from the phonebook
4. Terminate
Select operation on Phonebook App (1/2/3) : 1
Find the phone number of : Alex
Couldn't find phone number of Alex

1. Find phone number
2. Insert a phone number
3. Delete a person from the phonebook
4. Terminate
Select operation on Phonebook App (1/2/3) : 4
Exiting Phonebook
```

## Solution

```python
phonebook = {}

def find(keyword):
    return phonebook.get(keyword, f"Couldn't find phone number of {keyword}")

def add(name, phone_number):
    phonebook[name] = phone_number
    return f'Phone number of {name} is inserted into the phonebook'

def delete(name):
    try:
        phonebook.pop(name)
    except KeyError as err:
        return f'{err} is not in the phonebook'
    else:
        return f'{name} is deleted from the phonebook'

if __name__ == '__main__':
    print('Welcome to the phonebook application')
    print('1. Find phone number')
    print('2. Insert a phone number')
    print('3. Delete a person from the phonebook')
    print('4. Terminate')
    no = input('Select operation on Phonebook App (1/2/3) : ')
    while True:
        if no == '1':
            name = input('Find the phone number of : ')
            print(find(name))
            print(" ")
        elif no == '2':
            name = input('Insert name of the person : ')
            try:
                number = int(input('Insert phone number of the person: '))
            except ValueError as err:
                print('Invalid input format, cancelling operation ...')
            else:
                print(add(name, number))
            print(" ")
        elif no == '3':
            name = input('Whom to delete from phonebook : ')
            print(delete(name))
            print(" ")
        elif no == '4':
            print('Exiting Phonebook')
            break
        else:
            print('Wrong operation')

        print('1. Find phone number')
        print('2. Insert a phone number')
        print('3. Delete a person from the phonebook')
        print('4. Terminate')
        no = input('Select operation on Phonebook App (1/2/3) : ')
```
