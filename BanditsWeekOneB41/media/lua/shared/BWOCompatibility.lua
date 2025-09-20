BWOCompatibility = BWOCompatibility or {}

-- compatibility wrappers

BWOCompatibility.GetSandboxOptionVars = function(square)
    local vars = {}
        table.insert (vars, {"FoodLoot", 1.4, 0.3})
        table.insert (vars, {"CannedFoodLoot", 1.2, 0.3})
        table.insert (vars, {"LiteratureLoot", 1.2, 0.3})
        table.insert (vars, {"SurvivalGearsLoot", 1.2, 0.3})
        table.insert (vars, {"MedicalLoot", 1.2, 0.3})
        table.insert (vars, {"WeaponLoot", 1.2, 0.3})
        table.insert (vars, {"RangedWeaponLoot", 1.2, 0.3})
        table.insert (vars, {"AmmoLoot", 1.6, 0.5})
        table.insert (vars, {"MechanicsLoot", 1.2, 0.3})
        table.insert (vars, {"OtherLoot", 1.2, 0.3})
    return vars
end

BWOCompatibility.GetFlier = function()
    local item
        local txt = "URGENT PUBLIC NOTICE\nIMMEDIATE ACTION REQUIRED\n"
        txt = txt .. "The CDC has declared an imminent contamination hazard in your area. \n\n"
        txt = txt .. "To ensure your safety:\n"
        txt = txt .. "You required to wear approved hazmat suits at all times. \n"
        txt = txt .. "Proceed immediately to underground levels such as basements, shelters, or designated safe zones.\n\n"
        txt = txt .. "Stay alert. Stay protected. Together, we can ensure our safety.\n"
        item = BanditCompatibility.InstanceItem("Base.Notebook")
        item:setName("Flier: CDC URGENT PUBLIC NOTICE")
        item:setCustomName(true)
        item:addPage(1, txt)
end

BWOCompatibility.AddVehicle = function(btype, dir, square)
    local vehicle
    -- In MP, request server-side spawn to avoid client/server physics mismatch
    if isClient() then
        local dirStr = "S"
        if dir == IsoDirections.N then dirStr = "N"
        elseif dir == IsoDirections.S then dirStr = "S"
        elseif dir == IsoDirections.E then dirStr = "E"
        elseif dir == IsoDirections.W then dirStr = "W" end
        local args = {
            script = btype,
            x = square:getX(),
            y = square:getY(),
            z = square:getZ() or 0,
            dir = dirStr,
            randomColor = true,
            headlightsOn = true,
            generalPartCondition = {min=80, max=100},
            wasRepaired = true,
            autonomous = true
        }
        sendClientCommand(getSpecificPlayer(0), 'Commands', 'SpawnVehicle', args)
        return nil
    end
    vehicle = addVehicleDebug(btype, dir, nil, square)
    if not vehicle then return nil end

    -- Mirror server-side setup when spawning directly (SP/host)
    for i = 0, vehicle:getPartCount() - 1 do
        local container = vehicle:getPartByIndex(i):getItemContainer()
        if container then container:removeAllItems() end
    end

    local md = vehicle:getModData()
    md.BWO = md.BWO or {}

    -- Persist compass direction as string for BWOVehicles logic
    local dirStr = "S"
    if dir == IsoDirections.N then dirStr = "N"
    elseif dir == IsoDirections.S then dirStr = "S"
    elseif dir == IsoDirections.E then dirStr = "E"
    elseif dir == IsoDirections.W then dirStr = "W" end
    md.BWO.dir = dirStr
    md.BWO.wasRepaired = true
    md.BWO.autonomous = true

    vehicle:setGeneralPartCondition(100, 80)
    vehicle:setColor(ZombRandFloat(0, 1), ZombRandFloat(0, 1), ZombRandFloat(0, 1))
    vehicle:setHeadlightsOn(true)

    -- Register for autonomous management and NPC driver attachment
    if BWOVehicles and BWOVehicles.Register then
        BWOVehicles.Register(vehicle)
    end

    -- Attach NPC driver immediately when possible (SP/host)
    if SurvivorFactory and IsoPlayer and Vector3f then
        local square = vehicle:getSquare()
        if square then
            local cell = square:getCell()
            local npcAesthetics = SurvivorFactory.CreateSurvivor(SurvivorType.Neutral, false)
            npcAesthetics:setForename("Driver")
            npcAesthetics:setSurname("Driver")
            npcAesthetics:dressInNamedOutfit("Police")

            local driver = IsoPlayer.new(cell, npcAesthetics, square:getX(), square:getY(), square:getZ())
            driver:setNPC(true)
            driver:setGodMod(true)
            driver:setInvisible(true)
            driver:setGhostMode(true)

            local vxDir = driver:getForwardDirection():getX()
            local vyDir = driver:getForwardDirection():getY()
            local forwardVector = Vector3f.new(vxDir, vyDir, 0)
            if vehicle:getChunk() then
                vehicle:setPassenger(0, driver, forwardVector)
                driver:setVehicle(vehicle)
                driver:setCollidable(false)
            end

            vehicle:tryStartEngine(true)
            vehicle:engineDoStartingSuccess()
            vehicle:engineDoRunning()
        end
    end

    return vehicle
end

BWOCompatibility.GetCarType = function(carType)
    local map = {}
    map["Base.StepVan_LouisvilleSWAT"] = "Base.PickUpVanLightsPolice"
    if map[carType] then
        return map[carType]
    end
    return carType
end