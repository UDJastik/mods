ZombiePrograms = ZombiePrograms or {}

ZombiePrograms.Police = {}
ZombiePrograms.Police.Stages = {}

ZombiePrograms.Police.Init = function(bandit)
end

ZombiePrograms.Police.GetCapabilities = function()
    -- capabilities are program decided
    local capabilities = {}
    capabilities.melee = true
    capabilities.shoot = true
    capabilities.smashWindow = true
    capabilities.openDoor = true
    capabilities.breakDoor = true
    capabilities.breakObjects = true
    capabilities.unbarricade = true
    capabilities.disableGenerators = true
    capabilities.sabotageCars = true
    return capabilities
end

ZombiePrograms.Police.Prepare = function(bandit)
    local tasks = {}
    local world = getWorld()
    local cell = getCell()
    local cm = world:getClimateManager()
    local dls = cm:getDayLightStrength()

    local weapons = Bandit.GetWeapons(bandit)
    local primary = Bandit.GetBestWeapon(bandit)

    Bandit.ForceStationary(bandit, false)
    Bandit.SetWeapons(bandit, weapons)

    local secondary
    if SandboxVars.Bandits.General_CarryTorches and dls < 0.3 then
        secondary = "Base.HandTorch"
    end

    if weapons.primary.name and weapons.secondary.name then
        local task1 = {action="Unequip", time=100, itemPrimary=weapons.secondary.name}
        table.insert(tasks, task1)
    end

    local task2 = {action="Equip", itemPrimary=primary, itemSecondary=secondary}
    table.insert(tasks, task2)

    return {status=true, next="Main", tasks=tasks}
end

ZombiePrograms.Police.Main = function(bandit)
    local tasks = {}
    local weapons = Bandit.GetWeapons(bandit)

    -- update walk type
    local world = getWorld()
    local cell = getCell()
    local weapons = Bandit.GetWeapons(bandit)
    local outOfAmmo = Bandit.IsOutOfAmmo(bandit)
    local hands = bandit:getVariableString("BanditPrimaryType")
    local brain = BanditBrain.Get(bandit)

    local walkType = "Run"
    local endurance = -0.06
    local secondary

    if bandit:isInARoom() then
        if outOfAmmo then
            walkType = "Run"
        else
            walkType = "WalkAim"
        end
    end

    local health = bandit:getHealth()
    if health < 0.8 then
        walkType = "Limp"
        endurance = 0
    end 
 
    local handweapon = bandit:getVariableString("BanditWeapon") 
    
    local healthMin = 0.7
    if Bandit.IsDNA(bandit, "coward") then
        healthMin = 1.7
    end

    if SandboxVars.Bandits.General_RunAway and health < healthMin then
        return {status=true, next="Escape", tasks=tasks}
    end

    local target = {}

    local closestZombie = BanditUtils.GetClosestZombieLocation(bandit)
    local closestBandit = BanditUtils.GetClosestEnemyBanditLocation(bandit)
    local closestPlayer = BanditUtils.GetClosestPlayerLocation(bandit, false)

    if Bandit.IsHostile(bandit) then
        local age = getGameTime():getWorldAgeHours() - brain.born
        if age > 1 and closestPlayer.dist > 30 then
            Bandit.ClearTasks(bandit)
            Bandit.SetHostile(bandit, false)
            Bandit.SetProgram(bandit, "Patrol", {})
            local syncData = {}
            syncData.id = brain.id
            syncData.hostile = brain.hostile
            syncData.program = brain.program
            Bandit.ForceSyncPart(bandit, syncData)
            return {status=true, next="Main", tasks=tasks}
        end
    end

    target = closestZombie
    if closestBandit.dist < closestZombie.dist then
        target = closestBandit
        enemy = BanditZombie.GetInstanceById(target.id)
    end

    if Bandit.IsHostile(bandit) and closestPlayer.dist < closestBandit.dist then
        target = closestPlayer
        enemy = BanditPlayer.GetPlayerById(target.id)
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
        local targetSquare = cell:getGridSquare(target.x, target.y, target.z)
        local banditSquare = bandit:getSquare()
        if targetSquare and banditSquare then
            local targetBuilding = targetSquare:getBuilding()
            local banditBuilding = banditSquare:getBuilding()

            if targetBuilding and not banditBuilding then
                Bandit.Say(bandit, "INSIDE")
            end
            if not targetBuilding and banditBuilding then
                Bandit.Say(bandit, "OUTSIDE")
            end
            if targetBuilding and banditBuilding then
                if bandit:getZ() < target.z then
                    Bandit.Say(bandit, "UPSTAIRS")
                else
                    local room = targetSquare:getRoom()
                    if room then
                        local roomName = room:getName()
                        if roomName == "kitchen" then
                            Bandit.Say(bandit, "ROOM_KITCHEN")
                        end
                        if roomName == "bathroom" then
                            Bandit.Say(bandit, "ROOM_BATHROOM")
                        end
                    end
                end
            end
        end

        -- out of ammo, get close
        local minDist = 2
        if outOfAmmo then
            minDist = 0.5
        end

        if target.dist > minDist then

            -- must be deterministic, not random (same for all clients)
            local id = BanditUtils.GetCharacterID(bandit)

            local dx = 0
            local dy = 0
            local dxf = ((math.abs(id) % 10) - 5) / 10
            local dyf = ((math.abs(id) % 11) - 5) / 10

            table.insert(tasks, BanditUtils.GetMoveTask(endurance, target.x+dx+dxf, target.y+dy+dyf, target.z, walkType, target.dist, closeSlow))
            return {status=true, next="Main", tasks=tasks}
        end
    else
        -- fixme change to patrol program so its not affected by walkder typical behavior like protersts
        Bandit.ClearTasks(bandit)
        Bandit.SetHostile(bandit, false)
        Bandit.SetProgram(bandit, "Walker", {})
        local syncData = {}
        syncData.id = brain.id
        syncData.hostile = brain.hostile
        syncData.program = brain.program
        Bandit.ForceSyncPart(bandit, syncData)
        return {status=true, next="Main", tasks=tasks}
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

ZombiePrograms.Police.Escape = function(bandit)
    local tasks = {}
    local weapons = Bandit.GetWeapons(bandit)

    local health = bandit:getHealth()

    local endurance = -0.06
    local walkType = "Run"
    if health < 0.8 then
        walkType = "Limp"
        endurance = 0
    end

    local handweapon = bandit:getVariableString("BanditWeapon")

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
        return {status=true, next="Escape", tasks=tasks}
    end
    return {status=true, next="Escape", tasks=tasks}
end

ZombiePrograms.Police.Follow = function(bandit)
    return {status=true, next="Main", tasks={}}
end