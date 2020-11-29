-- This script will run on the turtle that creates the turtles for deployment
local TURTLE_CREATOR_CHANNEL = 3

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

function createTurtle() 
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




local event, modemSide, senderChannel, 
  replyChannel, message, senderDistance = os.pullEvent("modem_message")

-- print("I just received a message on channel: "..senderChannel)
-- print("I should apparently reply on channel: "..replyChannel)
-- print("The modem receiving this is located on my "..modemSide.." side")
-- print("The message was: "..message)
-- print("The sender is: "..(senderDistance or "an unknown number of").." blocks away from me.")

decodeMessage(message)
