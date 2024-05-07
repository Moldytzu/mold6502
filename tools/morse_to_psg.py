code = "... .- .-.. ..- -"

psg = []

psg.append(0b11110001)
psg.append(0b00000000)

for c in code:
    if c == '.':
        psg.append(0b00001001)
        psg.append(0)
        psg.append(0)
        psg.append(0b11111001)
    elif c == '-':
        psg.append(0b00001001)
        psg.append(0)
        psg.append(0)
        psg.append(0)
        psg.append(0)
        psg.append(0)
        psg.append(0)
        psg.append(0)
        psg.append(0)
        psg.append(0b11111001)
    else:
        psg.append(0b11111001)
        psg.append(0)
        psg.append(0)
        psg.append(0)
        psg.append(0)
        psg.append(0)
        psg.append(0)
        psg.append(0)
        psg.append(0)
        psg.append(0)
        psg.append(0)
        psg.append(0)
        psg.append(0)
        psg.append(0)
        psg.append(0)
        psg.append(0)
        psg.append(0)
        psg.append(0b11111001)
    psg.append(0)
   
psg.append(0)   
psg.append(0b11111001)    
       
while len(psg) < 256:
    psg.append(0)
        
for i in psg:
    print(f"${i:x}, ", end='')