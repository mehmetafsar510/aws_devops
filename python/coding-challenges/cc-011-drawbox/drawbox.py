def drawbox(length): 
        print ("#"*length)

        for i in range(length-2):
            print ("#" + " " * (length - 2) + "#")
            
        print ("#"*length)

length = int(input("Please enter the side length of the box: "))
drawbox(length)