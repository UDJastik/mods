ZombiePrograms = ZombiePrograms or {}

ZombiePrograms.Babe = {}
ZombiePrograms.Babe.Stages = {}

ZombiePrograms.Babe.Init = function(bandit)
end

ZombiePrograms.Babe.GetCapabilities = function()
    -- capabilities are program decided
    local capabilities = {}
    capabilities.melee = true
    capabilities.shoot = true
    capabilities.smashWindow = false
    capabilities.openDoor = true
    capabilities.breakDoor = false
    capabilities.breakObjects = false
    capabilities.unbarricade = false
    capabilities.disableGenerators = false
    capabilities.sabotageCars = false
    return capabilities
end

ZombiePrograms.Babe.Prepare = function(bandit)
    local tasks = {}
    local world = getWorld()
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

    if weapons.secondary.name then
        local task1 = {action="Unequip", time=100, itemPrimary=weapons.secondary.name}
        table.insert(tasks, task1)
    end

    local task2 = {action="Equip", itemPrimary=weapons.melee, itemSecondary=secondary}
    table.insert(tasks, task2)

    return {status=true, next="Follow", tasks=tasks}
end

ZombiePrograms.Babe.Follow = function(bandit)
    local tasks = {}
    local world = getWorld()
    local cm = world:getClimateManager()
    local cell = getCell()

    local master = getSpecificPlayer(0)
    
    -- update walktype
    local walkType = "Walk"
    local endurance = 0.00
    local vehicle = master:getVehicle()
    local dist = BanditUtils.DistTo(bandit:getX(), bandit:getY(), master:getX(), master:getY())

    if master:isRunning() or master:isSprinting() or vehicle or dist > 10 then
        walkType = "Run"
        endurance = -0.07
    elseif master:isSneaking() and dist < 12 then
        walkType = "SneakWalk"
        endurance = -0.01
    end

    local outOfAmmo = Bandit.IsOutOfAmmo(bandit)
    if master:isAiming() and not outOfAmmo and dist < 8 then
        walkType = "WalkAim"
        endurance = 0
    end

    local health = bandit:getHealth()
    if health < 0.4 then
        walkType = "Limp"
        endurance = 0
    end 
   
    -- fake npc in vehicle 
    if vehicle and vehicle:isDriver(master) then
        bandit:addLineChatElement("Wait for me!", 0, 1, 0)
        if dist < 3.5 then
            local brain = BanditBrain.Get(bandit)
            
            local seat = 1
            if vehicle:isSeatInstalled(seat) and not vehicle:isSeatOccupied(seat) then
                brain.inVehicle = true

                local npcAesthetics = SurvivorFactory.CreateSurvivor(SurvivorType.Neutral, false)
                npcAesthetics:setForename("Driver")
                npcAesthetics:setSurname("Driver")
                npcAesthetics:dressInNamedOutfit("Police")

                -- invisible fake driver that replaces babe
                local square = bandit:getSquare()
                local driver = IsoPlayer.new(cell, npcAesthetics, square:getX(), square:getY(), square:getZ())

                driver:setSceneCulled(false)
                driver:setNPC(true)
                driver:setGodMod(true)
                driver:setInvisible(true)
                driver:setGhostMode(true)
                driver:getModData().BWOBID = brain.id
                master:addLineChatElement("I'm in!", 0, 1, 0)

                local vx = driver:getForwardDirection():getX()
                local vy = driver:getForwardDirection():getY()
                local forwardVector = Vector3f.new(vx, vy, 0)
                
                if vehicle:getChunk() then
                    vehicle:setPassenger(seat, driver, forwardVector)
                    driver:setVehicle(vehicle)
                    driver:setCollidable(false)
                end

                master:playSound("VehicleDoorOpen")
                bandit:removeFromSquare()
                bandit:removeFromWorld()
                
            end
        end
    else
        local bvehicle = bandit:getVehicle()
        if bvehicle then
            print ("EXIT VEH")
            -- After exiting the vehicle, the companion is in the ongroundstate.
            -- Additionally he is under the car. This is fixed in BanditUpdate loop. 
            bandit:setVariable("BanditImmediateAnim", true)
            bvehicle:exit(bandit)
            bandit:playSound("VehicleDoorClose")
        end
    end

    -- Babe intention is to generally stay with the player
    -- however, if the enemy is close, the babe should engage
    -- but only if player is not too far, kind of a proactive defense.
    if dist < 20 then
        local enemy
        local closestZombie = BanditUtils.GetClosestZombieLocation(bandit)
        local closestBandit = BanditUtils.GetClosestEnemyBanditLocation(bandit)
        local closestEnemy = closestZombie

        if closestBandit.dist < closestZombie.dist then 
            closestEnemy = closestBandit
            enemy = BanditZombie.GetInstanceById(closestEnemy.id)
        end

        if closestEnemy.dist < 8 then
            -- We are trying to save the player, so the friendly should act with high motivation
            -- that translates to running pace (even despite limping) and minimal endurance loss.

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

            walkType = "Run"
            endurance = -0.01
            table.insert(tasks, BanditUtils.GetMoveTask(endurance, closestEnemy.x, closestEnemy.y, closestEnemy.z, walkType, closestEnemy.dist, closeSlow))
            return {status=true, next="Follow", tasks=tasks}
        end
    end
    
    -- look for guns
    if Bandit.IsOutOfAmmo(bandit) then

        -- deadbodies
        for z=0, 2 do
            for y=-12, 12 do
                for x=-12, 12 do
                    local square = cell:getGridSquare(bandit:getX() + x, bandit:getY() + y, z)
                    if square then
                        local body = square:getDeadBody()
                        if body then

                            -- we found one body, but there my be more bodies on that square and we need to check all
                            local objects = square:getStaticMovingObjects()
                            for i=0, objects:size()-1 do
                                local object = objects:get(i)
                                if instanceof (object, "IsoDeadBody") then
                                    local body = object
                                    container = body:getContainer()
                                    if container and not container:isEmpty() then
                                        local subTasks = BanditPrograms.Container.WeaponLoot(bandit, body, container)
                                        if #subTasks > 0 then
                                            for _, subTask in pairs(subTasks) do
                                                table.insert(tasks, subTask)
                                            end
                                            return {status=true, next="Prepare", tasks=tasks}
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        -- containers in rooms
        local room = bandit:getSquare():getRoom()
        if room then
            local roomDef = room:getRoomDef()
            for x=roomDef:getX(), roomDef:getX2() do
                for y=roomDef:getY(), roomDef:getY2() do
                    local square = cell:getGridSquare(x, y, roomDef:getZ())
                    if square then
                        local objects = square:getObjects()
                        for i=0, objects:size() - 1 do
                            local object = objects:get(i)
                            local container = object:getContainer()
                            if container and not container:isEmpty() then
                                local subTasks = BanditPrograms.Container.WeaponLoot(bandit, object, container)
                                if #subTasks > 0 then
                                    for _, subTask in pairs(subTasks) do
                                        table.insert(tasks, subTask)
                                    end
                                    return {status=true, next="Prepare", tasks=tasks}
                                end

                                --[[local subTasks = BanditPrograms.Container.Loot(bandit, object, container)
                                if #subTasks > 0 then
                                    for _, subTask in pairs(subTasks) do
                                        table.insert(tasks, subTask)
                                    end
                                    return {status=true, next="Prepare", tasks=tasks}
                                end]]
                            end
                        end
                    end
                end
            end
        end 
    end

    -- follow the player.
    local minDist = 2
    if dist > minDist then
        local id = BanditUtils.GetCharacterID(bandit)

        local theta = master:getDirectionAngle() * math.pi / 180
        local lx = 3 * math.cos(theta)
        local ly = 3 * math.sin(theta)

        local dx = master:getX() - lx
        local dy = master:getY() - ly
        local dz = master:getZ()
        local dxf = ((math.abs(id) % 10) - 5) / 10
        local dyf = ((math.abs(id) % 11) - 5) / 10
        table.insert(tasks, BanditUtils.GetMoveTask(endurance, dx+dxf, dy+dyf, dz, walkType, dist, false))
        return {status=true, next="Follow", tasks=tasks}
    end

    -- nothing to do, play idle anims
    local subTasks = BanditPrograms.Idle(bandit)
    if #subTasks > 0 then
        for _, subTask in pairs(subTasks) do
            table.insert(tasks, subTask)
        end
        return {status=true, next="Follow", tasks=tasks}
    end

    return {status=true, next="Follow", tasks=tasks}
end

ZombiePrograms.Babe.Guard = function(bandit)
    local tasks = {}

    local action = ZombRand(7)

    if action == 0 then
        local task = {action="Time", anim="ShiftWeight", time=200}
        table.insert(tasks, task)
    elseif action == 1 then
        local task = {action="Time", anim="Cough", time=200}
        table.insert(tasks, task)
    elseif action == 2 then
        local task = {action="Time", anim="ChewNails", time=200}
        table.insert(tasks, task)
    elseif action == 3 then
        local task = {action="Time", anim="Smoke", time=200}
        table.insert(tasks, task)
        table.insert(tasks, task)
        table.insert(tasks, task)
    elseif action == 4 then
        local task = {action="Time", anim="PullAtCollar", time=200}
        table.insert(tasks, task)
    elseif action == 5 then
        local task = {action="Time", anim="Sneeze", time=200}
        table.insert(tasks, task)
        addSound(getPlayer(), bandit:getX(), bandit:getY(), bandit:getZ(), 7, 60)
    elseif action == 6 then
        local task = {action="Time", anim="WipeBrow", time=200}
        table.insert(tasks, task)
    elseif action == 7 then
        local task = {action="Time", anim="WipeHead", time=200}
        table.insert(tasks, task)
    end
    return {status=true, next="Guard", tasks=tasks}
end

ZombiePrograms.Babe.Base = function(bandit)
    local tasks = {}

    local brain = BanditBrain.Get(bandit)
    local bx = bandit:getX()
    local by = bandit:getY()

    local hx = brain.bornCoords.x
    local hy = brain.bornCoords.y
    local hz = brain.bornCoords.z
    
    local walkType = "Walk"
    local endurance = 0

    local dist = BanditUtils.DistTo(bx, by, hx, hy)
    if dist > 2 then
        table.insert(tasks, BanditUtils.GetMoveTask(endurance, hx, hy, hz, walkType, dist, false))
        return {status=true, next="Base", tasks=tasks}
    else
        return {status=true, next="Guard", tasks=tasks}
    end
    return {status=true, next="Base", tasks=tasks}
end
