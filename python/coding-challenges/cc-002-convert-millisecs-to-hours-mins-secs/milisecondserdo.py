converted_list = [(1000*60*60, "hour/s"), (1000*60, "minute/s"), (1000, "second/s"), (1, "milisecond/s")]
result = ""
while True:
    milisecond = input("Please enter a milisecond value: ")

    if milisecond == "exit":
        print("Exiting the program... Good Bye")
        break

    if not milisecond.isdigit() or int(milisecond) == 0:
        print("Print a valid milisecond value, please")
        continue
    else:
        milisecond = int(milisecond)
        for i, text in converted_list:
            division = milisecond // i
            if not division == 0:
                result += str(division) + " " + text + " "
                milisecond = milisecond - division * i
    break

print(result)