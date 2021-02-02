#!/bin/bash

clear
echo "hello world"
read -p "Plese enter your name : " name
echo "$name" >> names.txt
clear
echo -e "hello $name\nyour name as been added to list"
echo"===================="
cat names.txt

echo"====================="
echo "good bye"
sleep 2
