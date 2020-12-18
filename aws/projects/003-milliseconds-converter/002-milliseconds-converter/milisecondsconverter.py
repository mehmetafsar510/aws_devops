def milisecondsconverter(number):
	hour = number // (60 * 60000)
	number %= (60 * 60000)
	minutes = number // 60000
	number %= 60000
	seconds = number // 1000
	if hour >= 1:
		if minutes >= 1 and seconds >= 1:
			return f"{hour} hour/s {minutes} minute/s {seconds} second/s"
		elif minutes >= 1 and seconds <1:
			return f"{hour} hour/s {minutes} minute/s"
		elif minutes <1 and seconds >= 1 :
			return f"{hour} hour/s {seconds} second/s"
		else:
			return f"{hour} hour/s"
	elif hour < 1 and minutes >= 1 :
		if seconds >= 1:
			return f"{minutes} minute/s {seconds} second/s"
		else:
			return f"{minutes} minute/s"
	else:
		return f"{seconds} second/s"
	
			

