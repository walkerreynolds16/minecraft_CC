import math


def print_factors(x):
   print("The factors of",x,"are:")
   for i in range(1, x + 1):
       if x % i == 0:
           print(i)

def getFactors(n):
    factors = []
    for i in range(1, n + 1):
       if n % i == 0:
           factors.append(i)
    
    solutions = []
    for i in range(len(factors)):
        for k in range(len(factors)):
            if factors[i] * factors[k] == n:
                solutions.append((factors[i], factors[k]))

    return solutions

deltas = [20,10,20]
startVector = [0,0,0]

numOfTurtles = 9

turtleDeltaX = math.floor(deltas[0] / numOfTurtles) # check for non divisible values
turtleDeltaZ = math.floor(deltas[2] / numOfTurtles)
turtlesPerSide = numOfTurtles / 2

# Height will for each turtle will be deltaY
# so it ends up diving into chunks similar to MC
for i in range(numOfTurtles):
    turtleStart = []


# solutions = getFactors(20)

# bestSolution = solutions[0]
# for solution in solutions:
#     value = abs(solution[0] - solution[1])
#     bestSolutionValue = abs(bestSolution[0] - bestSolution[1])

#     if value < bestSolutionValue:
#         bestSolution = solution

# longerSide = 0
# if deltas[2] > deltas[0]:
#     longerSide = 2

# longSideLines = max(bestSolution[0], bestSolution[1]) - 1
# shortSideLines = min(bestSolution[0], bestSolution[1]) - 1
# print(longSideLines, shortSideLines)


# for i in range(shortSideLines):
#     for k in range(longSideLines):
        

# print(getFactors(20))
# print(getFactors(30))
bestNumOfTurtles = 1
bestScore = 0
for i in range(1,65):
    sqrt = math.sqrt(i)
    xSections = math.floor(deltas[0] / sqrt)
    zSections = math.floor(deltas[2] / sqrt)

    ogArea = (deltas[0] * deltas[2]) 
    sectionedArea = (xSections * zSections * i)
    areaDiff = ogArea - sectionedArea

    print("NumOfTurtles = {}, OGArea = {}, sectionedArea = {}, areaDiff = {}".format(i, ogArea, sectionedArea, areaDiff))

    score = (i * 5) - areaDiff

    if score > bestScore:
        bestNumOfTurtles = i
        bestScore = score

print("Best NumOfTurtles = {}, Best Score = {}".format(bestNumOfTurtles, bestScore))
sqrt = math.sqrt(bestNumOfTurtles)
print(math.floor(deltas[0] / sqrt))
print(math.floor(deltas[2] / sqrt))





