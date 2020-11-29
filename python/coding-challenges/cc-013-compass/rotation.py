def rotation(a, b):
    directions = ["N", "W", "E", "S"]
    rotations = ["L", "R"]

    if a not in directions:
        print("please enter valid directions")

    for i in b:
        if i not in rotations:
            print("please enter valid directions")

    
    for i in b:
        if a == "N":
            if i == "L":
                a = "W"
            else:
                a = "E"
        elif a == "W":
            if i == "L":
                a = "S"
            else:
                a = "N"
        elif a == "S":
            if i == "L":
                a = "E"
            else:
                a = "W"
        elif a == "E":
            if i == "L":
                a = "N"
            else:
                a = "S"
    
    print(a)

rotation("N", ["R", "L"])
rotation("N", ["L", "L", "L"])
rotation("N", ["R", "R", "R", "L"])
rotation("N", ["R", "R", "R", "R"])
        

