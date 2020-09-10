while(True):
	print("This program converts milliseconds into hours, minutes, and seconds(To exit the program, please type 'Exit')")
	entry = input("Please enter the milliseconds (should be greater than zero): ")
	if entry == "Exit":
		print("Exiting the program... Good Bye")
		break
	elif entry.isdigit():
		if int(entry) == 0:
			print("Not Valid Input !!")
		elif 0 < int(entry) <1000:
			print("just {} millisecond/s".format(entry))
		else:
			number = int(entry)
			hour = number // (60 * 60000)
			number %= (60 * 60000)
			minutes = number // 60000
			number %= 60000
			seconds = number // 1000
			if hour >= 1:
				if minutes >= 1 and seconds >= 1:
					print(f"{hour} hour/s {minutes} minute/s {seconds} second/s")
				elif minutes >= 1 and seconds <1:
					print(f"{hour} hour/s {minutes} minute/s")
				elif minutes <1 and seconds >= 1 :
					print(f"{hour} hour/s {seconds} second/s")
				else:
					print(f"{hour} hour/s")
			elif hour < 1 and minutes >= 1 :
				if seconds >= 1:
					print(f"{minutes} minute/s {seconds} second/s")
				else:
					print(f"{minutes} minute/s")
			else:
				print(f"{seconds} second/s")
			
	else:
		print("Not Valid Input !!")
