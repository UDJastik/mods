ZombiePrograms = ZombiePrograms or {}

ZombiePrograms.Medic = {}
ZombiePrograms.Medic.Stages = {}

ZombiePrograms.Medic.Init = function(bandit)
end

ZombiePrograms.Medic.GetCapabilities = function()
    -- capabilities are program decided
    local capabilities = {}
    capabilities.melee = false
    capabilities.shoot = false
    capabilities.smashWindow = not BWOPopControl.Police.On
    capabilities.openDoor = true
    capabilities.breakDoor = not BWOPopControl.Police.On
    capabilities.breakObjects = not BWOPopControl.Police.On
    capabilities.unbarricade = false
    capabilities.disableGenerators = false
    capabilities.sabotageCars = false
    return capabilities
end

ZombiePrograms.Medic.Prepare = function(bandit)
    local tasks = {}
    local world = getWorld()
    local cell = getCell()
    local cm = world:getClimateManager()
    local dls = cm:getDayLightStrength()

    Bandit.ForceStationary(bandit, false)

    return {status=true, next="Main", tasks=tasks}
end

ZombiePrograms.Medic.Main = function(bandit)
    local tasks = {}

    local cell = bandit:getCell()
    local id = BanditUtils.GetCharacterID(bandit)
    local bx = bandit:getX()
    local by = bandit:getY()
    local bz = bandit:getZ()
    local walkType = "Run"
    local endurance = 0

    -- symptoms
    if math.abs(id) % 2 > 0 then
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
    
    -- CPR
    local target = BWOObjects.FindDeadBody(bandit)

    if target.x and target.y and target.z then
        if target.dist > 1.0 then
            table.insert(tasks, BanditUtils.GetMoveTask(endurance, target.x, target.y, target.z, walkType, target.dist, false))
            return {status=true, next="Main", tasks=tasks}
        else
            local square = cell:getGridSquare(target.x, target.y, target.z)
            if square then
                deadbody = square:getDeadBody()
                if deadbody then
                    local task = {action="Heal", time=1000, x=deadbody:getX(), y=deadbody:getY(), z=deadbody:getZ()}
                    table.insert(tasks, task)
                    return {status=true, next="Main", tasks=tasks}
                end
            end
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

ZombiePrograms.Medic.Walk = function(bandit)
    local tasks = {}
    return {status=true, next="Main", tasks=tasks}
end