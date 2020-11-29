local SERVER_CHANNEL = 1
local TURTLE_CHANNEL = 2
local TURTLE_CREATOR_CHANNEL = 3
local PHONE_CHANNEL = 4

local modem = peripheral.wrap("right")
modem.open(SERVER_CHANNEL)

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

function handlePhoneEvent(message)
    print("Handling phone event...")
    -- Area fill message = "areaFill,<numOfTurtles>,<startX>,<startY>,<startZ>,<deltaX>,<deltaY>,<deltaZ>"
    -- Strip Mining message = "stripMine,<numOfTurtles>,<startX>,<startY>,<startZ>,<numOfTunnels>,<tunnelLength>,<tunnelHeight>"
    local messageSplit = split(message, ',')
    local miningType = messageSplit[1]
    local numOfTurtles = messageSplit[2]

    if miningType == "areaFill" then

    elseif miningType == "stripMine" then

    else
        print("miningType was not a proper value...")
    end

end

function handleTurtleCreatorEvent(message)
    print("Handling turtle creator event...")

    local messageSplit = split(message, ',')
end

while true do
    local event, modemSide, senderChannel, 
        replyChannel, message, senderDistance = os.pullEvent("modem_message")

    print("Received message from channel ", replyChannel)

    if replyChannel == PHONE_CHANNEL then handlePhoneEvent(message)
    elseif replyChannel == TURTLE_CREATOR_CHANNEL then handleTurtleCreatorEvent(message)
    else
        print("Received unrecognizable event from channel ", replyChannel)
        print("Received message = ", message)
    end
end



-- turtle creator message format
-- Area fill message = "<command>?,<"areaFill">,<startX>,<startY>,<startZ>,<deltaX>,<deltaY>,<deltaZ>"
-- Strip Mining message = "<command>?,<"stripMine">,<startX>,<startY>,<startZ>,<tunnelLength>,<tunnelHeight>"
-- modem.transmit(TURTLE_CREATOR_CHANNEL, SERVER_CHANNEL, "create,areaFill,420,69,420,20,20,20")