local SERVER_CHANNEL = 1
local PHONE_CHANNEL = 4

local modem = peripheral.wrap("back")

modem.open(PHONE_CHANNEL)

-- program params
-- Area fill dig -> areaFill <deltaX> <deltaY> <deltaZ>
-- Strip Mine dig -> stripMine <numOfTunnels> <tunnelLength> <tunnelHeight>

local miningType = arg[1]

if not miningType then 
    -- Program didn't have proper params
    print("Program wasn't given proper params...")
    sleep(3)
    os.shutdown()
end

local gpsX, gpsY, gpsZ = gps.locate(2)

if miningType == "areaFill" then
    print("DeltaX = ", arg[2])
    print("DeltaY = ", arg[3])
    print("DeltaZ = ", arg[4])
    local commandString = string.format("%s,%s,%s,%s,%s,%s,%s", miningType, math.floor(gpsX), math.floor(gpsY), math.floor(gpsZ), arg[2], arg[3], arg[4])

    modem.transmit(SERVER_CHANNEL, PHONE_CHANNEL, commandString)

elseif miningType == "stripMine" then
    print("numOfTunnels = ", arg[2])
    print("tunnelLength = ", arg[3])
    print("tunnelHeight = ", arg[4])

    local commandString = string.format("%s,%s,%s,%s,%s,%s,%s", miningType, gpsX, gpsY, gpsZ, arg[2], arg[3], arg[4])

    modem.transmit(SERVER_CHANNEL, PHONE_CHANNEL, commandString)


else
    print("miningType was not a proper value...")
    sleep(3)
    os.shutdown()
end
