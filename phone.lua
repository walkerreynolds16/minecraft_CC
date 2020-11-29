local SERVER_CHANNEL = 1
local PHONE_CHANNEL = 4

local modem = peripheral.wrap("back")

modem.open(PHONE_CHANNEL)

-- program params
-- Area fill dig -> areaFill <numOfTurtles> <deltaX> <deltaY> <deltaZ>
-- Strip Mine dig -> stripMine <numOfTurtles> <numOfTunnels> <tunnelLength> <tunnelHeight>

local miningType = arg[1]
local numOfTurtles = arg[2]

if not miningType or not numOfTurtles then 
    -- Program didn't have proper params
    print("Program wasn't given proper params...")
    sleep(3)
    os.shutdown()
end

local gpsX, gpsY, gpsZ = gps.locate(2)

if miningType == "areaFill" then
    print("DeltaX = ", arg[3])
    print("DeltaY = ", arg[4])
    print("DeltaZ = ", arg[5])
    local commandString = string.format("%s,%s,%s,%s,%s,%s,%s,%s", miningType, numOfTurtles, math.floor(gpsX), math.floor(gpsY), math.floor(gpsZ), arg[3], arg[4], arg[5])

    modem.transmit(SERVER_CHANNEL, PHONE_CHANNEL, commandString)

elseif miningType == "stripMine" then
    print("numOfTunnels = ", arg[3])
    print("tunnelLength = ", arg[4])
    print("tunnelHeight = ", arg[5])

    local commandString = string.format("%s,%s,%s,%s,%s,%s,%s,%s", miningType, numOfTurtles, gpsX, gpsY, gpsZ, arg[3], arg[4], arg[5])

    modem.transmit(SERVER_CHANNEL, PHONE_CHANNEL, commandString)


else
    print("miningType was not a proper value...")
    sleep(3)
    os.shutdown()
end
