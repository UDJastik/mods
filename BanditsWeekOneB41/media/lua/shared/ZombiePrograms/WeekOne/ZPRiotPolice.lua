ZombiePrograms = ZombiePrograms or {}

ZombiePrograms.RiotPolice = {}
ZombiePrograms.RiotPolice.Stages = {}

ZombiePrograms.RiotPolice.Init = function(bandit)
end

ZombiePrograms.RiotPolice.GetCapabilities = function()
    -- capabilities are program decided
    local capabilities = {}
    capabilities.melee = true
    capabilities.shoot = false
    capabilities.smashWindow = true
    capabilities.openDoor = true
    capabilities.breakDoor = true
    capabilities.breakObjects = true
    capabilities.unbarricade = false
    capabilities.disableGenerators = false
    capabilities.sabotageCars = false
    return capabilities
end

ZombiePrograms.RiotPolice.Prepare = function(bandit)
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

ZombiePrograms.RiotPolice.Main = function(bandit)
    local tasks = {}

    local id = BanditUtils.GetCharacterID(bandit)
    local world = getWorld()
    local cell = getCell()
 
    local walkType = "WalkAim"
    local closeSlow = false

    local endurance = 0

    local health = bandit:getHealth()
    if health < 0.8 then
        walkType = "Limp"
        endurance = 0
    end 

    local minDist = 2
    local target = BanditUtils.GetClosestBanditLocationProgram(bandit, {"Walker", "Runner", "Active"})
    if target.x and target.y and target.z and target.dist < 20 then
        if target.dist > minDist then

            local id = BanditUtils.GetCharacterID(bandit)

            local dx = 0
            local dy = 0
            local dxf = ((math.abs(id) % 10) - 5) / 10
            local dyf = ((math.abs(id) % 11) - 5) / 10

            table.insert(tasks, BanditUtils.GetMoveTask(endurance, target.x+dx+dxf, target.y+dy+dyf, target.z, walkType, target.dist, closeSlow))
            return {status=true, next="Main", tasks=tasks}
        end
    end

    local target = BWOObjects.FindGMD(bandit, "protest")
    if target.x and target.y and target.z then
        table.insert(tasks, BanditUtils.GetMoveTask(endurance, target.x, target.y, target.z, walkType, target.dist, closeSlow))
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
