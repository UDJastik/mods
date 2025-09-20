local TAHeal = require("TimedActions/TAHeal")
require "ISUI/BWODataGraphWindow"
require "ISUI/BWOPopGraphWindow"

BWOMenu = BWOMenu or {}

BWOMenu.HealPerson = function(player, square, bandit)
    local task = {action="TimeEvent", anim="Yes", x=bandit:getX(), y=bandit:getY(), time=400}
    Bandit.AddTask(bandit, task)
    if luautils.walkAdj(player, bandit:getSquare()) then
        ISTimedActionQueue.add(TAHeal:new(player, square, bandit))
    end
end

BWOMenu.DisableLaunchSequence = function(player, square)
    if luautils.walkAdj(player, square) then
        ISTimedActionQueue.add(TADisableNuke:new(player, square))
    end
end

BWOMenu.SpawnRoom = function(player, square, prgName)

    config = {}
    config.clanId = 0
    config.hasRifleChance = 0
    config.hasPistolChance = 0
    config.rifleMagCount = 0
    config.pistolMagCount = 0

    local event = {}
    event.hostile = false
    event.occured = false
    event.program = {}
    event.program.name = prgName
    event.program.stage = "Prepare"
    event.bandits = {}

    local room = square:getRoom()
    if room then
        local name = room:getName()
        local roomDef = room:getRoomDef()
        if roomDef then
            local spawnSquare = roomDef:getFreeSquare()
            if spawnSquare then
                event.x = spawnSquare:getX()
                event.y = spawnSquare:getY()
                event.z = spawnSquare:getZ()
                local bandit = BanditCreator.MakeFromRoom(room)
                if bandit then
                    table.insert(event.bandits, bandit)
                    sendClientCommand(player, 'Commands', 'SpawnGroup', event)
                end
            end
        end
    end
end

BWOMenu.SpawnWave = function(player, square, prgName)
    config = {}
    config.clanId = 0

    config.hasRifleChance = 0
    config.hasPistolChance = 0
    config.rifleMagCount = 0
    config.pistolMagCount = 0

    if prgName == "Babe" then
        config.clanId = 1
        config.hasRifleChance = 100
        config.hasPistolChance = 100
        config.rifleMagCount = 3
        config.pistolMagCount = 3
    elseif prgName == "Shahid" then
        config.clanId = 11
    end

    local event = {}
    event.hostile = false
    event.occured = false
    event.program = {}
    event.program.name = prgName
    event.program.stage = "Prepare"
    event.x = square:getX()
    event.y = square:getY()
    event.bandits = {}
   
    local bandit = BanditCreator.MakeFromWave(config)

    if prgName == "Walker" then
        bandit.outfit = BanditUtils.Choice({"BWORainGeneric01", "BWORainGeneric02", "BWORainGeneric03"})
        bandit.femaleChance = 50
    elseif prgName == "Fireman" then
        bandit.outfit = BanditUtils.Choice({"FiremanFullSuit"})
        bandit.weapons.melee = "Base.Axe"
    elseif prgName == "Gardener" then
        bandit.outfit = BanditUtils.Choice({"Farmer"})
    elseif prgName == "Janitor" then
        bandit.outfit = BanditUtils.Choice({"Sanitation"})
        bandit.weapons.melee = "Base.Broom"
    elseif prgName == "Medic" then
        bandit.outfit = BanditUtils.Choice({"Doctor"})
        bandit.weapons.melee = "Base.Scalpel"
    elseif prgName == "Postal" then
        bandit.outfit = BanditUtils.Choice({"Postal"})
    elseif prgName == "Runner" then
        bandit.outfit = BanditUtils.Choice({"StreetSports", "AuthenticJogger", "AuthenticFitnessInstructor"})
    elseif prgName == "Vandal" then
        bandit.outfit = BanditUtils.Choice({"Bandit"})
    elseif prgName == "Shahid" then
        event.hostile = true
        bandit.femaleChance = 0
        bandit.skinTexture = "MaleBody03a"
        bandit.hairStyle = "Fabian"
        bandit.hairColor = {r=0, g=0, b=0}
        bandit.beardStyle = "Long"
        bandit.beardColor = {r=0, g=0, b=0}

        bandit.outfit = BanditUtils.Choice({"BWOBomber"})
    elseif prgName == "Babe" then
        bandit.permanent = true
        bandit.outfit = BanditUtils.Choice({"BWOYoung", "BWOCow", "BWOLeather"})
        bandit.accuracyBoost = 2
        bandit.femaleChance = 92
        if player:isFemale() then
            bandit.femaleChance = 8
        end
        bandit.health = 8
        bandit.weapons.melee = "Base.BareHands"
    end
    table.insert(event.bandits, bandit)

    sendClientCommand(player, 'Commands', 'SpawnGroup', event)
end

BWOMenu.FlushDeadbodies = function(player)
    local args = {a=1}
    sendClientCommand(getSpecificPlayer(0), 'Commands', 'DeadBodyFlush', args)
end

BWOMenu.TestEmitter = function(player, square)
    local effect = {}
    effect.x = square:getX()
    effect.y = square:getY()
    effect.z = square:getZ()
    effect.len = 300
    effect.volume = 0.1
    -- effect.sound = "ZSBuildingBaseAlert"
    effect.light = {r=1, g=1, b=0.7, t=1}
    BWOEmitter.Add(effect)
end

BWOMenu.EventArmy = function(player)
    local params = {}
    params.intensity = 12
    BWOScheduler.Add("Army", params, 100)
end

BWOMenu.EventArmyPatrol = function(player)
    local params = {}
    params.intensity = 9
    BWOScheduler.Add("ArmyPatrol", params, 100)
end

BWOMenu.EventArson = function(player)
    local params = {}
    params.x = player:getX()
    params.y = player:getY()
    params.z = player:getZ()
    BWOScheduler.Add("Arson", params, 100)
end

BWOMenu.EventGasDrop = function(player)
    local params = {}
    params.x = player:getX()
    params.y = player:getY()
    params.z = player:getZ()
    params.outside = player:isOutside()
    BWOScheduler.Add("GasDrop", params, 100)
end

BWOMenu.EventGasRun = function(player)
    local params = {}
    params.x = player:getX()
    params.y = player:getY()
    params.z = player:getZ()
    params.outside = player:isOutside()
    params.intensity = 10
    BWOScheduler.Add("GasRun", params, 100)
end

BWOMenu.EventBombDrop = function(player)
    local params = {}
    params.x = player:getX()
    params.y = player:getY()
    params.z = player:getZ()
    params.outside = player:isOutside()
    BWOScheduler.Add("BombDrop", params, 100)
end

BWOMenu.EventBombRun = function(player)
    local params = {}
    params.x = player:getX()
    params.y = player:getY()
    params.z = player:getZ()
    params.intensity = 20
    params.outside = player:isOutside()
    BWOScheduler.Add("BombRun", params, 100)
end

BWOMenu.EventNuke = function(player)
    local params = {}
    params.x = player:getX()
    params.y = player:getY()
    params.r = 80
    BWOScheduler.Add("Nuke", params, 100)
end

BWOMenu.EventFinalSolution = function(player)
    local params = {}
    BWOScheduler.Add("FinalSolution", params, 100)
end

BWOMenu.EventFliers = function(player)
    local params = {}
    params.x = player:getX()
    params.y = player:getY()
    params.z = player:getZ()
    BWOScheduler.Add("ChopperFliers", params, 100)
end

BWOMenu.EventEntertainer = function(player, eid)
    local params ={}
    params.x = player:getX()
    params.y = player:getY()
    params.z = player:getZ()
    params.eid = eid
    BWOScheduler.Add("Entertainer", params, 100)
end

BWOMenu.EventParty = function (player)
    local params = {}
    params.roomName = "bedroom"
    params.intensity = 8
    BWOScheduler.Add("BuildingParty", params, 100)
end

BWOMenu.EventJetFighter = function (player)
    local params = {}
    params.x = player:getX()
    params.y = player:getY()
    params.z = player:getZ()
    params.outside = player:isOutside()
    BWOScheduler.Add("JetFighter", params, 100)
end

BWOMenu.EventJetFighterRun = function (player)
    local params = {}
    params.x = player:getX()
    params.y = player:getY()
    params.z = player:getZ()
    params.outside = player:isOutside()
    BWOScheduler.Add("JetFighterRun", params, 100)
end

BWOMenu.EventProtest = function(player)
    local params = {}
    params.x = player:getX()
    params.y = player:getY()
    params.z = player:getZ()
    BWOScheduler.Add("Protest", params, 100)
end

BWOMenu.EventReanimate = function(player)
    local params = {}
    params.x = player:getX()
    params.y = player:getY()
    params.z = player:getZ()
    params.r = 50
    params.chance = 100
    BWOScheduler.Add("Reanimate", params, 100)
end

BWOMenu.EventStart = function(player)
    local params = {}
    BWOScheduler.Add("Start", params, 100)
end

BWOMenu.EventStartDay = function(player)
    local params = {}
    params.day = "wednesday"
    BWOScheduler.Add("StartDay", params, 100)
end

BWOMenu.EventPoliceRiot = function(player)
    local params = {}
    params.intensity = 10
    params.hostile = true
    BWOScheduler.Add("PoliceRiot", params, 100)
end

BWOMenu.EventPower = function(player, on)
    local params = {}
    params.on = on
    BWOScheduler.Add("SetHydroPower", params, 100)
end

BWOMenu.EventBikers = function(player)
    local params = {}
    params.intensity = 5
    BWOScheduler.Add("Bikers", params, 100)
end

BWOMenu.EventCriminals = function(player)
    local params = {}
    params.intensity = 3
    BWOScheduler.Add("Criminals", params, 100)
end

BWOMenu.EventDream = function(player)
    local params = {}
    params.night = 5
    BWOScheduler.Add("Dream", params, 100)
end

BWOMenu.EventBandits = function(player)
    local params = {}
    params.intensity = 7
    BWOScheduler.Add("Bandits", params, 100)
end

BWOMenu.EventThieves = function(player)
    local params = {}
    params.intensity = 2
    BWOScheduler.Add("Thieves", params, 100)
end

BWOMenu.EventShahids = function(player)
    local params = {}
    params.intensity = 1
    BWOScheduler.Add("Shahids", params, 100)
end

BWOMenu.EventStorm = function(player)
    local params = {}
    params.len = 1440
    BWOScheduler.Add("WeatherStorm", params, 1000)
end



local function getClickedVehicle()
    local sq = BanditCompatibility.GetClickedSquare()
    if not sq then return nil end
    return sq:getVehicleContainer()
end

-- Debug/UI: open data graph
BWOMenu.OpenDataGraph = function(player)
    if BWODataGraphWindow ~= nil and BWODataGraphWindow.Open ~= nil then
        BWODataGraphWindow.Open(player)
    end
end

-- Debug/UI: open population graph (Streets/Inhabitants/Survivors Max)
BWOMenu.OpenPopGraph = function(player)
    if BWOPopGraphWindow ~= nil and BWOPopGraphWindow.Open ~= nil then
        BWOPopGraphWindow.Open(player)
    end
end

BWOMenu.VehicleEngineClient = function(player, on)
    local vehicle = getClickedVehicle()
    if not vehicle then return end
    if on then
        vehicle:setPhysicsActive(true)
        vehicle:setHotwired(true)
        vehicle:tryStartEngine(true)
        vehicle:engineDoStartingSuccess()
        vehicle:engineDoRunning()
    else
        vehicle:setRegulator(false)
        if vehicle.engineDoShuttingDown then
            vehicle:engineDoShuttingDown()
        end
    end
end

BWOMenu.VehicleRegulatorClient = function(player, on)
    local vehicle = getClickedVehicle()
    if not vehicle then return end
    vehicle:setRegulator(on and true or false)
end

BWOMenu.VehicleRegulatorSpeedClient = function(player, speed)
    local vehicle = getClickedVehicle()
    if not vehicle then return end
    vehicle:setRegulatorSpeed(tonumber(speed) or 25)
end

BWOMenu.VehicleHeadlightsClient = function(player, on)
    local vehicle = getClickedVehicle()
    if not vehicle then return end
    vehicle:setHeadlightsOn(on and true or false)
end

BWOMenu.VehicleGoClient = function(player)
    local sq = BanditCompatibility.GetClickedSquare()
    if not sq then return end
    local vehicle = sq:getVehicleContainer()
    if not vehicle then return end

    vehicle:setPhysicsActive(true)
    vehicle:setHotwired(true)
    vehicle:tryStartEngine(true)
    vehicle:engineDoStartingSuccess()
    vehicle:engineDoRunning()

    if not vehicle:getDriver() then
        local square = vehicle:getSquare()
        if square then
            local cell = square:getCell()
            local npcAesthetics = SurvivorFactory.CreateSurvivor(SurvivorType.Neutral, false)
            npcAesthetics:setForename("Driver")
            npcAesthetics:setSurname("Driver")
            npcAesthetics:dressInNamedOutfit("Police")
            local driver = IsoPlayer.new(cell, npcAesthetics, square:getX(), square:getY(), square:getZ())
            driver:setNPC(true)
            driver:setGodMod(true)
            driver:setInvisible(true)
            driver:setGhostMode(true)
            local vxDir = driver:getForwardDirection():getX()
            local vyDir = driver:getForwardDirection():getY()
            local forwardVector = Vector3f.new(vxDir, vyDir, 0)
            if vehicle:getChunk() then
                vehicle:setPassenger(0, driver, forwardVector)
                driver:setVehicle(vehicle)
                driver:setCollidable(false)
            end
        end
    end
    
    vehicle:setRegulator(true)
    vehicle:setRegulatorSpeed(25)
end

BWOMenu.VehicleGoServer = function(player)
    local sq = BanditCompatibility.GetClickedSquare()
    if not sq then return end
    local args = { x = sq:getX(), y = sq:getY(), z = sq:getZ() or 0, speed = 25 }
    sendClientCommand(getSpecificPlayer(0), 'Commands', 'VehicleGo', args)
end

BWOMenu.VehicleEngineServer = function(player, on)
    local sq = BanditCompatibility.GetClickedSquare()
    if not sq then return end
    local args = { x = sq:getX(), y = sq:getY(), z = sq:getZ() or 0, on = on and true or false }
    sendClientCommand(getSpecificPlayer(0), 'Commands', 'VehicleEngine', args)
end

BWOMenu.VehicleRegulatorServer = function(player, on)
    local sq = BanditCompatibility.GetClickedSquare()
    if not sq then return end
    local args = { x = sq:getX(), y = sq:getY(), z = sq:getZ() or 0, on = on and true or false }
    sendClientCommand(getSpecificPlayer(0), 'Commands', 'VehicleRegulator', args)
end

BWOMenu.VehicleRegulatorSpeedServer = function(player, speed)
    local sq = BanditCompatibility.GetClickedSquare()
    if not sq then return end
    local args = { x = sq:getX(), y = sq:getY(), z = sq:getZ() or 0, speed = tonumber(speed) or 25 }
    sendClientCommand(getSpecificPlayer(0), 'Commands', 'VehicleRegulatorSpeed', args)
end

BWOMenu.VehicleHeadlightsServer = function(player, on)
    local sq = BanditCompatibility.GetClickedSquare()
    if not sq then return end
    local args = { x = sq:getX(), y = sq:getY(), z = sq:getZ() or 0, on = on and true or false }
    sendClientCommand(getSpecificPlayer(0), 'Commands', 'VehicleHeadlights', args)
end

function BWOMenu.WorldContextMenuPre(playerID, context, worldobjects, test)

    local player = getSpecificPlayer(playerID)
    local profession = player:getDescriptor():getProfession()
    -- print ("DIR: " .. player:getDirectionAngle())

    local square = BanditCompatibility.GetClickedSquare()

    local zombie = square:getZombie()
    if not zombie then
        local squareS = square:getS()
        if squareS then
            zombie = squareS:getZombie()
            if not zombie then
                local squareW = square:getW()
                if squareW then
                    zombie = squareW:getZombie()
                end
            end
        end
    end

    -- doctor healing
    if zombie and zombie:getVariableBoolean("Bandit") then
        local health = zombie:getHealth()
        if (profession == "doctor" or profession == "nurse") and health < 0.8 or zombie:isCrawling() then
            context:addOption("Heal Person", player, BWOMenu.HealPerson, square, zombie)
        end
    end

    if BanditCompatibility.GetGameVersion() >= 42 then
        if square:getZ() == -16 and square:getX() == 5556 and (square:getY() == 12445 or square:getY() == 12446 or square:getY() == 12447)  then
            context:addOption("Disable Launch Sequence", player, BWOMenu.DisableLaunchSequence, square)
        end
    else
        if square:getZ() == 0 and square:getX() == 5572 and square:getY() == 12486 then
            context:addOption("Disable Launch Sequence", player, BWOMenu.DisableLaunchSequence, square)
        end
    end

    if isDebugEnabled() or isAdmin() then

        local density = BanditScheduler.GetDensityScore(player, 120) * 1.4
        print ("DENSITY: " .. density)

        local density2 = BWOBuildings.GetDensityScore(player, 120) / 6000
        print ("DENSITY2: " .. density2)

        -- player:playSound("197ddd73-7662-41d5-81e0-63b83a58ab60")
        local eventsOption = context:addOption("BWO Event")
        local eventsMenu = context:getNew(context)
        context:addSubMenu(eventsOption, eventsMenu)

        eventsMenu:addOption("Army", player, BWOMenu.EventArmy)
        eventsMenu:addOption("Army Patrol", player, BWOMenu.EventArmyPatrol)
        eventsMenu:addOption("Arson", player, BWOMenu.EventArson)
        eventsMenu:addOption("Bandits", player, BWOMenu.EventBandits)
        eventsMenu:addOption("Bikers", player, BWOMenu.EventBikers)
        eventsMenu:addOption("Bomb Drop", player, BWOMenu.EventBombDrop)
        eventsMenu:addOption("Bomb Run", player, BWOMenu.EventBombRun)
        eventsMenu:addOption("Criminals", player, BWOMenu.EventCriminals)
        eventsMenu:addOption("Dream", player, BWOMenu.EventDream)

        local entertainerOption = eventsMenu:addOption("Entertainer")
        local entertainerMenu = context:getNew(context)
        eventsMenu:addSubMenu(entertainerOption, entertainerMenu)

        entertainerMenu:addOption("Priest", player, BWOMenu.EventEntertainer, 0)
        entertainerMenu:addOption("Guitarist", player, BWOMenu.EventEntertainer, 1)
        entertainerMenu:addOption("Violinist", player, BWOMenu.EventEntertainer, 2)
        entertainerMenu:addOption("Saxophonist", player, BWOMenu.EventEntertainer, 3)
        entertainerMenu:addOption("Breakdancer", player, BWOMenu.EventEntertainer, 4)
        entertainerMenu:addOption("Clown 1", player, BWOMenu.EventEntertainer, 5)
        entertainerMenu:addOption("Clown 2", player, BWOMenu.EventEntertainer, 6)

        eventsMenu:addOption("Final Solution", player, BWOMenu.EventFinalSolution)
        eventsMenu:addOption("Fliers", player, BWOMenu.EventFliers)
        eventsMenu:addOption("Gas Drop", player, BWOMenu.EventGasDrop)
        eventsMenu:addOption("Gas Run", player, BWOMenu.EventGasRun)
        eventsMenu:addOption("House Party", player, BWOMenu.EventParty)
        eventsMenu:addOption("Jetfighter", player, BWOMenu.EventJetFighter)
        eventsMenu:addOption("Jetfighter Run", player, BWOMenu.EventJetFighterRun)
        eventsMenu:addOption("Nuke", player, BWOMenu.EventNuke)
        eventsMenu:addOption("Rolice Riot", player, BWOMenu.EventPoliceRiot)
        eventsMenu:addOption("Power On", player, BWOMenu.EventPower, true)
        eventsMenu:addOption("Power Off", player, BWOMenu.EventPower, false)
        eventsMenu:addOption("Protest", player, BWOMenu.EventProtest)
        eventsMenu:addOption("Reanimate", player, BWOMenu.EventReanimate)
        eventsMenu:addOption("Shahid", player, BWOMenu.EventShahids)
        eventsMenu:addOption("Start", player, BWOMenu.EventStart)
        eventsMenu:addOption("Start Day", player, BWOMenu.EventStartDay)
        eventsMenu:addOption("Storm", player, BWOMenu.EventStorm)
        eventsMenu:addOption("Thieves", player, BWOMenu.EventThieves)
        eventsMenu:addOption("Open Data Graph", player, BWOMenu.OpenDataGraph)
        eventsMenu:addOption("Open Pop Graph", player, BWOMenu.OpenPopGraph)
        
        local spawnOption = context:addOption("BWO Spawn")
        local spawnMenu = context:getNew(context)
        context:addSubMenu(spawnOption, spawnMenu)
        
        spawnMenu:addOption("Babe", player, BWOMenu.SpawnWave, square, "Babe")
        spawnMenu:addOption("Fireman", player, BWOMenu.SpawnWave, square, "Fireman")
        spawnMenu:addOption("Gardener", player, BWOMenu.SpawnWave, square, "Gardener")
        spawnMenu:addOption("Inhabitant", player, BWOMenu.SpawnRoom, square, "Inhabitant")
        spawnMenu:addOption("Janitor", player, BWOMenu.SpawnWave, square, "Janitor")
        spawnMenu:addOption("Medic", player, BWOMenu.SpawnWave, square, "Medic")
        spawnMenu:addOption("Postal", player, BWOMenu.SpawnWave, square, "Postal")
        spawnMenu:addOption("Runner", player, BWOMenu.SpawnWave, square, "Runner")
        spawnMenu:addOption("Shahid", player, BWOMenu.SpawnWave, square, "Shahid")
        spawnMenu:addOption("Survivor", player, BWOMenu.SpawnWave, square, "Survivor")
        spawnMenu:addOption("Vandal", player, BWOMenu.SpawnWave, square, "Vandal")
        spawnMenu:addOption("Walker", player, BWOMenu.SpawnWave, square, "Walker")
        
        context:addOption("BWO Deadbodies: Flush", player, BWOMenu.FlushDeadbodies)
        context:addOption("BWO Test Emitter", player, BWOMenu.TestEmitter, square)

        -- Vehicles admin spawn
        local vehiclesOption = context:addOption("BWO Vehicles")
        local vehiclesMenu = context:getNew(context)
        context:addSubMenu(vehiclesOption, vehiclesMenu)

        local function addVehicleOption(label, script)
            vehiclesMenu:addOption(label, player, function(ply)
                local sq = BanditCompatibility.GetClickedSquare()
                if not sq then return end
                local dir = IsoDirections.S
                BWOCompatibility.AddVehicle(script, dir, sq)
            end)
        end

        addVehicleOption("SmallCar", "Base.SmallCar")
        addVehicleOption("SportsCar", "Base.SportsCar")
        addVehicleOption("SUV", "Base.SUV")
        addVehicleOption("PickUp", "Base.PickUpTruck")
        addVehicleOption("VanAmbulance", "Base.VanAmbulance")

        vehiclesMenu:addOption("Vehicle: Go (Client)", player, BWOMenu.VehicleGoClient)
        vehiclesMenu:addOption("Vehicle: Go (Server)", player, BWOMenu.VehicleGoServer)

        -- Controls submenus
        local controlsClientOption = vehiclesMenu:addOption("Controls (Client)")
        local controlsClientMenu = context:getNew(context)
        vehiclesMenu:addSubMenu(controlsClientOption, controlsClientMenu)
        controlsClientMenu:addOption("Engine ON", player, BWOMenu.VehicleEngineClient, true)
        controlsClientMenu:addOption("Engine OFF", player, BWOMenu.VehicleEngineClient, false)
        controlsClientMenu:addOption("Regulator ON", player, BWOMenu.VehicleRegulatorClient, true)
        controlsClientMenu:addOption("Regulator OFF", player, BWOMenu.VehicleRegulatorClient, false)
        local clientSpeedOption = controlsClientMenu:addOption("Set Speed")
        local clientSpeedMenu = context:getNew(context)
        controlsClientMenu:addSubMenu(clientSpeedOption, clientSpeedMenu)
        clientSpeedMenu:addOption("10", player, BWOMenu.VehicleRegulatorSpeedClient, 10)
        clientSpeedMenu:addOption("25", player, BWOMenu.VehicleRegulatorSpeedClient, 25)
        clientSpeedMenu:addOption("50", player, BWOMenu.VehicleRegulatorSpeedClient, 50)
        controlsClientMenu:addOption("Headlights ON", player, BWOMenu.VehicleHeadlightsClient, true)
        controlsClientMenu:addOption("Headlights OFF", player, BWOMenu.VehicleHeadlightsClient, false)

        local controlsServerOption = vehiclesMenu:addOption("Controls (Server)")
        local controlsServerMenu = context:getNew(context)
        vehiclesMenu:addSubMenu(controlsServerOption, controlsServerMenu)
        controlsServerMenu:addOption("Engine ON", player, BWOMenu.VehicleEngineServer, true)
        controlsServerMenu:addOption("Engine OFF", player, BWOMenu.VehicleEngineServer, false)
        controlsServerMenu:addOption("Regulator ON", player, BWOMenu.VehicleRegulatorServer, true)
        controlsServerMenu:addOption("Regulator OFF", player, BWOMenu.VehicleRegulatorServer, false)
        local serverSpeedOption = controlsServerMenu:addOption("Set Speed")
        local serverSpeedMenu = context:getNew(context)
        controlsServerMenu:addSubMenu(serverSpeedOption, serverSpeedMenu)
        serverSpeedMenu:addOption("10", player, BWOMenu.VehicleRegulatorSpeedServer, 10)
        serverSpeedMenu:addOption("25", player, BWOMenu.VehicleRegulatorSpeedServer, 25)
        serverSpeedMenu:addOption("50", player, BWOMenu.VehicleRegulatorSpeedServer, 50)
        controlsServerMenu:addOption("Headlights ON", player, BWOMenu.VehicleHeadlightsServer, true)
        controlsServerMenu:addOption("Headlights OFF", player, BWOMenu.VehicleHeadlightsServer, false)
        
        local room = square:getRoom()
        if room then
            local bid = room:getBuilding():getID()
            local roomName = room:getName()
            local def = room:getRoomDef()
            local occupantsCnt = BWORooms.GetRoomCurrPop(room)
            local occupantsMax = BWORooms.GetRoomMaxPop(room)
            local roomSize = BWORooms.GetRoomSize(room)
            local popMod = BWORooms.GetRoomPopMod(room)
            print ("ROOM: " .. roomName)
            print ("SIZE: " .. roomSize)
            print ("HOME: " .. tostring(BWOBuildings.IsEventBuilding(room:getBuilding(), "home")))
            print ("POP: " .. occupantsCnt .. "/" .. occupantsMax .. " (" .. popMod .. ")")

        end
    end
end

Events.OnPreFillWorldObjectContextMenu.Add(BWOMenu.WorldContextMenuPre)
