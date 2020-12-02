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

function getAvailableTurtleCount()

    modem.transmit(TURTLE_CREATOR_CHANNEL, SERVER_CHANNEL, "getTurtleCount")

    numOfTurtles = nil

    parallel.waitForAny(
        function()
            local event, modemSide, senderChannel, 
                replyChannel, message, senderDistance = os.pullEvent("modem_message")
            
            local messageSplit = split(message, ',')
            if replyChannel == TURTLE_CREATOR_CHANNEL and messageSplit[1] == "numTurtleResponse" then
                numOfTurtles = messageSplit[2]
            else
                print("received wrong event..")
                os.queueEvent(event, modemSide, senderChannel, replyChannel, message, senderDistance)
            end
        end,
        function()
            sleep(5)
            print( "getAvailableTurtleCount call timedout..." )
        end
    )

    if numOfTurtles == nil then 
        print("Didn't get numOfTurtles from creator, stoping request...")
        return
    end

    return numOfTurtles
end

function splitDigArea(availableTurtles, start, delta)
    bestNumOfTurtles = 1
    bestScore = 0

    for i = 1, availableTurtles, 1 do
        local sqrt = math.sqrt(i)
        local xSections = math.floor(delta.x / sqrt)
        local zSections = math.floor(delta.z / sqrt)

        local ogArea = (delta.x * delta.z) 
        local sectionedArea = (xSections * zSections * i)
        local areaDiff = ogArea - sectionedArea

        print(string.format("NumOfTurtles = %s, OGArea = %s, sectionedArea = %s, areaDiff = %s", i, ogArea, sectionedArea, areaDiff))

        local score = (i * 5) - areaDiff

        if score > bestScore then
            bestNumOfTurtles = i
            bestScore = score
        end
    end

    print(string.format("Best NumOfTurtles = %s, Best Score = %s", bestNumOfTurtles, bestScore))
    sqrt = math.sqrt(bestNumOfTurtles)
    print("sectionX size = ", math.floor(delta.x / sqrt))
    print("sectionZ size = ", math.floor(delta.z / sqrt))

    xSectionSize = math.floor(delta.x / sqrt)
    zSectionSize = math.floor(delta.z / sqrt)

    numXSections = delta.x / xSectionSize
    numZSections = delta.z / zSectionSize

    startingPositions = {}

    for xSection = 0, numXSections-1, 1 do
        for zSection = 0, numZSections-1, 1 do
            xStart = start.x + (xSectionSize * xSection)
            zStart = start.z + (zSectionSize * zSection)

            tempStart = {
                x = xStart,
                y = start.y,
                z = zStart
            }

            table.insert(startingPositions, tempStart)
        end
    end

    sectionDelta = {
        x = xSectionSize,
        y = delta.y,
        z = zSectionSize
    }

    return startingPositions, sectionDelta

end

function waitForReadyTurtle(start, delta)
    parallel.waitForAny(
        function()
            local event, modemSide, senderChannel, 
                replyChannel, message, senderDistance = os.pullEvent("modem_message")
            
            local messageSplit = split(message, ',')
            if replyChannel == TURTLE_CHANNEL and messageSplit[1] == "ready" then
                -- tell turtle where to go 
                local commandString = string.format("%s,%s,%s,%s,%s,%s,%s", "start", start.x, start.y, start.z, delta.x, delta.y, delta.z)
                modem.transmit(TURTLE_CHANNEL, SERVER_CHANNEL, commandString)
            else
                print("received wrong event..")
                os.queueEvent(event, modemSide, senderChannel, replyChannel, message, senderDistance)
            end
        end,
        function()
            sleep(5)
            print( "waitForReadyTurtle call timedout..." )
        end
    )
end

function placeTurtle()
    local commandString = string.format("%s", "placeTurtle")
    modem.transmit(TURTLE_CREATOR_CHANNEL, SERVER_CHANNEL, commandString)
end

function handlePhoneEvent(message)
    print("Handling phone event...")
    -- Area fill message = "areaFill,<startX>,<startY>,<startZ>,<deltaX>,<deltaY>,<deltaZ>"
    -- Strip Mining message = "stripMine,<startX>,<startY>,<startZ>,<numOfTunnels>,<tunnelLength>,<tunnelHeight>"
    local messageSplit = split(message, ',')
    local miningType = messageSplit[1]

    local start = {
        x = messageSplit[2],
        y = messageSplit[3],
        z = messageSplit[4]
    }

    if miningType == "areaFill" then
        -- get num of turtles available from turtle creator
        -- run function for dividing the area into smaller areas
        local delta = {
            x = messageSplit[5],
            y = messageSplit[6],
            z = messageSplit[7]
        }

        local availableTurtles = getAvailableTurtleCount()

        if availableTurtles == nil then return end
        local startingPositions, sectionDelta = splitDigArea(availableTurtles, start, delta)


        for i = 1, #startingPositions, 1 do
            placeTurtle()
            os.sleep(1)
            waitForReadyTurtle(startingPositions[1], sectionDelta)
        end

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