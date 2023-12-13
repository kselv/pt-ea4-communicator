import numpy as np

def isNxM(array):
    refN = len(array[0])
    
    for element in array:
        if refN != len(element):
            return False
        
    return True

def getChar(x, y):
    global char_array
    return char_array[y][x]
    

pipesLUT = {
    '|': ['u', 'd'],
    '-': ['r', 'l'],
    'L': ['u', 'r'],
    'J': ['u', 'l'],
    '7': ['l', 'd'],
    'F': ['d', 'r'],
    '.': [],
    'S': ['u', 'd', 'l', 'r']
}

compatibleConnection= {
    'l': 'r',
    'r': 'l',
    'd': 'u',
    'u': 'd',
}


char_array = []

with open('input.txt') as f:
    
    temp_row = []
    while True:
        char = f.read(1)
        if char == '\n':
            char_array.append(temp_row)
            temp_row = []
        elif(char == ''):
            break
        else:
            temp_row.append(char)
            
            

print("Is valid: {}".format(isNxM(char_array)))

x_len = len(char_array[0])
y_len = len(char_array)

def getCoordinateFromDirection(direction,index_x, index_y):
    # Local variables
    result_x = index_x
    result_y = index_y
    
    if direction == 'u':
        result_y = index_y-1
    elif direction == 'd':
        result_y = index_y+1
    elif direction == 'r':
        result_x = index_x+1
    elif direction == 'l':
        result_x = index_x-1
    elif direction == '':
        pass
    else:
        raise Exception("invalid char")
    
    if result_x >= x_len or result_y >= y_len or x_len < 0 or y_len < 0:
        return [-1, -1]
    
    return [result_x, result_y]


def getConnectedPipes(directionsToCheck, index_x, index_y):
    tilesAround = []
    for direction in directionsToCheck:
        # Get tile
        x_res, y_res = getCoordinateFromDirection(direction, index_x, index_y)
        
        if x_res == -1 or y_res == -1:
            continue
        # Check if it is compatible
        elif compatibleConnection[direction] in pipesLUT[getChar(x_res, y_res)]:
            situatedAt = direction
            tilesAround.append([x_res, y_res, direction])
            
    return tilesAround

def isInitialTile(tile):
    global initial_x
    global initial_y
    
    return tile[0] == initial_x and tile[1] == initial_y


def findLoopFromCharLoop(index_x, index_y, exclude_direction=None):
    to_check = [(index_x, index_y, exclude_direction)]
    count = 0

    while to_check:
        current = to_check.pop()
        index_x, index_y, exclude_direction = current
        result = False
        char = getChar(index_x, index_y)
        
        if char == "S":
            a=0
        # else:
        #     to_exclude_list.append([index_x, index_y])
        
        directions_to_check = pipesLUT[char].copy()
        try:
            directions_to_check.remove(exclude_direction)
        except ValueError:
            pass
        
        tiles_around = getConnectedPipes(directions_to_check, index_x, index_y)
        
        if len(tiles_around) == 0:
            result = False
            continue
        
        for tile in tiles_around:
            if isInitialTile(tile):
                result = True
                print((count/2)+1)
                break
            elif [tile[0], tile[1]] in to_exclude_list:
                continue
            else:
                to_check.append((tile[0], tile[1], compatibleConnection[tile[2]]))
        
        setXY(index_x, index_y, tile[2])
        count+=1
        
        if result:
            return True

    return False

def findLoopFromCharRec(index_x, index_y, exclude_direction=None):
    result = False
    char = getChar(index_x, index_y)
    
    if char == "S":
        pass
    # else:
    #     to_exclude_list.append([index_x, index_y])
    
    directionsToCheck = pipesLUT[char].copy()
    
    try:
        directionsToCheck.remove(exclude_direction)
    except Exception as e:
        pass
    
    tilesAround = getConnectedPipes(directionsToCheck, index_x, index_y)
    
    if len(tilesAround) == 0:
        return False
    
    # For each tile around
    for tile in tilesAround:
        if isInitialTile(tile):
            return True
        elif [tile[0], tile[1]] in to_exclude_list:
            continue
        else:
            # Find loop from char
            findLoopFromCharRec(tile[0], tile[1], exclude_direction=compatibleConnection[tile[2]])
    
    
    return result


def setXY(index_x, index_y, s):
    pass

def findLoopFromChar(char, index_x, index_y):
    result = False
    
    directionsToCheck = pipesLUT[char]
    
    # Check pipes around. Are they connected?
    tilesAround = getConnectedPipes(directionsToCheck, index_x, index_y)
    
    # For each tile around
    for tile in tilesAround:
        # Find loop from char
        # result = findLoopFromCharRec(tile[0], tile[1], exclude_direction=compatibleConnection[tile[2]])
        result = findLoopFromCharLoop(tile[0], tile[1], exclude_direction=compatibleConnection[tile[2]])
        if result == True:
            break
    
    return result

# TODO
to_exclude_list = []

initial_x = 111
initial_y = 41

result = findLoopFromChar(getChar(111, 41), 111, 41)

# for index_x, x_row in enumerate(char_array):
#     for index_y, char in enumerate(x_row):
        
#         initial_x = index_x
#         initial_y = index_y
        
#         if [initial_x, initial_y] not in to_exclude_list:
#             # Add to the excluded list
#             # to_exclude_list.append([index_x, index_y])
#             # Read the character and try to find a loop
#             result = findLoopFromChar(char, initial_x, initial_y)
        
        
#         if result == True:
#             break
        
#     if result == True:
#         break

with open('output.txt', 'w') as file:
    for sublist in char_array:
        file.write(''.join(sublist) + '\n')
        
print("Loop found: {}".format(result))
          
        
