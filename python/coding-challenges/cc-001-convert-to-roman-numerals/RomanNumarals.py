while(True):
	entry = input("a number for romen number: ")
	if entry == "Exit":
		break
	elif entry.isdigit():
		if int(entry) > 3999:
			print("Not Valid Input !!")
		else:
			number = int(entry)
			rest1 = number%1000
			valueM = "M" * int(number/1000)
			
			rest2 = rest1%500
			valueD = "D" * int(rest1/500) if rest2 < 400 else "CD" * abs(int(rest1/500)-1)+"CM" * int(rest1/500)
			
			rest3 = rest2 % 100
			valueC = "C" * int(rest2/100) if rest1 <400 else ""
			rest4 = rest3 % 50
			valueL = "L" * int(rest3/50) if rest4<40 else "XL" * abs(int (rest3/50)-1) +"XC" * int(rest3/50)
			rest5 = rest4 % 10
			valueX = "X" * int(rest4/10) if rest4<40 else ""
			rest6 = rest5 % 5
			valueV = "V" * int(rest5/5) if rest6 < 4 else "IV" * abs(int (rest5/5)-1) +"IX" * int(rest5/5)
			valueI = "I" * rest6 if rest6<4 else ""
			
			print(valueM.strip(" "), valueD,
			 valueC,  valueL, valueX, valueV,
			 valueI, sep="")
	else:
		print("Not Valid Input !!")
