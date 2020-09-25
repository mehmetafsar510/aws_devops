#!/bin/bash

read -p "Please enter your name: " name

read -p "please enter your age: " age

read -p "Please ente your life avarage expectancy: " ale


if (( age<18 ))
then
	
	echo " $name is a Student. " 
	echo " At least $((18 -age)) years to become a worker."
elif (((( age >= 18 )) && (( age < 65))))
then
	
	echo " $name is a worker. at least $((65-age)) years to retire. "
elif (( age >= 65))
then

	if (( age < ale))
	then
		
		echo " $name have to retired mannn!! $((ale - age)) years to die. "
	else
	
		echo -ne '\007'
		echo "!!!! Already DİED !!!!"
		sleep 3
		echo -ne '\007'
		echo "!!!! Already DİED !!!!"
		sleep 3
		echo "!!!! Already DİED !!!!"
		echo -ne '\007'
	fi
fi
