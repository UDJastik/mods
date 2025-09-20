BWOServer = {}
BWOServer.Commands = {}

BWOServer.Commands.ObjectAdd = function(player, args)
    local gmd = GetBWOModData()
    if not (args.x and args.y and args.z and args.otype) then return end

    local id = math.floor(args.x) .. "-" .. math.floor(args.y) .. "-" ..args.z

    if not gmd.Objects[args.otype] then gmd.Objects[args.otype] = {} end
    gmd.Objects[args.otype][id] = args
end

BWOServer.Commands.ObjectRemove = function(player, args)
    local gmd = GetBWOModData()
    if not (args.x and args.y and args.z and args.otype) then return end

    local id = math.floor(args.x) .. "-" .. math.floor(args.y) .. "-" ..args.z
    if not gmd.Objects[args.otype] then gmd.Objects[args.otype] = {} end

    gmd.Objects[args.otype][id] = nil
end

BWOServer.Commands.NukeAdd = function(player, args)
    local gmd = GetBWOModData()
    if not (args.x and args.y and args.r) then return end

    local id = math.floor(args.x) .. "-" .. math.floor(args.y)

    gmd.Nukes[id] = args
end

BWOServer.Commands.NukesDisable = function(player, args)
    local gmd = GetBWOModData()
    if args.confirm then
        gmd.Nukes = {}
    end
end

BWOServer.Commands.EventBuildingAdd = function(player, args)
    local gmd = GetBWOModData()
    if not (args.id and args.event) then return end

    gmd.EventBuildings[args.id] = args
end

BWOServer.Commands.DeadBodyAdd = function(player, args)
    local gmd = GetBWOModData()
    if not (args.x and args.y and args.z) then return end

    local id = math.floor(args.x) .. "-" .. math.floor(args.y) .. "-" ..args.z
    gmd.DeadBodies[id] = args
end

BWOServer.Commands.DeadBodyRemove = function(player, args)
    local gmd = GetBWOModData()
    if not (args.x and args.y and args.z) then return end

    local id = math.floor(args.x) .. "-" .. math.floor(args.y) .. "-" .. args.z
    gmd.DeadBodies[id] = nil
end

BWOServer.Commands.DeadBodyFlush = function(player, args)
    local gmd = GetBWOModData()
    gmd.DeadBodies = {}
    print ("[INFO] All deadbodies info removed!!!")
end

BWOServer.Commands.AddEffect = function(player, args)
    sendServerCommand('BWOEffects', 'Add', args)
end

BWOServer.Commands.ZombieRemove = function(player, args)
    if not args or not args.id then return end

    local cell = getCell()
    if not cell then return end

    local zombieList = cell:getZombieList()
    for i = 0, zombieList:size() - 1 do
        local zombie = zombieList:get(i)
        if zombie and BanditUtils and BanditUtils.GetCharacterID and BanditUtils.GetCharacterID(zombie) == args.id then
            zombie:removeFromWorld()
            zombie:removeFromSquare()
            sendServerCommand('Commands', 'ZombieRemoveClient', { id = args.id })
            return
        end
    end
    -- not found; silently ignore or log if needed
end

-- Remove a vehicle on the server to keep clients in sync
BWOServer.Commands.VehicleRemove = function(player, args)
    if not args then return end

    local cell = getCell()
    if not cell then return end

    local vehicle = nil

    -- Prefer lookup by id if provided
    if args.id then
        local vehicles = cell:getVehicles()
        if vehicles then
            for i = 0, vehicles:size() - 1 do
                local v = vehicles:get(i)
                if v and v:getId() == args.id then
                    vehicle = v
                    break
                end
            end
        end
    end

    -- Fallback: lookup by square position
    if not vehicle and args.x and args.y then
        local square = cell:getGridSquare(args.x, args.y, args.z or 0)
        if square then
            vehicle = square:getVehicleContainer()
        end
    end

    if not vehicle then return end

    -- Disable physics before removing to avoid Bullet errors on clients
    vehicle:setPhysicsActive(false)
    local vid = vehicle:getId()
    local sq = vehicle:getSquare()
    local vx = sq and sq:getX() or args.x
    local vy = sq and sq:getY() or args.y
    local vz = sq and sq:getZ() or (args.z or 0)
    vehicle:permanentlyRemove()

    -- Clean up server-side tracking if used
    if BWOVehicles and BWOVehicles.tab then
        BWOVehicles.tab[vid] = nil
    end

    -- Notify clients to drop any local references immediately (defensive)
    sendServerCommand('Commands', 'VehicleRemoveClient', { id = vid, x = vx, y = vy, z = vz })
end

-- Force vehicle physics and movement on server for a vehicle at x,y,z
BWOServer.Commands.VehicleGo = function(player, args)
    if not args or not args.x or not args.y then return end
    local square = getCell():getGridSquare(args.x, args.y, args.z or 0)
    if not square then return end
    local vehicle = square:getVehicleContainer()
    if not vehicle then return end

    vehicle:setPhysicsActive(true)
    vehicle:setHotwired(true)
    vehicle:tryStartEngine(true)
    vehicle:engineDoStartingSuccess()
    vehicle:engineDoRunning()

    -- Ensure there is an NPC driver attached on server
    if not vehicle:getDriver() then
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

    local speed = tonumber(args.speed) or 25

    vehicle:setRegulator(true)
    vehicle:setRegulatorSpeed(speed)
end

local function getVehicleAt(args)
    if not args or not args.x or not args.y then return nil end
    local square = getCell():getGridSquare(args.x, args.y, args.z or 0)
    if not square then return nil end
    return square:getVehicleContainer()
end

BWOServer.Commands.VehicleEngine = function(player, args)
    local vehicle = getVehicleAt(args)
    if not vehicle then return end
    if args.on then
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

BWOServer.Commands.VehicleRegulator = function(player, args)
    local vehicle = getVehicleAt(args)
    if not vehicle then return end
    vehicle:setRegulator(args.on and true or false)
end

BWOServer.Commands.VehicleRegulatorSpeed = function(player, args)
    local vehicle = getVehicleAt(args)
    if not vehicle then return end
    local speed = tonumber(args.speed) or 25
    vehicle:setRegulatorSpeed(speed)
end

BWOServer.Commands.VehicleHeadlights = function(player, args)
    local vehicle = getVehicleAt(args)
    if not vehicle then return end
    vehicle:setHeadlightsOn(args.on and true or false)
end

-- Spawn a vehicle on the server (authoritative). Accepts args from BWOCompatibility.AddVehicle on client.
BWOServer.Commands.SpawnVehicle = function(player, args)
    if not args or not args.script or not args.x or not args.y then return end
    local square = getCell():getGridSquare(args.x, args.y, args.z or 0)
    if not square then return end

    local dir = IsoDirections.S
    if args.dir == "N" then dir = IsoDirections.N
    elseif args.dir == "S" then dir = IsoDirections.S
    elseif args.dir == "E" then dir = IsoDirections.E
    elseif args.dir == "W" then dir = IsoDirections.W end

    local vehicle = addVehicleDebug(args.script, dir, nil, square)
    if not vehicle then return end

    for i = 0, vehicle:getPartCount() - 1 do
        local container = vehicle:getPartByIndex(i):getItemContainer()
        if container then container:removeAllItems() end
    end

    local md = vehicle:getModData()
    md.BWO = md.BWO or {}
    md.BWO.wasRepaired = args.wasRepaired or true
    md.BWO.dir = args.dir or "S"
    md.BWO.autonomous = args.autonomous and true or false

    if args.generalPartCondition then
        local g = args.generalPartCondition
        if type(g) == 'table' and g.min and g.max then
            vehicle:setGeneralPartCondition(ZombRand(g.min, g.max+1), 80)
        elseif type(g) == 'number' then
            vehicle:setGeneralPartCondition(g, 80)
        end
    else
        vehicle:setGeneralPartCondition(100, 80)
    end

    if args.randomColor then
        vehicle:setColor(ZombRandFloat(0, 1), ZombRandFloat(0, 1), ZombRandFloat(0, 1))
    elseif args.color then
        vehicle:setColor(args.color.r or 1, args.color.g or 1, args.color.b or 1)
    end

    if args.headlightsOn then vehicle:setHeadlightsOn(true) end
    if args.alarmed ~= nil then vehicle:setAlarmed(args.alarmed) end

    -- physics will be activated by engine once clients load the vehicle
    -- engine start disabled for spawned vehicles

    -- If requested, register for autonomous control so server will attach NPC driver
    if args.autonomous then
        if BWOVehicles and BWOVehicles.Register then
            BWOVehicles.Register(vehicle)
        end
        -- NPC driver attach and engine start are disabled for spawned vehicles
    end
end

BWOServer.Commands.Nuke = function(player, args)
    local player = getSpecificPlayer(0)
    local cell = player:getCell()
    local px = args.x
    local py = args.y
    local r = args.r

    for z=0, 7 do
        for y=-r, r do
            for x=-r, r do
                local bx = px + x
                local by = py + y
                local dist = math.sqrt(math.pow(bx - px, 2) + math.pow(by - py, 2))
                if dist < r then
                    local square = cell:getGridSquare(bx, by, z)
                    if square then
                        BWOSquareLoader.Burn(square)

                        local vehicle = square:getVehicleContainer()
                        if vehicle then
                            BWOVehicles.Burn(vehicle)
                        end
                    end
                end
            end
        end
    end
end

-- main
local onClientCommand = function(module, command, player, args)
    if BWOServer[module] and BWOServer[module][command] then
        local argStr = ""
        for k, v in pairs(args) do
            argStr = argStr .. " " .. k .. "=" .. tostring(v)
        end
        print ("received " .. module .. "." .. command .. " "  .. argStr)
        BWOServer[module][command](player, args)

        if module == "Commands" then
            TransmitBWOModData()
        end
    end
end

-- gc for objects with set ttl
local everyOneMinute = function()
    local toRemove = {}
    local gmd = GetBWOModData()
    for k, obj in pairs(gmd.Objects) do
        if obj.ttl then
            if BanditUtils.GetTime() > obj.ttl then
                table.insert(toRemove, k)
            end
        end
    end

    for _, k in pairs(toRemove) do
        gmd.Objects[k] = nil
    end
end

Events.OnClientCommand.Add(onClientCommand)
Events.EveryOneMinute.Add(everyOneMinute)
