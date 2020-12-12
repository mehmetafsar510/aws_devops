# Coding Challenge - 015: Morse Translator

The purpose of this coding challenge is to write a program that translates the plain text to morse code.

## Learning Outcomes

At the end of this coding challenge, students will be able to;

- Analyze a problem, identify, and apply programming knowledge for an appropriate solution.

- Implement loops to solve a problem.

- Make use of dictionary data structure to map values. 

- Demonstrate their knowledge of algorithmic design principles by solving the problem effectively.

## Problem Statement :

Write a function that takes in a plain text as input and converts it into morse alphabet. Following alphabet can be used:
{
  'A': '.-', 'B': '-...', 'C': '-.-.', 'D': '-..', 'E': '.', 'F': '..-.',
  'G': '--.', 'H': '....', 'I': '..', 'J': '.---', 'K': '-.-', 'L': '.-..',
  'M': '--', 'N': '-.', 'O': '---', 'P': '.--.', 'Q': '--.-', 'R': '.-.',
  'S': '...', 'T': '-', 'U': '..-', 'V': '...-', 'W': '.--', 'X': '-..-',
  'Y': '-.--', 'Z': '--..', ' ': ' ', '0': '-----',
  '1': '.----', '2': '..---', '3': '...--', '4': '....-', '5': '.....',
  '6': '-....', '7': '--...', '8': '---..', '9': '----.',
  '&': '.-...', "'": '.----.', '@': '.--.-.', ')': '-.--.-', '(': '-.--.',
  ':': '---...', ',': '--..--', '=': '-...-', '!': '-.-.--', '.': '.-.-.-',
  '-': '-....-', '+': '.-.-.', '"': '.-..-.', '?': '..--..', '/': '-..-.'
}

- Expected Outputs:

```text
Input: Hello world!

Output:
.... . .-.. .-.. ---   .-- --- .-. .-.. -.. -.-.--

Input: Good job!

Output: --. --- --- -..   .--- --- -... -.-.--
```

