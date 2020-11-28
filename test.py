def test(targetOrientation, currOrientation):

    # if targetOrientation == 4 and currOrientation == 1:
    #     print("{}-{} : {}".format(targetOrientation, currOrientation, "left"))
    #     return targetOrientation
    # elif targetOrientation == 1 and currOrientation == 4:
    #     print("{}-{} : {}".format(targetOrientation, currOrientation, "right"))
    #     return targetOrientation
    

    # if targetOrientation == (currOrientation + 1):
    #     print("{}-{} : {}".format(targetOrientation, currOrientation, "right"))
    #     return targetOrientation
    # elif targetOrientation == (currOrientation + 2):
    #     print("{}-{} : {}".format(targetOrientation, currOrientation, "rightx2"))
    #     return targetOrientation
    # elif targetOrientation == (currOrientation - 1):
    #     print("{}-{} : {}".format(targetOrientation, currOrientation, "left"))
    #     return targetOrientation

    xMovement = (currOrientation - 2) * (currOrientation % 2)
    zMovement = (currOrientation - 3) * ((currOrientation + 1) % 2)

    print(xMovement, zMovement)    

for i in range(1, 4):
    for k in range(1, 4):
        test(i, k)
