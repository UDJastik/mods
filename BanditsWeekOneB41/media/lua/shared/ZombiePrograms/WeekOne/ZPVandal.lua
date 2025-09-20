ZombiePrograms = ZombiePrograms or {}

ZombiePrograms.Vandal = {}
ZombiePrograms.Vandal.Stages = {}

ZombiePrograms.Vandal.Init = function(bandit)
end

ZombiePrograms.Vandal.GetCapabilities = function()
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

ZombiePrograms.Vandal.Prepare = function(bandit)
    local tasks = {}
    local world = getWorld()
    local cell = getCell()
    local cm = world:getClimateManager()
    local dls = cm:getDayLightStrength()

    Bandit.ForceStationary(bandit, false)

    return {status=true, next="Main", tasks=tasks}
end

ZombiePrograms.Vandal.Main = function(bandit)

    local function checkWalls(squareList, north)
        for _, square in pairs(squareList) do
                        
            local wall
            if north then
                wall = square:getWall(true)
            else
                wall = square:getWall(false)
            end

            if not wall then return false end

            local sprite = wall:getSprite()
            if not sprite then return false end

            local spriteProps = sprite:getProperties()
            if spriteProps:Is(IsoFlagType.WallNTrans) or spriteProps:Is(IsoFlagType.WallWTrans) then return false end
            if spriteProps:Is(IsoFlagType.WindowN) or spriteProps:Is(IsoFlagType.WindowW) then return false end
            if spriteProps:Is(IsoFlagType.DoorWallN) or spriteProps:Is(IsoFlagType.DoorWallW) then return false end
            if spriteProps:Is(IsoFlagType.WallSE) then return false end

            local attachments = wall:getAttachedAnimSprite()
            if attachments then
                for i=0, attachments:size()-1 do
                    local attachment = attachments:get(i)
                    local name = attachment:getName()
                    if attachment and name:embodies("graffiti") or name:embodies("message") then
                        return false
                    end
                end
            end
        end
        return true
    end

    local tasks = {}

    local id = BanditUtils.GetCharacterID(bandit)
    local bx = bandit:getX()
    local by = bandit:getY()
    local bz = bandit:getZ()
    local walkType = "Run"
    local endurance = 0 -- runners are fit!
    local cell = bandit:getCell()

    -- too sick to run
    if BWOScheduler.SymptomLevel > 3 then
        Bandit.ClearTasks(bandit)
        Bandit.SetProgram(bandit, "Walker", {})

        local brain = BanditBrain.Get(bandit)
        local syncData = {}
        syncData.id = brain.id
        syncData.program = brain.program
        Bandit.ForceSyncPart(bandit, syncData)
        return {status=true, next="Main", tasks=tasks}
    end

    local foundDist = math.huge
    local foundObj
    local foundDir = "N"
    for x=bx-10, bx+10 do
        for y=by-10, by+10 do
            local square = cell:getGridSquare(x, y, 0)
            if square and square:isOutside() then
                local wall = square:getWall(true)
                local north = true
                if not wall then
                    wall = square:getWall(false)
                    north = false
                end

                if wall then
                    local squareList = {}
                    if north then
                        for dx=-1, 1 do
                            table.insert(squareList, cell:getGridSquare(x + dx, y, 0))
                        end
                    else
                        for dy=-1, 1 do
                            table.insert(squareList, cell:getGridSquare(x, y+ dy, 0))
                        end
                    end
                    
                    local ok = checkWalls(squareList, north)
                    if ok then
                        local dist = BanditUtils.DistTo(x, y, bx, by)
                        if dist < foundDist then
                            foundObj = wall
                            foundDist = dist
                            if north then 
                                foundDir ="N"
                            else
                                foundDir ="W"
                            end
                        end
                    end
                end
            end
        end
    end

    if foundObj then
        local dist = BanditUtils.DistTo(bandit:getX(), bandit:getY(), foundObj:getX() + 0.5, foundObj:getY() + 0.5)
        if dist > 0.70 then
            table.insert(tasks, BanditUtils.GetMoveTask(0, foundObj:getX() + 0.5, foundObj:getY() + 0.5, foundObj:getZ(), walkType, dist, false))
            return {status=true, next="Main", tasks=tasks}
        else
            local task = {action="Graffiti", anim="Paint", sound="TIsnd_TakingM", dir=foundDir, x=foundObj:getX(), y=foundObj:getY(), z=foundObj:getZ(), time=300}
            table.insert(tasks, task)
            return {status=true, next="Main", tasks=tasks}
        end
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
