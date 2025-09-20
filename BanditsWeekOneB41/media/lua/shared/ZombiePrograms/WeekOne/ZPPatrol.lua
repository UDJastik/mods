ZombiePrograms = ZombiePrograms or {}

ZombiePrograms.Patrol = {}
ZombiePrograms.Patrol.Stages = {}

ZombiePrograms.Patrol.Init = function(bandit)
end

ZombiePrograms.Patrol.GetCapabilities = function()
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

ZombiePrograms.Patrol.Prepare = function(bandit)
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

ZombiePrograms.Patrol.Main = function(bandit)
    local tasks = {}
    local weapons = Bandit.GetWeapons(bandit)

    -- update walk type
    local world = getWorld()
    local cell = getCell()
    local weapons = Bandit.GetWeapons(bandit)
    local outOfAmmo = Bandit.IsOutOfAmmo(bandit)
    local hands = bandit:getVariableString("BanditPrimaryType")
    local brain = BanditBrain.Get(bandit)

    local walkType = "Walk"
    local endurance = 0
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
    
    local subTasks = BanditPrograms.FollowRoad(bandit, walkType)
    if #subTasks > 0 then
        for _, subTask in pairs(subTasks) do
            table.insert(tasks, subTask)
        end
        return {status=true, next="Main", tasks=tasks}
    end

    local subTasks = BanditPrograms.GoSomewhere(bandit, walkType)
    if #subTasks > 0 then
        for _, subTask in pairs(subTasks) do
            table.insert(tasks, subTask)
        end
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

