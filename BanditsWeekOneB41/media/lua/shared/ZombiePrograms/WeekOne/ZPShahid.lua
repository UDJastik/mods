ZombiePrograms = ZombiePrograms or {}

ZombiePrograms.Shahid = {}
ZombiePrograms.Shahid.Stages = {}

ZombiePrograms.Shahid.Init = function(bandit)
end

ZombiePrograms.Shahid.GetCapabilities = function()
    -- capabilities are program decided
    local capabilities = {}
    capabilities.melee = true
    capabilities.shoot = true
    capabilities.smashWindow = true
    capabilities.openDoor = true
    capabilities.breakDoor = true
    capabilities.breakObjects = true
    capabilities.unbarricade = true
    capabilities.disableGenerators = false
    capabilities.sabotageCars = false
    return capabilities
end

ZombiePrograms.Shahid.Prepare = function(bandit)
    local tasks = {}
    local world = getWorld()
    local cell = getCell()
    local cm = world:getClimateManager()
    local dls = cm:getDayLightStrength()
    local id = BanditUtils.GetCharacterID(bandit)
    local weapons = Bandit.GetWeapons(bandit)

    if math.abs(id) % 13 == 0 and not bandit:isFemale() then
        local brain = BanditBrain.Get(bandit)
        brain.bag = "Briefcase"
        local fakeItem = BanditCompatibility.InstanceItem("Base.Briefcase")
        --local fakeItem = BanditCompatibility.InstanceItem("Base.Briefcase")
        --local fakeItem = BanditCompatibility.InstanceItem("Base.Flightcase")
        --local fakeItem = BanditCompatibility.InstanceItem("Base.Cooler")
        bandit:setPrimaryHandItem(fakeItem)
    elseif math.abs(id) % 5 == 0 and bandit:isFemale() then
        weapons.melee = "Base.PurseWeapon"
        local task = {action="Equip", itemPrimary=weapons.melee}
        table.insert(tasks, task)
    end

    Bandit.ForceStationary(bandit, false)

    return {status=true, next="Main", tasks=tasks}
end

ZombiePrograms.Shahid.Main = function(bandit)
    local tasks = {}
    local health = bandit:getHealth()

    local endurance = 0
    local walkType = "Run"

    local brain = BanditBrain.Get(bandit)
    local cx = brain.bornCoords.x
    local cy = brain.bornCoords.y
    local x
    local y

    local zombieList = BanditZombie.GetAll()
    local cntMax = 4
    for by=-6, 6 do
        for bx=-6, 6 do
            local y1 = cy + by * 10 - 5
            local y2 = cy + by * 10 + 5
            local x1 = cx + bx * 10 - 5
            local x2 = cx + bx * 10 + 5
            
            local cnt = 0
            local killList = {}
            for id, zombie in pairs(zombieList) do
                if zombie.x >= x1 and zombie.x < x2 and zombie.y >= y1 and zombie.y < y2 then
                    cnt = cnt + 1
                end
            end
            if cnt > cntMax then
                x = x1 + 5
                y = y1 + 5
                cntMax = cnt
            end
        end
    end

    if x and y then
        -- print ("X: " .. x .. " Y: " .. y .. " M:" .. cntMax)
        local dist = BanditUtils.DistTo(bandit:getX(), bandit:getY(), x, y)
        if dist > 4 then
            if dist < 6 then Bandit.Say(bandit, "DRAGDOWN") end
            bandit:addLineChatElement("I will not become one of them!", 1, 0, 0)
            table.insert(tasks, BanditUtils.GetMoveTask(endurance, x, y, 0, walkType, 12, false))
            return {status=true, next="Main", tasks=tasks}
        else
            BWOEvents.Explode(bandit:getX(), bandit:getY())
            return {status=true, next="Main", tasks=tasks}
        end
        
    end

    local closestPlayer = BanditUtils.GetClosestPlayerLocation(bandit)

    if closestPlayer.x and closestPlayer.y and closestPlayer.z then
        
        -- calculate random escape direction
        local deltaX = 100 + ZombRand(100)
        local deltaY = 100 + ZombRand(100)

        local rx = ZombRand(2)
        local ry = ZombRand(2)
        if rx == 1 then deltaX = -deltaX end
        if ry == 1 then deltaY = -deltaY end

        table.insert(tasks, BanditUtils.GetMoveTask(endurance, closestPlayer.x+deltaX, closestPlayer.y+deltaY, 0, walkType, 12, false))
        return {status=true, next="Main", tasks=tasks}
    end
    return {status=true, next="Main", tasks=tasks}
end