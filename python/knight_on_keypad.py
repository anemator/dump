#!/usr/bin/env python

# https://codereview.stackexchange.com/questions/107470/find-total-number-of-phone-numbers-formed-by-the-movement-of-knight-and-bishop-o
# https://stackoverflow.com/questions/2893470/generate-10-digit-number-using-a-phone-keypad
# https://stackoverflow.com/questions/40758607/minimum-number-of-knight-moves-to-move-from-source-to-destination-in-a-matrix
# https://programmingpraxis.com/2012/01/20/knights-on-a-keypad/<Paste>

# 1 2 3
# 4 5 6
# 7 8 9
#   0
moves = {
    1: [6, 8],
    2: [7, 9],
    3: [4, 8],
    4: [0, 3, 9],
    5: [],
    6: [0, 1, 7],
    7: [2, 6],
    8: [1, 3],
    9: [2, 4],
    0: [4, 6],
}

# 1 -> 6
# 1 -> 8

# 1 -> 6 -> 0
# 1 -> 6 -> 1
# 1 -> 6 -> 7
# 1 -> 8 -> 1
# 1 -> 8 -> 3

def count(length, pos=1, acc={}):
    if length == 0:
        return 1
    elif (pos, length) in acc:
        return acc[(pos, length)]
    else:
        acc[(pos, length)] = sum(count(pos=i, length=length-1) for i in moves[pos])
        return acc[(pos, length)]

def count_table(length, pos=1):
    d = { (k,1): len(v) for (k,v) in moves.items() }
    for i in range(2,length):
        for j in range(10):
            d[(i, j)] = d[i-1, j] + len(moves[j])
    return d[(length, pos)]


# from collections import defaultdict
# def count_knight_paths(maxlevel):
#     jump = {0: [6, 4], 1: [6, 8], 2: [9, 7],
#             3: [4, 8], 4: [9, 3, 0], 6: [7, 1, 0],
#             7: [6, 2], 8: [3, 1], 9: [4, 2]}
#     c = { 1 : 1 }
#     for level in range(maxlevel):
#         cprim = defaultdict(int)
#         for key in c:
#             for jumped in jump[key]:
#                 cprim[jumped] += c[key]
#         c = cprim
#     return sum(c.values())
 
# moves1 = [[4, 6], [8, 6], [7, 9], 
#           [4, 8], [3, 0, 9], [], 
#           [1, 7, 0], [2, 6], [1, 3], 
#           [2, 4]]
# def solve(n, pos):
#     table = [[0 for p in range(10)] for l in range(n + 1)]
#     for p in range(10):
#         table[1][p] = 1
#     for l in range(2, n + 1):
#         for p in range(10):
#             table[l][p] = 0
#             for np in moves1[p]:
#                 table[l][p] += table[l - 1][np]
#     return table[n][pos]

def main():
    print(count(length=129))
    # print(count_knight_paths(10))
 
if __name__ == '__main__':
    main()
