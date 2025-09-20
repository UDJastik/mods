ZombiePrograms = ZombiePrograms or {}

ZombiePrograms.Runner = {}
ZombiePrograms.Runner.Stages = {}

ZombiePrograms.Runner.Init = function(bandit)
end

ZombiePrograms.Runner.GetCapabilities = function()
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

ZombiePrograms.Runner.Prepare = function(bandit)
    local tasks = {}
    local world = getWorld()
    local cell = getCell()
    local cm = world:getClimateManager()
    local dls = cm:getDayLightStrength()

    Bandit.ForceStationary(bandit, false)

    return {status=true, next="Main", tasks=tasks}
end

ZombiePrograms.Runner.Main = function(bandit)
    local tasks = {}

    local id = BanditUtils.GetCharacterID(bandit)
    local bx = bandit:getX()
    local by = bandit:getY()
    local bz = bandit:getZ()
    local walkType = "Run"
    local endurance = 0 -- runners are fit!
    local cell = bandit:getCell()

    -- too sick to run
    if BWOScheduler.SymptomLevel > 2 then
        Bandit.ClearTasks(bandit)
        Bandit.SetProgram(bandit, "Walker", {})

        local brain = BanditBrain.Get(bandit)
        local syncData = {}
        syncData.id = brain.id
        syncData.program = brain.program
        Bandit.ForceSyncPart(bandit, syncData)
        return {status=true, next="Main", tasks=tasks}
    end

    -- react to events
    local subTasks = BanditPrograms.Events(bandit)
    if #subTasks > 0 then
        for _, subTask in pairs(subTasks) do
            table.insert(tasks, subTask)
        end
        return {status=true, next="Main", tasks=tasks}
    end

    -- follow the street / road
    local subTasks = BanditPrograms.FollowRoad(bandit, walkType)
    if #subTasks > 0 then
        for _, subTask in pairs(subTasks) do
            table.insert(tasks, subTask)
        end
        return {status=true, next="Main", tasks=tasks}
    end

    -- fallback if no road is found
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
