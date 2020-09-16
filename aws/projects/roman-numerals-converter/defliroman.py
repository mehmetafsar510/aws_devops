def int_to_rome(number): 
           
        n = int(number)
        b = (1000, 900,  500, 400, 100,  90, 50,  40, 10,  9,   5,  4,   1)
        c = ('M',  'CM', 'D', 'CD','C', 'XC','L','XL','X','IX','V','IV','I')
        d= []
        for i in range(len(b)):
            count = int((n/b[i]))
            d.append(count*c[i])
            n -= count * b[i]
        return "".join(d)
    
