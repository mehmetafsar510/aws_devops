sym = {1000 : "M" ,900 : "CM" ,500 :"D",400:"CD", 100 : "C" , 90 : "XC" ,80: "XXC",50:"L",40:"XL",30:"XXL",10 : "X" ,9:"IX" ,8:"IIX", 5 : "V",4:"IV", 1 : "I"}
base = [1000,900,500,400,100,90,80,50,40,30,10,9,8,5,4,1]
num = int(input()) 
print("You have chosen: " + str(num))
if num >= 4000 or num <= 0:
    print("Not Valid Input !!!")
 
for i in range (len(base)):
    if num >= base[i]:
        print (num // base[i] * sym [base[i]],end = '')
        num %= base[i]
