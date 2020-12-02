local ITEM_SLOTS = 16

local NEGATIVE_X_ORIENTATION = 1
local NEGATIVE_Z_ORIENTATION = 2
local POSITIVE_X_ORIENTATION = 3
local POSITIVE_Z_ORIENTATION = 4

local SERVER_CHANNEL = 1
local TURTLE_CHANNEL = 2
local TURTLE_CREATOR_CHANNEL = 3
local PHONE_CHANNEL = 4

local currOrientation = nil

local fuelSources = {
    coal = 80
}


 
local KEEP_ITEMS = {
    "minecraft:diamond",
    "minecraft:emerald",
    "minecraft:coal",
    "minecraft:iron_ore",
    "minecraft:gold_ore",
    "thermalfoundation:ore",
    "ic2:resource",
    "enderstorage:ender_storage",
    "computercraft:turtle_expanded"
}


function ternary(cond, T, F)
    if cond then
        return T
    else
        return F
    end
end

function split (inputstr, sep)
    if sep == nil then
            sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
end

function findItemInInventory(itemName)
    for i = 1, ITEM_SLOTS, 1 do
        local itemData = turtle.getItemDetail(i)

        if itemData and (itemData.name == itemName) then
            return i, itemData
        end
    end

    return nil, nil
end

function refuelTurtle(necessaryFuel)
    local coalIndex, coalData = findItemInInventory("minecraft:coal")

    if coalData == nil or coalIndex == nil then
        print("Could not find coal")
        return false
    end

    print("Found ", coalData.count, " coal")
    print("Refueling coal from slot ", coalIndex)

    if necessaryFuel and necessaryFuel > coalData.count then
        print("Dont have enough fuel to do operation, reeee")
        return false
    end

    turtle.select(coalIndex)
    if necessaryFuel then
        refuelingResult = turtle.refuel(necessaryFuel)
    else
        refuelingResult = turtle.refuel()
    end

    if refuelingResult == false then
        print("Refueling failed")
    end
    if refuelingResult == true then
        print("Refueling succeeded")
    end

    return refuelingResult
end

function checkFuel(blocks)
    local currFuel = turtle.getFuelLevel()
    -- TODO check which fuel is in the inventory
    -- for now, assume coal

    if currFuel > blocks then
        return true
    else
        return false
    end
end

function goToCalculateBlocks(xStart, yStart, zStart, xEnd, yEnd, zEnd) 
    local curX, curY, curZ = gps.locate(2)

    local xDelta = xEnd - xStart
    local yDelta = yEnd - yStart
    local zDelta = zEnd - zStart

    return math.abs(xDelta) + math.abs(yDelta) + math.abs(zDelta)
end

function areaFillMineCalculateBlocks(deltas) 
    return math.abs(deltas.x * deltas.y * deltas.z)
end

function stripMineCalculateBlocks(tunnelLength, tunnelHeight) 
    return math.abs(tunnelHeight * tunnelLength)
end

function getNecessaryFuel(blockToTravel, fuelSource)
    local blocksPerFuelItem = fuelSources[fuelSource]

    if blocksPerFuelItem then
        neededFuelItems = math.floor((blockToTravel / blocksPerFuelItem) + 1)
        print("required ", fuelSource, " = ", neededFuelItems)
        return neededFuelItems
    else
        print("Fuel source ", fuelSource, " doesn't exist")
    end
end

function shouldDropItem(itemName) 
    for keepIter=1, #KEEP_ITEMS, 1 do
        if KEEP_ITEMS[keepIter] == itemName then
            return false
        end
    end

    return true
end

function filterItems()
    -- For now, only able to filter items
    for slotIter = 1, ITEM_SLOTS, 1 do
        local itemInSlot = turtle.getItemDetail(slotIter)
        
        if itemInSlot then
            if shouldDropItem(itemInSlot.name) then
                turtle.select(slotIter)
                turtle.drop()
            end
        end
        
    end
end

function digAndMoveForward(blocks)
    if blocks == nil then blocks = 1 end
    for i = 1, blocks, 1 do
        while turtle.detect() do
            turtle.dig()
        end
        turtle.forward()
    end
end

function digAndMoveUp(blocks)
    if blocks == nil then blocks = 1 end
    for i = 1, blocks, 1 do
        while turtle.detectUp() do
            turtle.digUp()
        end

        turtle.up()
    end
end

function digAndMoveDown(blocks)
    if blocks == nil then blocks = 1 end
    for i = 1, blocks, 1 do
        while turtle.detectDown() do
            turtle.digDown()
        end

        turtle.down()
    end
end

function getOrientation()
    print("getting orientation...")
    loc1 = vector.new(gps.locate(2, false))
    digAndMoveForward(1)
    loc2 = vector.new(gps.locate(2, false))
    turtle.back()
    heading = loc2 - loc1
    return ((heading.x + math.abs(heading.x) * 2) + (heading.z + math.abs(heading.z) * 3))
end

function turnToOrientation(targetOrientation)
    local diff = targetOrientation - currOrientation

    if diff == -1 or diff == 3 then
        turtle.turnLeft()
    elseif diff == 1 or diff == -3 then
        turtle.turnRight()
    elseif diff ~= 0 then
        turtle.turnRight()
        turtle.turnRight()
    end

    currOrientation = targetOrientation -- set global var
    return targetOrientation

end

function goTo(x, y, z)
    local curX, curY, curZ = gps.locate(2)

    -- Step 1 : get difference in each axis
    local xDelta = x - curX
    local yDelta = y - curY
    local zDelta = z - curZ
    print("goTo: deltas = ", xDelta, yDelta, zDelta)

    -- Step 2 : move in Y direction
    if yDelta > 0 then
        digAndMoveUp(math.abs(yDelta))
    end
    if yDelta < 0 then
        digAndMoveDown(math.abs(yDelta))
    end

    if math.abs(zDelta) > math.abs(xDelta) then
        -- print("Moving in Z axis")
        if zDelta ~= 0 then
            local zOrientation = ternary(zDelta > 0, POSITIVE_Z_ORIENTATION, NEGATIVE_Z_ORIENTATION)
            turnToOrientation(zOrientation)
            digAndMoveForward(math.abs(zDelta))
        end

        -- print("Moving in X axis")
        if xDelta ~= 0 then
            local xOrientation = ternary(xDelta > 0, POSITIVE_X_ORIENTATION, NEGATIVE_X_ORIENTATION)
            turnToOrientation(xOrientation)
            digAndMoveForward(math.abs(xDelta))
        end
    else 
        -- Step 3 : calculate and execute X values
        -- print("Moving in X axis")
        if xDelta ~= 0 then
            local xOrientation = ternary(xDelta > 0, POSITIVE_X_ORIENTATION, NEGATIVE_X_ORIENTATION)
            turnToOrientation(xOrientation)
            digAndMoveForward(math.abs(xDelta))
        end

        -- Step 4 : calculate and execute Z values
        -- print("Moving in Z axis")
        if zDelta ~= 0 then
            local zOrientation = ternary(zDelta > 0, POSITIVE_Z_ORIENTATION, NEGATIVE_Z_ORIENTATION)
            turnToOrientation(zOrientation)
            digAndMoveForward(math.abs(zDelta))
        end
    end


    
end

function turnAndMoveOver(yIter, zIter, zDelta)
    if zDelta % 2 == 1 then
        -- if zDelta is odd, first turn will always be right, regardless of yIter
        if zIter % 2 == 1 then
            -- If on a odd z iteration
            turnAndMoveRight()
        else
            -- If on a even z iteration
            turnAndMoveLeft()
        end
    else
        -- If zDelta is even, then first turn depends on yIter
        if yIter % 2 == 1 then
            if zIter % 2 == 1 then
                -- If on a odd z iteration
                turnAndMoveRight()
            else
                -- If on a even z iteration
                turnAndMoveLeft()
            end
        else
            if zIter % 2 == 1 then
                -- If on a odd z iteration
                turnAndMoveLeft()
            else
                -- If on a even z iteration
                turnAndMoveRight()
            end
        end
    end

end

function turnAndMoveRight()
    currOrientation = orientationToTheRight(currOrientation)
    turtle.turnRight()
    digAndMoveForward(1)
    currOrientation = orientationToTheRight(currOrientation)
    turtle.turnRight()
end

function turnAndMoveLeft()
    currOrientation = orientationToTheLeft(currOrientation)
    turtle.turnLeft()
    digAndMoveForward(1)
    currOrientation = orientationToTheLeft(currOrientation)
    turtle.turnLeft()
end

function orientationToTheRight(orientation) 
    if orientation == 4 then return 1
    else return (orientation + 1) end
end

function orientationToTheLeft(orientation) 
    if orientation == 1 then return 4
    else return (orientation - 1) end
end

function digAreaFill(start, delta)
    local curX, curY, curZ = gps.locate(2)

    local toStartFuel = goToCalculateBlocks(curX, curY, curZ, start.x, start.y, start.z)
    local digAreaFuel = areaFillMineCalculateBlocks(delta)
    local toEndFuel = toStartFuel + (math.abs(delta.x) + math.abs(delta.y) + math.abs(delta.z))
    local totalBlocks = toStartFuel + digAreaFuel + toEndFuel

    local necessaryFuel = getNecessaryFuel(totalBlocks - turtle.getFuelLevel(), "coal")
    print("Blocks to move = ", totalBlocks)
    -- print("NecessaryFuel items = ", necessaryFuel)
    if necessaryFuel ~= 0 and not refuelTurtle(necessaryFuel) then
        -- If it doesn't have enough fuel to do dig line
        print("rip, doesn't have enough fuel to do dig area")
        sleep(5)
        os.shutdown()
    end
    

    -- TODO always go to most positive X and Z corner and turn toward positive X
    print("going to dig location")
    goTo(start.x, start.y, start.z)

    areaFillMining(delta)

    -- Finally, go back to where it started
    print("going to start location")
    goTo(curX, curY, curZ)
end

function areaFillMining(delta)
    for yIter = 1, math.abs(delta.y), 1 do

        if math.abs(delta.z) % 2 == 1 then
            if yIter % 2 == 1 then
                turnToOrientation(POSITIVE_X_ORIENTATION)
            else
                turnToOrientation(NEGATIVE_X_ORIENTATION)
            end
        else
            turnToOrientation(POSITIVE_X_ORIENTATION)
        end
        

        if yIter == 1 then
            digAndMoveForward(1) 
        end

        for zIter = 1, math.abs(delta.z)-1, 1 do

            digAndMoveForward(math.abs(delta.x)-1)

            -- if zIter ~= math.abs(delta.z) then
            --     turnAndMoveOver(yIter, zIter)
            -- end
            turnAndMoveOver(yIter, zIter, delta.z)

            filterItems()

        end

        digAndMoveForward(math.abs(delta.x)-1)

        -- digAndMoveForward(math.abs(delta.x)-1)

        if delta.y > 1 then
            digAndMoveUp(1)
        elseif delta.y < 0 then
            digAndMoveDown(1)
        else
            break
        end
    end

end

function digStripMine(start, tunnelLength, tunnelHeight) 
    local curX, curY, curZ = gps.locate(2)

    local toStartFuel = goToCalculateBlocks(curX, curY, curZ, start.x, start.y, start.z)
    local stripMineFuel = stripMineCalculateBlocks(tunnelLength, tunnelHeight)
    local backToStartFuel = goToCalculateBlocks(curX + tunnelLength, curY + tunnelHeight, curZ, start.x, start.y, start.z)
    local backToCur = goToCalculateBlocks(start.x, start.y, start.z, curX, curY, curZ)
    local totalBlocks = toStartFuel + stripMineFuel + backToStartFuel + backToCur

    local necessaryFuel = getNecessaryFuel(totalBlocks - turtle.getFuelLevel(), "coal")
    print("Blocks to move = ", totalBlocks)
    -- print("NecessaryFuel items = ", necessaryFuel)
    if not refuelTurtle(necessaryFuel) then
        -- If it doesn't have enough fuel to do dig line
        print("rip, doesn't have enough fuel to do dig area")
        sleep(5)
        os.shutdown()
    end

    -- TODO always go to most positive X and Z corner and turn toward positive X
    

    turnToOrientation(POSITIVE_X_ORIENTATION)
    stripMine(tunnelLength, tunnelHeight)

    print("going back to start strip location")
    goTo(start.x, start.y, start.z)

    filterItems()
    
end

function stripMine(tunnelLength, tunnelHeight)
    -- for simplicity, always move in positive X

    for xIter = 1, tunnelLength, 1 do
        digAndMoveForward(1)
        if xIter % 2 == 1 then
            digAndMoveUp(tunnelHeight-1)
        else
            digAndMoveDown(tunnelHeight-1)
        end
    end

end




-- if turtle.getFuelLevel() == 0 then refuelTurtle(1) end

-- currOrientation = getOrientation()

-- local gpsX, gpsY, gpsZ = gps.locate(2)
local start = nil
local delta = nil

local modem = peripheral.wrap("left")

modem.open(TURTLE_CHANNEL)
modem.transmit(SERVER_CHANNEL, TURTLE_CHANNEL, "ready")

while true do
    local event, modemSide, senderChannel, 
        replyChannel, message, senderDistance = os.pullEvent("modem_message")

    print("Received message from channel ", replyChannel)

    if replyChannel == SERVER_CHANNEL then
        local messageSplit = split(message, ',')

        if messageSplit[1] == "start" then
            local start = {x = messageSplit[2], y = messageSplit[3], z = messageSplit[4]}
            local delta = {x = messageSplit[5], y = messageSplit[6], z = messageSplit[7]}
            break
        end

        print("bad command from server")
        os.shutdown()
    else
        print("Received unrecognizable event from channel ", replyChannel)
        print("Received message = ", message)
    end
end


-- TODO move code for running multi turtles to a new turtle file
-- TODO turtle is gonna just dig through a bunch of shit, maybe make it go up one block or something when it encounters something
-- TODO get turtle to refuel from below chest, also add functionality for more than one stack of coal
-- TODO check how to get orientation before/after sending ready command, maybe just set static orientation from start? 

digAreaFill(start, delta)