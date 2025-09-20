BWOVehicles = BWOVehicles or {}

BWOVehicles.tab = BWOVehicles.tab or {}

BWOVehicles.carChoices = BWOVehicles.carChoices or {"Base.CarLights", "Base.CarLuxury", "Base.CarNormal", "Base.CarStationWagon", 
                          "Base.CarTaxi", "Base.ModernCar", "Base.PickUpTruck", "Base.PickUpTruckLights", 
                          "Base.PickUpVan", "Base.PickUpVanLights", "Base.SUV", "Base.SmallCar", 
                          "Base.SportsCar", "Base.StepVan", "Base.Van"}

-- order is important
BWOVehicles.burnMap = BWOVehicles.burnMap or {}

BWOVehicles.burnMap["Base.CarLights"] = "Base.CarNormalBurnt"
BWOVehicles.burnMap["Base.CarLuxury"] = "Base.LuxuryCarBurnt"
BWOVehicles.burnMap["Base.NormalCarPolice"] = "Base.NormalCarBurntPolice"
BWOVehicles.burnMap["Base.CarNormal"] = "Base.CarNormalBurnt"
BWOVehicles.burnMap["Base.CarStationWagon"] = "Base.CarNormalBurnt"
BWOVehicles.burnMap["Base.ModernCar"] = "Base.ModernCar02Burnt"
BWOVehicles.burnMap["Base.ModernCar02"] = "Base.SmallCar02Burnt"
BWOVehicles.burnMap["Base.SmallCar02"] = "Base.SmallCar02Burnt"
BWOVehicles.burnMap["Base.CarSmall02"] = "Base.SmallCar02Burnt"
BWOVehicles.burnMap["Base.SmallCar"] = "Base.SmallCarBurnt"
BWOVehicles.burnMap["Base.CarSmall"] = "Base.SmallCarBurnt"
BWOVehicles.burnMap["Base.SportsCar"] = "Base.SportsCarBurnt"
BWOVehicles.burnMap["Base.OffRoad"] = "Base.OffRoadBurnt"
BWOVehicles.burnMap["Base.LuxuryCar"] = "Base.LuxuryCarBurnt"
BWOVehicles.burnMap["Base.SUV"] = "Base.SUVBurnt"
BWOVehicles.burnMap["Base.Taxi"] = "Base.TaxiBurnt"
BWOVehicles.burnMap["Base.CarTaxi"] = "Base.TaxiBurnt"
BWOVehicles.burnMap["Base.CarTaxi2"] = "Base.TaxiBurnt"
BWOVehicles.burnMap["Base.PickUpVanLights"] = "Base.PickUpVanLightsBurnt"
BWOVehicles.burnMap["Base.PickUpVan"] = "Base.PickUpVanBurnt"
BWOVehicles.burnMap["Base.VanAmbulance"] = "Base.AmbulanceBurnt"
BWOVehicles.burnMap["Base.VanRadio"] = "Base.VanRadioBurnt"
BWOVehicles.burnMap["Base.VanSeats"] = "Base.VanSeatsBurnt"
BWOVehicles.burnMap["Base.Van"] = "Base.VanBurnt"
BWOVehicles.burnMap["Base.StepVan"] = "Base.VanBurnt"
BWOVehicles.burnMap["Base.PickupSpecial"] = "Base.PickupSpecialBurnt"
BWOVehicles.burnMap["Base.PickUpTruck"] = "Base.PickupBurnt"
BWOVehicles.burnMap["Base.Pickup"] = "Base.PickupBurnt"

BWOVehicles.parts = BWOVehicles.parts or {}
BWOVehicles.parts[1] = "HeadlightLeft"
BWOVehicles.parts[2] = "HeadlightRight"
BWOVehicles.parts[3] = "HeadlightRearLeft"
BWOVehicles.parts[4] = "HeadlightRight"
BWOVehicles.parts[5] = "Windshield"
BWOVehicles.parts[6] = "WindshieldRear"
BWOVehicles.parts[7] = "WindowFrontRight"
BWOVehicles.parts[8] = "WindowFrontLeft"
BWOVehicles.parts[9] = "WindowRearRight"
BWOVehicles.parts[10] = "WindowRearLeft"
BWOVehicles.parts[11] = "WindowMiddleLeft"
BWOVehicles.parts[12] = "WindowMiddleRight"
BWOVehicles.parts[13] = "DoorFrontRight"
BWOVehicles.parts[14] = "DoorFrontLeft"
BWOVehicles.parts[15] = "DoorRearRight"
BWOVehicles.parts[16] = "DoorRearLeft"
BWOVehicles.parts[17] = "EngineDoor"
BWOVehicles.parts[18] = "TireFrontRight"
BWOVehicles.parts[19] = "TireFrontLeft"
BWOVehicles.parts[20] = "TireRearLeft"
BWOVehicles.parts[21] = "TireRearRight"

BWOVehicles.Register = function(vehicle)
    local id = vehicle:getId()
    BWOVehicles.tab[id] = vehicle
end

BWOVehicles.VehicleSpawn = function(x, y, dir, btype)
    local square = getCell():getGridSquare(x, y, 0)
    if square then
        if not square:isFree(false) then return end
        if square:isVehicleIntersecting() then return end

        local vehicle = addVehicleDebug(BWOCompatibility.GetCarType(btype), dir, nil, square)
        if vehicle then
            for i = 0, vehicle:getPartCount() - 1 do
                local container = vehicle:getPartByIndex(i):getItemContainer()
                if container then
                    container:removeAllItems()
                end
            end
            vehicle:getModData().BWO = vehicle:getModData().BWO or {}
            vehicle:getModData().BWO.wasRepaired = true
            BWOVehicles.Repair(vehicle)
            vehicle:setColor(ZombRandFloat(0, 1), ZombRandFloat(0, 1), ZombRandFloat(0, 1))
            vehicle:setAlarmed(false)
            vehicle:setGeneralPartCondition(100, 80)
            vehicle:setHeadlightsOn(true)

            local md = vehicle:getModData()
            if not md.BWO then md.BWO = {} end
            md.BWO.autonomous = true

            if dir == IsoDirections.N then
                vehicle:setAngles(0, 180, 0)
                md.BWO.dir = "N"
            elseif dir == IsoDirections.S then
                vehicle:setAngles(0, 0, 0)
                md.BWO.dir = "S"
            elseif dir == IsoDirections.E then
                vehicle:setAngles(0, 90, 0)
                md.BWO.dir = "E"
            elseif dir == IsoDirections.W then
                vehicle:setAngles(0, -90, 0)
                md.BWO.dir = "W"
            end

            BWOVehicles.Register(vehicle)
        end
    end
end

BWOVehicles.Repair = function(vehicle)
    for i = 0, vehicle:getPartCount() - 1 do
        local part = vehicle:getPartByIndex(i)
        local area = part:getArea()
        if area and not area:embodies("Armor") then
            local cond = 70 + ZombRand(40)
            if cond > 100 then cond = 100 end
            part:setCondition(cond)
        end
    end
    local gasTank = vehicle:getPartById("GasTank")
    if gasTank then
        local max = gasTank:getContainerCapacity() * 0.7
        gasTank:setContainerContentAmount(ZombRandFloat(0, max))
    end
end

BWOVehicles.Burn = function(vehicle)
    local burnMap = BWOVehicles.burnMap
    local scriptName = vehicle:getScriptName()
    if scriptName:embodies("Burnt") then return end
    for k, v in pairs(burnMap) do
        if scriptName:embodies(k) then
            -- disable physics before removing to avoid client Bullet errors
            vehicle:setPhysicsActive(false)
            local ax = vehicle:getAngleX()
            local ay = vehicle:getAngleY()
            local az = vehicle:getAngleZ()
            vehicle:permanentlyRemove()
            local vehicleBurnt = addVehicleDebug(v, IsoDirections.S, nil, vehicle:getSquare())
            if vehicleBurnt then
                for i = 0, vehicleBurnt:getPartCount() - 1 do
                    local container = vehicleBurnt:getPartByIndex(i):getItemContainer()
                    if container then
                        container:removeAllItems()
                    end
                end
                vehicleBurnt:getModData().BWO = vehicleBurnt:getModData().BWO or {}
                vehicleBurnt:getModData().BWO.wasRepaired = true
                vehicleBurnt:setAngles(ax, ay, az)
            end
            break
        end
    end
end

local dirMap = {}
dirMap.N = {}
for y=-12, -4 do
    for x=-1, 1 do
        table.insert(dirMap.N, {x=x, y=y})
    end
end

dirMap.S = {}
for y=4, 12 do
    for x=-1, 1 do
        table.insert(dirMap.S, {x=x, y=y})
    end
end

dirMap.W = {}
for x=-20, -4 do
    for y=-1, -1 do
        table.insert(dirMap.W, {x=x, y=y})
    end
end

dirMap.E = {}
for x=4, 12 do
    for y=-1, 1 do
        table.insert(dirMap.E, {x=x, y=y})
    end
end

BWOVehicles.dirMap = dirMap

local function getAnyOnlinePlayer()
    local players = getOnlinePlayers()
    if players and players:size() > 0 then
        return players:get(0)
    end
    return getSpecificPlayer(0)
end

BWOVehicles.FindSpawnPoint = function(player)
    if not player then return end

    local function getInfo(x, y)
        local res = {}
        res.valid = false
        local xlen = 0
        local xmin = math.huge
        local xmax = 0
        for i = -14, 14 do
            local dx = x + i
            if BanditUtils.HasZoneType(dx, y, 0, "Nav") then 
                xlen = xlen + 1 
                if dx < xmin then xmin = dx end
                if dx > xmax then xmax = dx end
            end
        end
        local ylen = 0
        local ymin = math.huge
        local ymax = 0
        for i = -14, 14 do
            local dy = y + i
            if BanditUtils.HasZoneType(x, dy, 0, "Nav") then 
                ylen = ylen + 1
                if dy < ymin then ymin = dy end
                if dy > ymax then ymax = dy end
            end
        end
        if xlen > 20 and ylen >= 8 then
            res.valid = true
            res.orientation = "X"
            res.min = ymin
            res.max = ymax
            res.width = ylen
        elseif ylen > 20 and xlen >= 8 then
            res.valid = true
            res.orientation = "Y"
            res.min = xmin
            res.max = xmax
            res.width = xlen
        end
        return res
    end

    local function checkPoint(x, y)
        local res = {}
        res.valid = false
        if BanditUtils.HasZoneType(x, y, 0, "Nav") then
            local roadInfo = getInfo(x, y)
            if roadInfo.valid then
                res.valid = true
                if roadInfo.orientation == "X" then
                    res.toEast = { x = x - 50, y = roadInfo.max - 1, dir = IsoDirections.E }
                    res.toWest = { x = x + 50, y = roadInfo.min + 2, dir = IsoDirections.W }
                    for dx=x-50, x+50, 5 do
                        local ri = getInfo(dx, y)
                        if not ri.valid then res.valid = false; break end
                    end
                else
                    res.toNorth = { x = roadInfo.max - 1, y = y + 50, dir = IsoDirections.N }
                    res.toSouth = { x = roadInfo.min + 2, y = y - 50, dir = IsoDirections.S }
                    for dy=y-50, y+50, 5 do
                        local ri = getInfo(x, dy)
                        if not ri.valid then res.valid = false; break end
                    end
                end
            end
        end
        return res
    end

    local px = math.floor(player:getX()+0.5)
    local py = math.floor(player:getY()+0.5)

    local list = {}
    for x=px-25, px+25, 5 do
        local res = checkPoint (x, py)
        if res.valid then 
            table.insert(list, res)
        end
    end
    for y=py-25, py+25, 5 do
        local res = checkPoint (px, y)
        if res.valid then 
            table.insert(list, res)
        end
    end
    if #list == 0 then return end
    for i = #list, 2, -1 do
        local j = ZombRand(i) + 1
        list[i], list[j] = list[j], list[i]
    end
    local res = list[1]
    if res.valid then
        local x, y, dir
        local btype = BWOCompatibility.GetCarType(BanditUtils.Choice(BWOVehicles.carChoices))
        if res.toNorth and res.toSouth then
            if ZombRand(2) == 0 then
                x = res.toNorth.x; y = res.toNorth.y; dir = res.toNorth.dir
            else
                x = res.toSouth.x; y = res.toSouth.y; dir = res.toSouth.dir
            end
        elseif res.toEast and res.toWest then
            if ZombRand(2) == 0 then
                x = res.toEast.x; y = res.toEast.y; dir = res.toEast.dir
            else
                x = res.toWest.x; y = res.toWest.y; dir = res.toWest.dir
            end
        end
        BWOVehicles.VehicleSpawn(x, y, dir, btype)
    end
end

local function AddVehicles()
    -- compute world age on server without relying on client scheduler
    local gametime = getGameTime()
    local worldAge = gametime and gametime:getWorldAgeHours() or 0
    if worldAge > 168 then return end
    local hour = gametime:getHour()
    local minute = gametime:getMinutes()
    if minute % 2 == 1 then return end
    local cnt = 0
    for _, _ in pairs(BWOVehicles.tab) do cnt = cnt + 1 end
    local max = 0
    if hour == 5 then
        max = math.floor(SandboxVars.BanditsWeekOne.VehiclesMax / 3)
    elseif hour >= 6 and hour < 19 then
        max = SandboxVars.BanditsWeekOne.VehiclesMax
    elseif hour >= 20 and hour < 23 then
        max = math.floor(SandboxVars.BanditsWeekOne.VehiclesMax / 3)
    end
    if cnt < max then
        BWOVehicles.FindSpawnPoint(getAnyOnlinePlayer())
    end
end

local function ManageVehicles(ticks)
    if ticks % 6 > 0 then return end
    local dirMap = BWOVehicles.dirMap
    local vehicleList = BWOVehicles.tab
    for id, vehicle in pairs(vehicleList) do
        local controller = vehicle:getController()
        -- controller may be nil on server; keep the vehicle to allow NPC driver attachment
        if not vehicle:isSeatInstalled(0) then
            BWOVehicles.tab[id] = nil
            break
        end
        local square = vehicle:getSquare()
        if square then
            local cell = square:getCell()
            local vx = vehicle:getX()
            local vy = vehicle:getY()
            local driver = vehicle:getDriver()
            if driver then
                if driver:isNPC() then 
                    local closest = getAnyOnlinePlayer()
                    if closest then
                        local dist = BanditUtils.DistToManhattan(closest:getX(), closest:getY(), vx, vy)
                        if dist > 51 then
                            local seat = vehicle:getSeat(driver)
                            vehicle:clearPassenger(seat)
                            driver:setVehicle(nil)
                            driver:setCollidable(true)
                            driver:Kill(nil)
                            driver:removeSaveFile()
                            driver:removeFromSquare()
                            driver:removeFromWorld()
                            vehicle:permanentlyRemove()
                            BWOVehicles.tab[id] = nil
                            break
                        end
                    end
                    local md = vehicle:getModData()
                    if not md.BWO then md.BWO = {} end
                    local dir = md.BWO.dir
                    if dir then
                        local vecs = dirMap[dir]
                        for _, vec in pairs(vecs) do
                            local asquare = cell:getGridSquare(vx + vec.x, vy + vec.y, 0)
                            if asquare then
                                local shouldStop = false
                                if not asquare:isFree(false) or asquare:isVehicleIntersecting() then
                                    shouldStop = true
                                end
                                if shouldStop then
                                    vehicle:setRegulatorSpeed(0)
                                    vehicle:setRegulator(false)
                                    return
                                end
                            end
                        end
                        -- leave engine/regulator unchanged for spawned vehicles
                    end
                end
            else
                -- NPC driver creation and engine start disabled for spawned vehicles
            end
        end
    end
end

Events.OnTick.Add(ManageVehicles)
-- Temporarily disable periodic vehicle spawns; use admin UI instead
-- Events.EveryOneMinute.Add(AddVehicles)


