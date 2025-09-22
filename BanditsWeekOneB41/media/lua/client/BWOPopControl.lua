BWOPopControl = BWOPopControl or {}

-- population control
BWOPopControl.ZombieMax = 0
BWOPopControl.ZombieCnt = 1000

BWOPopControl.SurvivorsCnt = 0
BWOPopControl.SurvivorsNominal = 0
BWOPopControl.SurvivorsMax = 0

BWOPopControl.InhabitantsCnt = 0
BWOPopControl.InhabitantsNominal = 0 
BWOPopControl.InhabitantsMax = 0

BWOPopControl.StreetsCnt = 0
BWOPopControl.StreetsNominal = 0
BWOPopControl.StreetsMax = 0

-- emergency services control
BWOPopControl.Police = {} 
BWOPopControl.Police.Cooldown = 0
BWOPopControl.Police.On = true

BWOPopControl.SWAT = {} 
BWOPopControl.SWAT.Cooldown = 0
BWOPopControl.SWAT.On = true

BWOPopControl.Security = {}
BWOPopControl.Security.Cooldown = 0
BWOPopControl.Security.On = true

BWOPopControl.Medics = {}
BWOPopControl.Medics.Cooldown = 0
BWOPopControl.Medics.On = true

BWOPopControl.Hazmats = {}
BWOPopControl.Hazmats.Cooldown = 0
BWOPopControl.Hazmats.On = true

BWOPopControl.Fireman = {} 
BWOPopControl.Fireman.Cooldown = 0
BWOPopControl.Fireman.On = true

local function countQueueByPrograms(programSet)
	local gmd = GetBanditModData()
	local count = 0
	if gmd and gmd.Queue then
		for _, brain in pairs(gmd.Queue) do
			local prg = brain and brain.program and brain.program.name
			if prg and programSet[prg] then
				count = count + 1
			end
		end
	end
	return count
end

local streetPrograms = {
    Walker = true, Runner = true, Postal = true,
    Gardener = true, Janitor = true, Entertainer = true, Vandal = true
}

local inhabitantPrograms = {
    Inhabitant = true, 
    Medic = true, Janitor = true, Entertainer = true
}
local survivorPrograms = {
    Survivor = true
}
function everyOneHour()
    local player = getPlayer() 
    if not player then return end
    local cell = player:getCell()
    local zombieList = cell:getZombieList()
    local cnt = countQueueByPrograms(streetPrograms)
    local cnt2 = countQueueByPrograms(inhabitantPrograms)
    local cnt3 = countQueueByPrograms(survivorPrograms)
    
    -- validate mod data
    local gmd = GetBanditModData()
    if not gmd or not gmd.Queue then return end

    -- build a combined program filter of interest
    local allowedPrograms = {}
    for k, v in pairs(streetPrograms) do if v then allowedPrograms[k] = true end end
    for k, v in pairs(inhabitantPrograms) do if v then allowedPrograms[k] = true end end
    for k, v in pairs(survivorPrograms) do if v then allowedPrograms[k] = true end end

    -- collect real nearby bandits with allowed programs
    local nearIds = {}
    local nearCnt = 0
    local banditList = BanditZombie.GetAllB and BanditZombie.GetAllB() or {}
    for id, light in pairs(banditList) do
        local brain = light and light.brain
        local prg = brain and brain.program and brain.program.name
        if prg and allowedPrograms[prg] then
            nearIds[id] = true
            nearCnt = nearCnt + 1
        end
    end

    -- compare against queue and prepare removal for those not near the player
    local queueCnt = 0
    local removeIds = {}
    for id, brain in pairs(gmd.Queue) do
        local prg = brain and brain.program and brain.program.name
        if prg and allowedPrograms[prg] then
            queueCnt = queueCnt + 1
            if not nearIds[id] then
                table.insert(removeIds, id)
            end
        end
    end

    -- if the numbers differ, clean up queue entries that have no nearby instance
    if queueCnt ~= nearCnt and #removeIds > 0 then
        sendClientCommand(player, 'Commands', 'BanditRemoveBatch', { ids = removeIds })
    end
end
-- zombie despawner
BWOPopControl.Zombie = function()
    if BWOPopControl.ZombieMax >= 400 then return end
    local gmd = GetBanditModData()
    local player = getPlayer()
    local zombieList = BanditZombie.GetAllZ()
    local cnt = 0
    BWOPopControl.ZombieCnt = 0
    local removeIds = {}
    for id, z in pairs(zombieList) do
        cnt = cnt + 1
        local test = BWOPopControl
        if cnt > BWOPopControl.ZombieMax then
            local zombie = BanditZombie.GetInstanceById(z.id)
            -- local id = BanditUtils.GetCharacterID(zombie)
            if zombie and zombie:isAlive() and not gmd.Queue[z.id] then
                -- fixme: zombie:canBeDeletedUnnoticed(float)
                args = {}
                args.id = z.id
                zombie:removeFromSquare()
                zombie:removeFromWorld()
                table.insert(removeIds, z.id)
            end
        else
            BWOPopControl.ZombieCnt = BWOPopControl.ZombieCnt + 1
        end
    end
    if player and #removeIds > 0 then
        sendClientCommand(player, 'Commands', 'ZombieRemoveBatch', { ids = removeIds })
        sendClientCommand(player, 'Commands', 'BanditRemoveBatch', { ids = removeIds })
    end
end

-- npc on streets spawner
BWOPopControl.StreetsSpawn = function(cnt)
    local player = getPlayer()
    if not player then return end
    local cell = player:getCell()
    local px, py = player:getX(), player:getY()
    local cm = getWorld():getClimateManager()
    local rainIntensity = cm:getRainIntensity()

    local events = {}

    for i = 1, cnt do
        local x = 10 + ZombRand(10)
        local y = 10 + ZombRand(10)
        
        if ZombRand(2) == 1 then x = -x end
        if ZombRand(2) == 1 then y = -y end

        local square = cell:getGridSquare(px + x, py + y, 0)
        if square then
            if square:isOutside() and not BWOSquareLoader.IsInExclusion(square:getX(), square:getY()) then
                local groundType = BanditUtils.GetGroundType(square) 
                if groundType == "street" then
                    config = {}
                    config.clanId = 0
                    config.hasRifleChance = 0
                    config.hasPistolChance = SandboxVars.BanditsWeekOne.StreetsPistolChance
                    config.rifleMagCount = 0
                    config.pistolMagCount = 1
                
                    local event = {}
                    event.x = square:getX()
                    event.y = square:getY()
                    event.hostile = false
                    event.occured = false
                    event.program = {}
                    event.program.name = "Walker"
                    event.program.stage = "Prepare"
                    event.bandits = {}
                
                    local bandit
                    local rnd = ZombRand(100)
                    if rnd < 4 then
                        bandit = BanditCreator.MakeFromWave(config)
                        bandit.weapons.melee = "Base.BareHands"
                        bandit.outfit = BanditUtils.Choice({"StreetSports"})
                        event.program.name = "Runner"
                        event.program.stage = "Prepare"
                    elseif rnd < 8 then 
                        bandit = BanditCreator.MakeFromWave(config)
                        bandit.weapons.melee = "Base.BareHands"
                        bandit.outfit = BanditUtils.Choice({"Postal"})
                        event.program.name = "Postal"
                        event.program.stage = "Prepare"
                    elseif rnd < 13 then 
                        bandit = BanditCreator.MakeFromWave(config)
                        bandit.weapons.melee = "Base.BareHands"
                        bandit.outfit = BanditUtils.Choice({"Farmer"})
                        event.program.name = "Gardener"
                        event.program.stage = "Prepare"
                    elseif rnd < 16 then 
                        bandit = BanditCreator.MakeFromWave(config)
                        bandit.weapons.melee = "Base.BareHands"
                        bandit.outfit = BanditUtils.Choice({"Sanitation"})
                        bandit.weapons.melee = "Base.Broom"
                        event.program.name = "Janitor"
                        event.program.stage = "Prepare"
                    elseif rnd < 17 then 
                        -- config.clanId = 0
                        bandit = BanditCreator.MakeFromWave(config)
                        bandit.weapons.melee = "Base.BareHands"
                        bandit.outfit = BanditUtils.Choice({"Bandit"})
                        bandit.weapons.melee = "Base.Crowbar"
                        event.program.name = "Vandal"
                        event.program.stage = "Prepare"
                    else
                        bandit = BanditCreator.MakeFromWave(config)
                        bandit.weapons.melee = "Base.BareHands"
                        if rainIntensity > 0.02 then
                            bandit.outfit = BanditUtils.Choice({"BWORainGeneric01", "BWORainGeneric02", "BWORainGeneric03"})
                        else
                            bandit.outfit = BanditUtils.Choice({"Generic05", "Generic04", "Generic03", "Generic02", "Generic01",
                                                                "BWOCow", "BWOYoung", "BWOLeather", "BWOFormal"})
                        end

                        event.program.name = "Walker"
                        event.program.stage = "Prepare"

                    end
                    
                    table.insert(event.bandits, bandit)
                    table.insert(events, event)
                end
            end
        end
    end

    if #events > 0 then
        sendClientCommand(player, 'Commands', 'SpawnGroupBatch', { events = events })
    end
end

-- npc on streets despawner
	BWOPopControl.StreetsDespawn = function(cnt,always)
    local player = getPlayer()
    if not player then return end
    local cell = player:getCell()
		local vehicle = player:getVehicle()
		local px, py = player:getX(), player:getY()
		if vehicle then px, py = vehicle:getX(), vehicle:getY() end

    local removePrg = {"Walker", "Runner", "Postal", "Entertainer", "Janitor", "Gardener", "Vandal"}
    local zombieList = BanditUtils.GetAllBanditByProgram(removePrg)

		local removeIds = {}
		local i = 0
		for k, zombie in pairs(zombieList) do
        local zx = zombie.x
        local zy = zombie.y
        local dist = BanditUtils.DistTo(px, py, zx, zy)
			if dist > 50 then
				local zombieObj = BanditZombie.GetInstanceById(zombie.id)
				if zombieObj then
					zombieObj:removeFromSquare()
					zombieObj:removeFromWorld()
					table.insert(removeIds, zombie.id)
				end
            i = i + 1
            if i >= cnt and not always then break end
        end
    end
    if #removeIds > 0 then
        sendClientCommand(player, 'Commands', 'BanditRemoveBatch', { ids = removeIds })
    end
end

-- npcs in buildings spawner
BWOPopControl.InhabitantsSpawn = function(cnt)

    local ts = getTimestampMs()

    local event = {}
    event.hostile = false
    event.occured = false
    event.program = {}
    event.program.name = "Inhabitant"
    event.program.stage = "Prepare"

    local events = {}
    

    local player = getPlayer()
    if not player then return end
    local cell = player:getCell()
    local px, py = player:getX(), player:getY()
    local rooms = cell:getRoomList()    

    -- the probability of spawn in a room will depend on room size and other factors
    local cursor = 0
    local roomPool = {}
    for i = 0, rooms:size() - 1 do
        local room = rooms:get(i)
        local def = room:getRoomDef()

        if def then
            local building = room:getBuilding()
            local buildingDef = building:getDef()
            buildingDef:setAlarmed(false)
            
            if not BWOBuildings.IsEventBuilding(building, "home") and not BWOBuildings.IsRecentlyVisited(building) then
                
                if def:getZ() >=0 and math.abs(def:getX() - player:getX()) < 100 and math.abs(def:getX2() - player:getX()) < 100 and 
                math.abs(def:getY() - player:getY()) < 100 and math.abs(def:getY2() - player:getY()) < 100 then

                    local roomSize = BWORooms.GetRoomSize(room)
                    local popMod = 1 -- lags: BWORooms.GetRoomPopMod(room)
                    if popMod > 0 then
                        local cursorStart = cursor
                        cursor = cursor + math.floor(roomSize ^ 1.2)
                        table.insert(roomPool, {room=room, cursorStart=cursorStart, cursorEnd=cursor})
                    end
                end
                
            end
            
        end
    end

    -- now spawn
    for i = 1, cnt do
        local rnd = ZombRand(cursor)
        for _, rp in pairs(roomPool) do
            if rnd >= rp.cursorStart and rnd < rp.cursorEnd then
                local spawnRoom = rp.room

                local occupantsCnt = BWORooms.GetRoomCurrPop(rp.room)
                local occupantsMax = BWORooms.GetRoomMaxPop(rp.room)

                if occupantsCnt < occupantsMax then

                    local spawnRoomDef = spawnRoom:getRoomDef()
                    if spawnRoomDef then
                        local spawnSquare = spawnRoomDef:getFreeSquare()
                        if spawnSquare and not spawnSquare:getZombie() and not spawnSquare:isOutside() and spawnSquare:isFree(false) and not BWOSquareLoader.IsInExclusion(spawnSquare:getX(), spawnSquare:getY()) then
                            event.x = spawnSquare:getX()
                            event.y = spawnSquare:getY()
                            event.z = spawnSquare:getZ()
                            local dist = BanditUtils.DistTo(px, py, event.x, event.y)
                            if dist > 10 and dist < 30 then
                                event.bandits = {}
                                local bandit = BanditCreator.MakeFromRoom(spawnRoom)
                                if bandit then
                                    table.insert(event.bandits, bandit)
                                    local ev = {
                                        x = event.x,
                                        y = event.y,
                                        z = event.z,
                                        hostile = event.hostile,
                                        occured = event.occured,
                                        program = { name = event.program.name, stage = event.program.stage },
                                        bandits = event.bandits
                                    }
                                    table.insert(events, ev)
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- print ("--------------- IS: " .. getTimestampMs() - ts)
end

-- npcs in buildings despawner
	BWOPopControl.InhabitantsDespawn = function(cnt,always)
    local player = getPlayer()
    if not player then return end
    local cell = player:getCell()
		local vehicle = player:getVehicle()
		local px, py = player:getX(), player:getY()
		if vehicle then px, py = vehicle:getX(), vehicle:getY() end

    local removePrg = {"Inhabitant", "Janitor", "Entertainer"}
    local zombieList = BanditUtils.GetAllBanditByProgram(removePrg)
		local removeIds = {}
		local i = 0
		for k, zombie in pairs(zombieList) do
        local zx = zombie.x
        local zy = zombie.y
        local dist = BanditUtils.DistTo(px, py, zx, zy)
			if dist > 50 then
				local zombieObj = BanditZombie.GetInstanceById(zombie.id)
				if zombieObj then
					zombieObj:removeFromSquare()
					zombieObj:removeFromWorld()
					table.insert(removeIds, zombie.id)
				end
            i = i + 1
            if i >= cnt and not always then break end
        end
    end
    if #removeIds > 0 then
        sendClientCommand(player, 'Commands', 'BanditRemoveBatch', { ids = removeIds })
    end
end

-- survivors spawner
BWOPopControl.SurvivorsSpawn = function(missing)

    -- anchor chosen per-iteration for fairer MP distribution

    config = {}
    config.clanId = 0
    config.hasRifleChance = 0
    config.hasPistolChance = 30
    config.rifleMagCount = 0
    config.pistolMagCount = 2

    local event = {}
    event.hostile = false
    event.occured = false
    event.program = {}
    event.program.name = "Survivor"
    event.program.stage = "Prepare"

    local events = {}

    for i=1, missing do
        local player = getPlayer()
        if not player then break end
        local spawnPoint = BanditScheduler.GenerateSpawnPoint(player, ZombRand(10,25))
        if spawnPoint then
            event.x = spawnPoint.x
            event.y = spawnPoint.y
            event.bandits = {}

            local bandit = BanditCreator.MakeFromWave(config)
            table.insert(event.bandits, bandit)

            local ev = {
                x = event.x,
                y = event.y,
                hostile = event.hostile,
                occured = event.occured,
                program = { name = event.program.name, stage = event.program.stage },
                bandits = event.bandits
            }
            table.insert(events, ev)

        end
    end

    local playerForSend = getPlayer()
    if playerForSend and #events > 0 then
        sendClientCommand(playerForSend, 'Commands', 'SpawnGroupBatch', { events = events })
    end
end

-- survivors despawner
	BWOPopControl.SurvivorsDespawn = function(cnt,always)
    local player = getPlayer()
    if not player then return end
    local cell = player:getCell()
		local vehicle = player:getVehicle()
		local px, py = player:getX(), player:getY()
		if vehicle then px, py = vehicle:getX(), vehicle:getY() end

    local removePrg = {"Survivor"}
    local zombieList = BanditUtils.GetAllBanditByProgram(removePrg)
		local removeIds = {}
		local i = 0
		for k, zombie in pairs(zombieList) do
        local zx = zombie.x
        local zy = zombie.y
        local dist = BanditUtils.DistTo(px, py, zx, zy)
			if dist > 50 then
				local zombieObj = BanditZombie.GetInstanceById(zombie.id)
				if zombieObj then
					zombieObj:removeFromSquare()
					zombieObj:removeFromWorld()
					table.insert(removeIds, zombie.id)
				end
            i = i + 1
            if i >= cnt and not always then break end
        end
    end
    if #removeIds > 0 then
        sendClientCommand(player, 'Commands', 'BanditRemoveBatch', { ids = removeIds })
    end
end

-- controls numbers of overall populations and inits spawn / despawn procedures for various groups when necessary
BWOPopControl.UpdateCivs = function()
    if isServer() then return end

    local function getHourScore()
        local hmap = { [0]=0.20,
            0.15, 0.10, 0.05, 0.05, 0.35, 0.85, 1.20, 1.20,
            1.00, 1.00, 0.80, 0.80, 0.80, 0.80, 1.0, 1.2,
            1.2, 1.0, 1.0, 1.0, 0.9, 0.7, 0.4 }

        local gameTime = getGameTime()
        local hour = gameTime:getHour()
        return hmap[hour]
    end

    local player = getPlayer()
    if not player then return end
    local px = player:getX()
    local py = player:getY()

    -- gather civ stats
    local cell = getCell()
    local zombieList = cell:getZombieList()

    local totalb = 0 -- all civs
    local totalz = 0 -- all zeds

    local tab = {}
    tab.Active = 0
    tab.ArmyGuard = 0
    tab.Bandit = 0
    tab.Entertainer = 0
    tab.Fireman = 0
    tab.Gardener = 0
    tab.Inhabitant = 0
    tab.Janitor = 0
    tab.Medic = 0
    tab.Police = 0
    tab.Postal = 0
    tab.RiotPolice = 0
    tab.Runner = 0
    tab.Survivor = 0
    tab.Vandal = 0
    tab.Walker = 0

    for i = 0, zombieList:size() - 1 do
        local zombie = zombieList:get(i)
        local zx = zombie:getX()
        local zy = zombie:getY()
        local dist = BanditUtils.DistTo(px, py, zx, zy)
        if zombie:getVariableBoolean("Bandit") then
            local brain = BanditBrain.Get(zombie)
            local prg = brain.program.name
            if tab[prg] then
                tab[prg] = tab[prg] + 1
            else
                tab[prg] = 1
            end
        else
            totalz = totalz + 1
        end
    end

    -- ADJUST cooldowns 
    if BWOPopControl.Police.Cooldown > 0 then
        BWOPopControl.Police.Cooldown = BWOPopControl.Police.Cooldown - 1
    end
    if BWOPopControl.SWAT.Cooldown > 0 then
        BWOPopControl.SWAT.Cooldown = BWOPopControl.SWAT.Cooldown - 1
    end
    if BWOPopControl.Security.Cooldown > 0 then
        BWOPopControl.Security.Cooldown = BWOPopControl.Security.Cooldown - 1
    end
    if BWOPopControl.Medics.Cooldown > 0 then
        BWOPopControl.Medics.Cooldown = BWOPopControl.Medics.Cooldown - 1
    end

    -- ADJUST: population nominals
    BWOPopControl.ZombieMax = 0
    BWOPopControl.StreetsNominal = 41
    BWOPopControl.InhabitantsNominal = 100
    BWOPopControl.SurvivorsNominal = 0

    if BWOScheduler.WorldAge == 83 then -- occasional zombies
        BWOPopControl.ZombieMax = 1
    elseif BWOScheduler.WorldAge == 86 then -- occasional zombies
        BWOPopControl.ZombieMax = 1
    elseif BWOScheduler.WorldAge >= 91 and BWOScheduler.WorldAge < 94 then -- occasional zombies
        BWOPopControl.ZombieMax = 2
    elseif BWOScheduler.WorldAge >= 105 and BWOScheduler.WorldAge < 108 then -- occasional zombies
        BWOPopControl.ZombieMax = 3
    elseif BWOScheduler.WorldAge >= 114 and BWOScheduler.WorldAge < 117 then -- occasional zombies
        BWOPopControl.ZombieMax = 3
    elseif BWOScheduler.WorldAge >= 120 and BWOScheduler.WorldAge < 128 then -- occasional zombies
        BWOPopControl.ZombieMax = 8
    elseif BWOScheduler.WorldAge == 128  then -- outbreak
        BWOPopControl.ZombieMax = 70
        BWOPopControl.StreetsNominal = 45
        BWOPopControl.InhabitantsNominal = 50
    elseif BWOScheduler.WorldAge == 129 then 
        BWOPopControl.ZombieMax = 70
        BWOPopControl.StreetsNominal = 50
        BWOPopControl.InhabitantsNominal = 40
        BWOPopControl.SurvivorsNominal = 2
    elseif BWOScheduler.WorldAge == 130 then
        BWOPopControl.ZombieMax = 70
        BWOPopControl.StreetsNominal = 55
        BWOPopControl.InhabitantsNominal = 30
        BWOPopControl.SurvivorsNominal = 3
    elseif BWOScheduler.WorldAge == 131 then
        BWOPopControl.ZombieMax = 70
        BWOPopControl.StreetsNominal = 60
        BWOPopControl.InhabitantsNominal = 15
        BWOPopControl.SurvivorsNominal = 5
    elseif BWOScheduler.WorldAge == 132 then
        BWOPopControl.ZombieMax = 70
        BWOPopControl.StreetsNominal = 55
        BWOPopControl.InhabitantsNominal = 15
        BWOPopControl.SurvivorsNominal = 8
    elseif BWOScheduler.WorldAge >= 133 and BWOScheduler.WorldAge < 170 then
        BWOPopControl.ZombieMax = 1000
        BWOPopControl.InhabitantsNominal = 4
        BWOPopControl.StreetsNominal = 1
        BWOPopControl.SurvivorsNominal = 6
    elseif BWOScheduler.WorldAge >= 169 then
        BWOPopControl.ZombieMax = 1000
        BWOPopControl.SurvivorsNominal = 0
        BWOPopControl.InhabitantsNominal = 0
        BWOPopControl.StreetsNominal = 0
    end
    

    -- ADJUST: people on the streets
    -- count currently active civs
    BWOPopControl.StreetsCnt = countQueueByPrograms(streetPrograms)
    -- count desired population of civs
    local nominal = BWOPopControl.StreetsNominal
    -- local density = BanditScheduler.GetDensityScore(player, 120) * 1.4
    local density = BWOBuildings.GetDensityScore(player, 120) / 8000
    if density > 2.5 then density = 2.5 end
    local hourmod = getHourScore()
    local pop = nominal * density * hourmod * SandboxVars.BanditsWeekOne.StreetsPopMultiplier
    BWOPopControl.StreetsMax = pop

    -- count missing amount to spawn
    local missing = BWOPopControl.StreetsMax - BWOPopControl.StreetsCnt
    local capStreets = math.floor(20)
    if capStreets < 1 then capStreets = 1 end
    if missing > capStreets then missing = capStreets end
    if missing > 0 then
        BWOPopControl.StreetsSpawn(missing)
    elseif missing < 0 then
        local surplus = -missing
        BWOPopControl.StreetsDespawn(surplus,false)
    BWOPopControl.StreetsDespawn(0,true)    -- always despawn all streets
    end

    -- ADJUST: inhabitants (civs in buildings)

    -- count currently active civs
    BWOPopControl.InhabitantsCnt = countQueueByPrograms(inhabitantPrograms)

    -- count desired population of civs
    local nominal = BWOPopControl.InhabitantsNominal
    -- local density = BanditScheduler.GetDensityScore(player, 120) * 1.2
    BWOPopControl.InhabitantsMax = nominal * SandboxVars.BanditsWeekOne.InhabitantsPopMultiplier

    -- count missing amount to spawn
    local missing = BWOPopControl.InhabitantsMax - BWOPopControl.InhabitantsCnt
    local capInhab = math.floor(20)
    if capInhab < 1 then capInhab = 1 end
    if missing > capInhab then missing = capInhab end
    if missing > 0 then
        BWOPopControl.InhabitantsSpawn(missing)
    elseif missing < 0 then
        local surplus = -missing
        BWOPopControl.InhabitantsDespawn(surplus,false)
    BWOPopControl.InhabitantsDespawn(0,true)    -- always despawn all inhabitants
    end
    
    -- ADJUST: survivors (first organized immune civs)
    -- count currently active civs
    BWOPopControl.SurvivorsCnt = countQueueByPrograms(survivorPrograms)

    -- count desired population of civs
    local nominal = BWOPopControl.SurvivorsNominal
    BWOPopControl.SurvivorsMax = math.max(1, math.floor(nominal))

    -- count missing amount to spawn
    local missing = BWOPopControl.SurvivorsMax - BWOPopControl.SurvivorsCnt
    local capSurv = math.floor(4)
    if capSurv < 1 then capSurv = 1 end
    if missing > capSurv then missing = capSurv end
    if missing > 0 then
        BWOPopControl.SurvivorsSpawn(missing)
    elseif missing < 0 then
        local surplus = -missing
        BWOPopControl.SurvivorsDespawn(surplus,false)
    BWOPopControl.SurvivorsDespawn(0,true)    -- always despawn all survivors
    end

    -- debug report:
        print ("----------- POPULATION STATS -----------")
        print ("WORLD AGE: " .. BWOScheduler.WorldAge .. "(" .. ((BWOScheduler.WorldAge+9) * 60) .. ")" .. " SYMPTOM LVL:" .. BWOScheduler.SymptomLevel)
        print ("INHAB: " .. BWOPopControl.InhabitantsCnt .. "/" .. BWOPopControl.InhabitantsMax)
        print ("STREET: " .. BWOPopControl.StreetsCnt .. "/" .. BWOPopControl.StreetsMax)
        print ("SURVIVOR: " .. BWOPopControl.SurvivorsCnt .. "/" .. BWOPopControl.SurvivorsMax)
        print ("ZOMBIE: " .. totalz .. "/" .. BWOPopControl.ZombieMax)
        print ("DENSITY SCORE:" .. density)
        print ("----------------------------------------")

end

local everyOneMinute = function()
    BWOPopControl.UpdateCivs()
end

local onTick = function(numTicks)
    
    if numTicks % 4 == 0 then
        BWOPopControl.Zombie()
    end
end

local OnBanditUpdate = function(bandit)

    local isInCircle = function(x, y, cx, cy, r)
        local d2 = (x - cx) ^ 2 + (y - cy) ^ 2
        return d2 <= r ^ 2
    end

    if not bandit:getVariableBoolean("Bandit") then return end

    if BWOScheduler.World.PostNuclearFallout then
        local outfit = bandit:getOutfitName()
        local gmd = GetBWOModData()
        local nukes = gmd.Nukes
        for _, nuke in pairs(nukes) do
            if isInCircle(bandit:getX(), bandit:getY(), nuke.x, nuke.y, nuke.r) then
                if bandit:getZ() >= 0 and outfit ~= "HazardSuit" then
                    if bandit:isOutside() then
                        bandit:setHealth(bandit:getHealth() - 0.0020)
                    else
                        bandit:setHealth(bandit:getHealth() - 0.0010)
                    end
                end
                break
            end
        end
    end
end

Events.EveryOneMinute.Add(everyOneMinute)
Events.EveryOneHour.Add(everyOneHour)
Events.OnTick.Add(onTick)
Events.OnZombieUpdate.Add(OnBanditUpdate)