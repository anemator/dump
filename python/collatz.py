#!/usr/bin/env python3
# Prints the path to the unit element

def exit():
    print("Error: not a valid number")
    sys.exit(1)

try:
    n = int(raw_input("Number? "))
except ValueError:
    exit()

if n < 1:
    exit()

steps=[]
while n != 1:
    if n % 2 == 0:
        n = n / 2
    else:
        n = 3*n+1
    steps.append(n)

print("Steps: " + str(len(steps)-1))
print("# Steps: " + str(steps))
