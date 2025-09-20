ZombiePrograms = ZombiePrograms or {}

ZombiePrograms.Active = {}
ZombiePrograms.Active.Stages = {}

ZombiePrograms.Active.Init = function(bandit)
end

ZombiePrograms.Active.GetCapabilities = function()
    -- capabilities are program decided
    local capabilities = {}
    capabilities.melee = true
    capabilities.shoot = true
    capabilities.smashWindow = true
    capabilities.openDoor = true
    capabilities.breakDoor = not BWOPopControl.Police.On
    capabilities.breakObjects = not BWOPopControl.Police.On
    capabilities.unbarricade = false
    capabilities.disableGenerators = false
    capabilities.sabotageCars = false
    return capabilities
end

ZombiePrograms.Active.Prepare = function(bandit)
    local tasks = {}
    local world = getWorld()
    local cell = getCell()
    local cm = world:getClimateManager()
    local dls = cm:getDayLightStrength()

    local weapons = Bandit.GetWeapons(bandit)
    local primary = Bandit.GetBestWeapon(bandit)

    Bandit.ForceStationary(bandit, false)
    Bandit.SetWeapons(bandit, weapons)

    -- bandit:setPrimaryHandItem(nil)
    -- bandit:setSecondaryHandItem(nil)

    local secondary
    if SandboxVars.Bandits.General_CarryTorches and dls < 0.3 then
        secondary = "Base.HandTorch"
    end

    if weapons.primary.name and weapons.secondary.name then
        local task1 = {action="Unequip", time=100, itemPrimary=weapons.secondary.name}
        table.insert(tasks, task1)
    end

    local player = getSpecificPlayer(0)
    local px, py = player:getX(), player:getY()
    local anim = BanditUtils.Choice({"Spooked1", "Spooked2"})
    local task2 = {action="TimeFace", anim=anim, x=px, y=py, time=100}
    table.insert(tasks, task2)
    
    local task3 = {action="Equip", itemPrimary=primary, itemSecondary=secondary}
    table.insert(tasks, task3)

    return {status=true, next="Main", tasks=tasks}
end

ZombiePrograms.Active.Main = function(bandit)
    local tasks = {}
    -- if true then return {status=true, next="Main", tasks=tasks} end
    local id = BanditUtils.GetCharacterID(bandit)
    local world = getWorld()
    local cell = getCell()
    local cm = world:getClimateManager()
    local dls = cm:getDayLightStrength()
    local outOfAmmo = Bandit.IsOutOfAmmo(bandit)
    local hands = bandit:getVariableString("BanditPrimaryType")
 
    local walkType = "Run"
    if hands == "rifle" or hands =="handgun" then
        walkType = "WalkAim"
    end

    local coward = Bandit.IsDNA(bandit, "coward")
    if SandboxVars.Bandits.General_RunAway and coward then
        return {status=true, next="Escape", tasks=tasks}
    end

    -- symptoms
    if math.abs(id) % 4 > 0 then
        if BWOScheduler.SymptomLevel == 3 then
            walkType = "Limp"
        elseif BWOScheduler.SymptomLevel >= 4 then
            walkType = "Scramble"
        end

        local subTasks = BanditPrograms.Symptoms(bandit)
        if #subTasks > 0 then
            for _, subTask in pairs(subTasks) do
                table.insert(tasks, subTask)
            end
            return {status=true, next="Main", tasks=tasks}
        end
    end

    local endurance = 0 -- -0.02
    local secondary
    if dls < 0.3 then
        if SandboxVars.Bandits.General_CarryTorches then
            if hands == "barehand" or hands == "onehanded" or hands == "handgun" then
                secondary = "Base.HandTorch"
            end
        end

        if SandboxVars.Bandits.General_SneakAtNight then
            if Bandit.IsDNA(bandit, "sneak") then
                walkType = "SneakWalk"
                endurance = 0
            end
        end
    end

    local health = bandit:getHealth()
    if health < 0.8 then
        walkType = "Limp"
        endurance = 0
    end 
 
    local handweapon = bandit:getVariableString("BanditWeapon") 
    
    local target = {}
    local enemy

    local closestZombie = BanditUtils.GetClosestZombieLocation(bandit)
    local closestBandit = BanditUtils.GetClosestEnemyBanditLocation(bandit)
    local closestPlayer = BanditUtils.GetClosestPlayerLocation(bandit, true)

    target = closestZombie
    if closestBandit.dist < closestZombie.dist then
        target = closestBandit
        enemy = BanditZombie.GetInstanceById(target.id)
    end

    if Bandit.IsHostile(bandit) and closestPlayer.dist < closestBandit.dist and closestPlayer.dist < closestZombie.dist then
        target = closestPlayer
        enemy = BanditPlayer.GetPlayerById(target.id)
    end

    -- no targets, relax
    if target.dist > 30 then
        if bandit:isOutside() then
            Bandit.SetProgram(bandit, "Walker", {})
        else
            Bandit.SetProgram(bandit, "Inhabitant", {})
        end

        local brain = BanditBrain.Get(bandit)
        local syncData = {}
        syncData.id = brain.id
        syncData.program = brain.program
        Bandit.ForceSyncPart(bandit, syncData)
        return {status=true, next="Main", tasks=tasks}
    end

    local closeSlow = true
    if enemy then
        local weapon = enemy:getPrimaryHandItem()
        if weapon and weapon:IsWeapon() then
            local weaponType = WeaponType.getWeaponType(weapon)
            if weaponType == WeaponType.firearm or weaponType == WeaponType.handgun then
                closeSlow = false
            end
        end
    end

    if target.x and target.y and target.z then

        -- out of ammo, get close
        local minDist = 2
        if outOfAmmo then
            minDist = 0.5
        end

        if target.dist > minDist then

            -- must be deterministic, not random (same for all clients)
            local dx = 0
            local dy = 0
            local dxf = ((math.abs(id) % 10) - 5) / 10
            local dyf = ((math.abs(id) % 11) - 5) / 10

            table.insert(tasks, BanditUtils.GetMoveTask(endurance, target.x+dx+dxf, target.y+dy+dyf, target.z, walkType, target.dist, closeSlow))
            return {status=true, next="Main", tasks=tasks}
        end
    end
    
    -- fallback
    local subTasks = BanditPrograms.FallbackAction(bandit)
    if #subTasks > 0 then
        for _, subTask in pairs(subTasks) do
            table.insert(tasks, subTask)
        end
    end

    return {status=true, next="Main", tasks=tasks}
end

ZombiePrograms.Active.Escape = function(bandit)
    local tasks = {}
    local id = BanditUtils.GetCharacterID(bandit)
    local health = bandit:getHealth()

    local endurance = -0.06
    local walkType = "Run"
    if health < 0.8 then
        walkType = "Limp"
        endurance = 0
    end

    -- symptoms
    if math.abs(id) % 4 > 0 then
        if BWOScheduler.SymptomLevel == 3 then
            walkType = "Limp"
        elseif BWOScheduler.SymptomLevel >= 4 then
            walkType = "Scramble"
        end

        local subTasks = BanditPrograms.Symptoms(bandit)
        if #subTasks > 0 then
            for _, subTask in pairs(subTasks) do
                table.insert(tasks, subTask)
            end
            return {status=true, next="Main", tasks=tasks}
        end
    else
        if BWOScheduler.SymptomLevel >= 4 then walkType = "Run" end
    end

    local closestPlayer = BanditUtils.GetClosestPlayerLocation(bandit)

    if closestPlayer.dist > 30 then
        if bandit:isOutside() then
            Bandit.SetProgram(bandit, "Walker", {})
        else
            Bandit.SetProgram(bandit, "Inhabitant", {})
        end

        local brain = BanditBrain.Get(bandit)
        local syncData = {}
        syncData.id = brain.id
        syncData.program = brain.program
        Bandit.ForceSyncPart(bandit, syncData)
        return {status=true, next="Main", tasks=tasks}
    end

    if closestPlayer.x and closestPlayer.y and closestPlayer.z then

        -- calculate random escape direction
        local deltaX = 100 + ZombRand(100)
        local deltaY = 100 + ZombRand(100)

        local rx = ZombRand(2)
        local ry = ZombRand(2)
        if rx == 1 then deltaX = -deltaX end
        if ry == 1 then deltaY = -deltaY end

        table.insert(tasks, BanditUtils.GetMoveTask(endurance, closestPlayer.x+deltaX, closestPlayer.y+deltaY, 0, walkType, 12, false))
    end
    return {status=true, next="Escape", tasks=tasks}
end

ZombiePrograms.Active.Wait = function(bandit)
    return {status=true, next="Main", tasks={}}
end

