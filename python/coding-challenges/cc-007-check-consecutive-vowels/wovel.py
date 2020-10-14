def ardisik():
    d = input('Enter your name:')
    d = d.lower()
    vowels = ('a', 'e', 'i', 'i', 'o', 'ö', 'u', 'ü')
    e = []
    for i in d:
        e.append(i)
    c = 0
    for i in range(len(e)-1):
        if e[i] in vowels:
            if e[i+1] in vowels:
                c += 1
        elif e[c] not in vowels:
            continue
    if c <= 0 :
        print('Negative')
    else:
        print('Positive')
ardisik()
        