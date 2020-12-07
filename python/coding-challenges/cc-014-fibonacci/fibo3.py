deneme = []

def fibonacci():
    fib = input("How many fibonacci number do you want to see?\n let see your number -----> ")
    fibo = []
    if fib.isdigit():
        fib = int(fib)
        fib = fib - 2
        for i in range(-2, fib) :
            if i < 0 : 
                fibo.append(1)
            else : 
                fibo.append(fibo[i] + fibo[i+1])
        print(fibo)
        print(len(fibo))
    else:
        if len(deneme) < 3:
            deneme.append(fib)
            print('hey...\nyou must be smart enough to understand that only numbers need to be entered')
            fibonacci()
        else:
            print(":'('\nprobably, i was wrong about you. bye bye \ngo to Clarusway")
    

                

fibonacci()
