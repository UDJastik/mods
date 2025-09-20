BWOEventsPlace = BWOEventsPlace or {}

local spawnVehicle = function(x, y, dir, vtype)
    local cell = getCell()
    local square = getCell():getGridSquare(x, y, 0)
    if not square then return end

    if not square:isFree(false) then return end

    if square:getVehicleContainer() then return end

    local vehicle = BWOCompatibility.AddVehicle(vtype, dir, square)
    
    if not vehicle then return end

    --[[
    for i = 0, vehicle:getPartCount() - 1 do
        local container = vehicle:getPartByIndex(i):getItemContainer()
        if container then
            container:removeAllItems()
        end
    end]]

    vehicle:getModData().BWO = {}
    vehicle:getModData().BWO.wasRepaired = true
    vehicle:repair()
    vehicle:setColor(ZombRandFloat(0, 1), ZombRandFloat(0, 1), ZombRandFloat(0, 1))
    vehicle:setTrunkLocked(true)
    for i=0, vehicle:getMaxPassengers() -1 do 
        local part = vehicle:getPassengerDoor(i)
        if part then 
            local door = part:getDoor()
            if door then
                door:setLocked(true)
            end
        end
    end

    local gasTank = vehicle:getPartById("GasTank")
    if gasTank then
        local max = gasTank:getContainerCapacity() * 0.8
        gasTank:setContainerContentAmount(ZombRandFloat(0, max))
    end
end

function BWOEventsPlace.ArmyGuards(params)
    config = {}
    config.clanId = 0
    config.hasRifleChance = 100
    config.hasPistolChance = 100
    config.rifleMagCount = 6
    config.pistolMagCount = 3

    local event = {}
    event.hostile = false
    event.occured = false
    event.program = {}
    event.program.name = "ArmyGuard"
    event.program.stage = "Prepare"

    event.x = params.x
    event.y = params.y
    event.bandits = {}
    
    local bandit = BanditCreator.MakeFromWave(config)
    bandit.hairStyle = BanditUtils.Choice({"Bald", "Fresh", "Demi", "FlatTop", "MohawkShort"})
    bandit.accuracyBoost = 1.6
    bandit.femaleChance = 0
    bandit.health = 6
    bandit.outfit = "ZSArmySpecialOps"
    bandit.weapons.melee = "Base.HuntingKnife"

    local intensity = 4
    if intensity > 0 then
        for i=1, intensity do
            table.insert(event.bandits, bandit)
        end
        local player = getPlayer()
        sendClientCommand(player, 'Commands', 'SpawnGroup', event)
    end

    if SandboxVars.Bandits.General_ArrivalIcon then
        local icon = "media/ui/raid.png"
        local color = {r=0, g=1, b=0} -- green
        BanditEventMarkerHandler.setOrUpdate(getRandomUUID(), icon, 10, event.x, event.y, color)
    end
end

function BWOEventsPlace.GunshopGuard(params)
    config = {}
    config.clanId = 0
    config.hasRifleChance = 100
    config.hasPistolChance = 100
    config.rifleMagCount = 6
    config.pistolMagCount = 3

    local event = {}
    event.hostile = false
    event.occured = false
    event.program = {}
    event.program.name = "ArmyGuard"
    event.program.stage = "Prepare"

    event.x = params.x
    event.y = params.y
    event.bandits = {}
    
    local bandit = BanditCreator.MakeFromWave(config)
    bandit.accuracyBoost = 1.6
    bandit.femaleChance = 0
    bandit.health = 6
    bandit.outfit = "Veteran"
    bandit.weapons.melee = "Base.HuntingKnife"

    local intensity = 2
    if intensity > 0 then
        for i=1, intensity do
            table.insert(event.bandits, bandit)
        end
        local player = getPlayer()
        sendClientCommand(player, 'Commands', 'SpawnGroup', event)
    end
end

function BWOEventsPlace.BaseDefenders(params)
    config = {}
    config.clanId = 15
    config.hasRifleChance = 100
    config.hasPistolChance = 100
    config.rifleMagCount = 6
    config.pistolMagCount = 3

    local event = {}
    event.hostile = true
    event.occured = false
    event.program = {}
    event.program.name = "ArmyGuard"
    event.program.stage = "Prepare"

    event.x = params.x
    event.y = params.y
    event.bandits = {}
    
    local bandit = BanditCreator.MakeFromWave(config)

    local intensity = 4
    if intensity > 0 then
        for i=1, intensity do
            table.insert(event.bandits, bandit)
        end
        local player = getPlayer()
        sendClientCommand(player, 'Commands', 'SpawnGroup', event)
    end

    if SandboxVars.Bandits.General_ArrivalIcon then
        local icon = "media/ui/raid.png"
        local color = {r=1, g=0, b=0} -- red
        BanditEventMarkerHandler.setOrUpdate(getRandomUUID(), icon, 10, event.x, event.y, color)
    end
end

function BWOEventsPlace.CarMechanic(params)

    local cell = getCell()
    local square = getCell():getGridSquare(params.x, params.y, 0)
    if not square then return end

    local vtype = BanditUtils.Choice(BWOVehicles.carChoices)

    local vehicle = BWOCompatibility.AddVehicle(vtype, params.dir, square)
    if not vehicle then return end

    --[[local vehicle = BaseVehicle.new(cell)
    vehicle:setScriptName(vtype)
    vehicle:setScript()
    vehicle:setDir(params.directions)
    vehicle:setX(params.x)
    vehicle:setY(params.y)
    vehicle:setZ(0)
    vehicle:setSquare(square)
    VehiclesDB2.instance:addVehicle(vehicle)
    -- vehicle:addToWorld()
    -- vehicle:setRust(0)]]

    if params.dir == IsoDirections.N then
        vehicle:setAngles(0, 180, 0)
    elseif params.dir == IsoDirections.S then
        vehicle:setAngles(0, 0, 0)
    elseif params.dir == IsoDirections.E then
        vehicle:setAngles(0, 90, 0)
    elseif params.dir == IsoDirections.W then
        -- vehicle:setAngles(-125, -90, -125)
        vehicle:setAngles(0, -90, 0)
    end

    for i = 0, vehicle:getPartCount() - 1 do
        local container = vehicle:getPartByIndex(i):getItemContainer()
        if container then
            container:removeAllItems()
        end
    end

    if params.dx then
        vehicle:setX(params.x + params.dx)
    end

    local md = vehicle:getModData()
    md.BWO = {}
    md.BWO.wasRepaired = true
    md.BWO.client = true
    md.BWO.parts = {}
    BWOVehicles.Repair(vehicle)
    vehicle:setColor(0, 0, 0)
    vehicle:setGeneralPartCondition(100, 100)
    vehicle:putKeyInIgnition(vehicle:createVehicleKey())

    for i = 1, 21 do
        md.BWO.parts[i] = 100
    end

    for i = 1, 10 do
        local partRandom = 1 + ZombRand(21)
        local vehiclePart = vehicle:getPartById(BWOVehicles.parts[partRandom])
        if vehiclePart then
            local cond = 20 + ZombRand(40)
            vehiclePart:setCondition(cond)
            md.BWO.parts[partRandom] = cond
        end
    end

end

function BWOEventsPlace.Emitter(params)
    local effect = {}
    effect.x = params.x
    effect.y = params.y
    effect.z = params.z
    effect.len = params.len --2460
    effect.sound = params.sound -- "ZSBuildingBaseAlert"
    effect.light = params.light -- {r=1, g=0, b=0, t=10}
    BWOEmitter.Add(effect)
end

function BWOEventsPlace.AbandonedVehicle(params)
    local vtype = BanditUtils.Choice(BWOVehicles.carChoices)
    spawnVehicle(params.x, params.y, params.dir, vtype)
end

function BWOEventsPlace.BuildingParty(params)
    BWOEvents.BuildingParty(params)
end