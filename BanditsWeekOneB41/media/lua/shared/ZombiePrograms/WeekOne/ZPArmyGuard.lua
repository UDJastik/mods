ZombiePrograms = ZombiePrograms or {}

ZombiePrograms.ArmyGuard = {}
ZombiePrograms.ArmyGuard.Stages = {}

ZombiePrograms.ArmyGuard.Init = function(bandit)
end

ZombiePrograms.ArmyGuard.GetCapabilities = function()
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

ZombiePrograms.ArmyGuard.Prepare = function(bandit)
    local tasks = {}

    local weapons = Bandit.GetWeapons(bandit)
    local primary = Bandit.GetBestWeapon(bandit)

    Bandit.ForceStationary(bandit, true)
    Bandit.SetWeapons(bandit, weapons)

    if weapons.primary.name and weapons.secondary.name then
        local task1 = {action="Unequip", time=100, itemPrimary=weapons.secondary.name}
        table.insert(tasks, task1)
    end

    local task2 = {action="Equip", itemPrimary=primary, itemSecondary=secondary}
    table.insert(tasks, task2)

    return {status=true, next="Main", tasks=tasks}
end

ZombiePrograms.ArmyGuard.Main = function(bandit)
    local tasks = {}

    -- activated
    local closestZombie = BanditUtils.GetClosestZombieLocation(bandit)
    if closestZombie.dist < 15 then
        Bandit.Say(bandit, "SPOTTED")
        Bandit.ClearTasks(bandit)
        Bandit.SetProgram(bandit, "Bandit", {})
        Bandit.ForceStationary(bandit, false)
        return {status=true, next="Prepare", tasks=tasks}
    end

    if Bandit.IsHostile(bandit) then
        local closestPlayer = BanditUtils.GetClosestPlayerLocation(bandit, false)
        if closestPlayer.dist < 50 then
            Bandit.Say(bandit, "SPOTTED")
            Bandit.ClearTasks(bandit)
            Bandit.SetProgram(bandit, "Bandit", {})
            Bandit.ForceStationary(bandit, false)
            return {status=true, next="Prepare", tasks=tasks}
        end
    end

    local subTasks = BanditPrograms.Idle(bandit)
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

