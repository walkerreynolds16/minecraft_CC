-- This script will run on the turtle that creates the turtles for deployment
local SERVER_CHANNEL = 1
local TURTLE_CHANNEL = 2
local TURTLE_CREATOR_CHANNEL = 3
local PHONE_CHANNEL = 4

local ITEM_SLOTS = 16

local modem = peripheral.wrap("left")

modem.open(TURTLE_CREATOR_CHANNEL)

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

function checkIfCanCreateTurtle()
    -- need to check if turtle is in inventory
    -- need to check if shit is in the way of the placement block
    local slotNum, itemData = findItemInInventory("computercraft:turtle_expanded")

    if not slotNum or not itemData then return false end
    if turtle.inspect() then return false end

    turtle.select(slotNum)
    return true

end

function placeTurtle() 
    if not checkIfCanCreateTurtle() then print("can't make turtle, sorry uWu") return end

    turtle.place()
end

function decodeMessage(message)
    local messageSplit = split(message, ',')
    print("Command = ", messageSplit[1])
    print("MiningType = ", messageSplit[2])

    if miningType == "areaFill" then
        print("StartX = ", messageSplit[3])
        print("StartY = ", messageSplit[4])
        print("StartZ = ", messageSplit[5])
        print("DeltaX = ", messageSplit[6])
        print("DeltaY = ", messageSplit[7])
        print("DeltaZ = ", messageSplit[8])

        if not checkIfCanCreateTurtle() then print("can't make turtle, sorry uWu") end

        createTurtle()

    elseif miningType == "stripMine" then
        print("StartX = ", messageSplit[3])
        print("StartY = ", messageSplit[4])
        print("StartZ = ", messageSplit[5])
        print("tunnelLength = ", messageSplit[6])
        print("tunnelHeight = ", messageSplit[7])
    else
        print("miningType was not a proper value...")
        sleep(5)
        os.shutdown()
    end

    

end


function getAvailableTurtleCount()
    local turtleCount = 0
    for i = 1, ITEM_SLOTS, 1 do
        local itemData = turtle.getItemDetail(i)

        if itemData and (itemData.name == "computercraft:turtle_expanded") then
            turtleCount = turtleCount + itemData.count
        end
    end

    return turtleCount
end

function handleServerEvent(message)
    local messageSplit = split(message)

    if messageSplit[1] == "getTurtleCount" then
        local count = getAvailableTurtleCount()
        print("available count = ", count)
        local commandString = string.format("%s,%s", "numTurtleResponse", count)
        modem.transmit(SERVER_CHANNEL, TURTLE_CREATOR_CHANNEL, commandString)

    elseif messageSplit[1] == "placeTurtle" then
        placeTurtle()
    else
        print("event type was not a proper value...")
    end
end


while true do
    print("looking for events...")
    local event, modemSide, senderChannel, 
        replyChannel, message, senderDistance = os.pullEvent("modem_message")

    print("Received message from channel ", replyChannel)

    if replyChannel == SERVER_CHANNEL then handleServerEvent(message)
    else
        print("Received unrecognizable event from channel ", replyChannel)
        print("Received message = ", message)
    end
end

-- decodeMessage(message)
