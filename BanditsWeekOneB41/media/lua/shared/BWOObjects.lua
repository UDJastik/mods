BWOObjects = BWOObjects or {}

local function predicateAll(item)
    -- item:getType()
    return true
end


-- this is a collection of functions resonsible for finding a particular map object that is required
-- by various npc programs

BWOObjects.Find = function (bandit, def, objName)
    local cell = getCell()
    local bid = BanditUtils.GetCharacterID(bandit)
    local bx = bandit:getX()
    local by = bandit:getY()
    local bz = bandit:getZ()
    local foundDist = math.huge
    local foundObj

    local x1 = def:getX()
    local x2 = def:getX2()
    local y1 = def:getY()
    local y2 = def:getY2()
    local size = (x2 - x1) * (y2 - y1)

    if size > 196 then
        x1 = bx - 14
        x2 = bx + 14
        y1 = by - 14
        y2 = by + 14

        if x1 < def:getX() then x1 = def:getX() end
        if x2 > def:getX2() then x2 = def:getX2() end
        if y1 < def:getY() then y1 = def:getY() end
        if y2 > def:getY2() then y2 = def:getY2() end
    end

    for x=x1, x2 do
        for y=y1, y2 do
            local square = cell:getGridSquare(x, y, def:getZ())
            if square then
                local zombie = square:getZombie()
                
                -- skip objects that are already occupied by other character
                local taken = false
                local chrs = square:getMovingObjects()
                for i=0, chrs:size()-1 do
                    local chr = chrs:get(i)
                    if instanceof(chr, "IsoZombie") and BanditUtils.GetCharacterID(chr) == bid then
                        taken = false
                    else
                        taken = true
                        break
                    end
                end

                if not taken then
                    local objects = square:getObjects()
                    for i=0, objects:size()-1 do
                        local object = objects:get(i)
                        local sprite = object:getSprite()
                        if sprite then
                            local props = sprite:getProperties()
                            if props:Is("CustomName") then
                                local name = props:Val("CustomName")
                                if name == objName then
                                    local dist = BanditUtils.DistTo(x, y, bx, by)
                                    if dist < foundDist then
                                        foundObj = object
                                        foundDist = dist
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return foundObj
end

BWOObjects.FindFull = function (bandit, def, objName)
    local cell = getCell()
    local bid = BanditUtils.GetCharacterID(bandit)
    local bx = bandit:getX()
    local by = bandit:getY()
    local bz = bandit:getZ()
    local foundDist = math.huge
    local foundObj

    local x1 = def:getX()
    local x2 = def:getX2()
    local y1 = def:getY()
    local y2 = def:getY2()
    local size = (x2 - x1) * (y2 - y1)

    if size > 196 then
        x1 = bx - 14
        x2 = bx + 14
        y1 = by - 14
        y2 = by + 14

        if x1 < def:getX() then x1 = def:getX() end
        if x2 > def:getX2() then x2 = def:getX2() end
        if y1 < def:getY() then y1 = def:getY() end
        if y2 > def:getY2() then y2 = def:getY2() end
    end

    for x=x1, x2 do
        for y=y1, y2 do
            local square = cell:getGridSquare(x, y, def:getZ())
            if square then
                local objects = square:getObjects()
                for i=0, objects:size()-1 do
                    local object = objects:get(i)
                    local sprite = object:getSprite()
                    if sprite then
                        local props = sprite:getProperties()
                        if props:Is("CustomName") then
                            local name = props:Val("CustomName")
                            if not objName or name == objName then
                                local container = object:getContainer()
                                if container and not container:isEmpty() then
                                    local dist = BanditUtils.DistTo(x, y, bx, by)
                                    if dist < foundDist then
                                        foundObj = object
                                        foundDist = dist
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return foundObj
end

BWOObjects.FindAround = function (bandit, r, objName)
    local cell = getCell()
    local bid = BanditUtils.GetCharacterID(bandit)
    local bx = bandit:getX()
    local by = bandit:getY()
    local bz = bandit:getZ()
    local foundDist = math.huge
    local foundObj
    for x=bx-r, bx+r do
        for y=by-r, by+r do
            local square = cell:getGridSquare(x, y, bz)
            if square then
                local zombie = square:getZombie()
                if not zombie or BanditUtils.GetCharacterID(zombie) == bid then
                    local objects = square:getObjects()
                    for i=0, objects:size()-1 do
                        local object = objects:get(i)
                        local sprite = object:getSprite()
                        if sprite then
                            local props = sprite:getProperties()
                            if props:Is("CustomName") then
                                local name = props:Val("CustomName")
                                if name == objName then
                                    local dist = BanditUtils.DistTo(x, y, bx, by)
                                    if dist < foundDist then
                                        foundObj = object
                                        foundDist = dist
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return foundObj
end

BWOObjects.FindFire = function (bandit, r)
    local cell = getCell()
    local bid = BanditUtils.GetCharacterID(bandit)
    local bx = bandit:getX()
    local by = bandit:getY()
    local bz = bandit:getZ()
    local foundDist = math.huge
    local foundObj
    for x=bx-r, bx+r do
        for y=by-r, by+r do
            local square = cell:getGridSquare(x, y, bz)
            if square then
                if square:haveFire() then
                    local dist = BanditUtils.DistTo(x, y, bx, by)
                    if dist < foundDist then
                        foundObj = square
                        foundDist = dist
                    end
                end
            end
        end
    end
    return foundObj
end

BWOObjects.FindBarricadable = function (bandit, def)
    local cell = getCell()
    local bid = BanditUtils.GetCharacterID(bandit)
    local bx = bandit:getX()
    local by = bandit:getY()
    local bz = bandit:getZ()
    local foundDist = math.huge
    local foundObj
    for x=def:getX(), def:getX2() + 1 do
        for y=def:getY(), def:getY2() + 1 do
            local square = cell:getGridSquare(x, y, def:getZ())
            if square then
                local zombie = square:getZombie()
                if not zombie or BanditUtils.GetCharacterID(zombie) == bid then
                    local objects = square:getObjects()
                    for i=0, objects:size()-1 do
                        local object = objects:get(i)
                        if instanceof(object, "IsoWindow") or instanceof(object, "IsoDoor") then
                            local oppositeSquare = object:getOppositeSquare()
                            if oppositeSquare then
                                if square:isOutside() ~= oppositeSquare:isOutside() then
                                    
                                    local numPlanks = 0
                                    local barricade = object:getBarricadeOnSameSquare()
                                    if barricade then
                                        numPlanks = numPlanks + barricade:getNumPlanks()
                                    end

                                    local barricade2 = object:getBarricadeOnOppositeSquare()
                                    if barricade2 then
                                        numPlanks = numPlanks + barricade2:getNumPlanks()
                                    end

                                    if numPlanks < 4 then
                                        local dist = math.sqrt(math.pow(x - bx, 2) + math.pow(y - by, 2))
                                        if dist < foundDist then
                                            foundObj = object
                                            foundDist = dist
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return foundObj
end

BWOObjects.FindExteriorDoor = function (bandit, def)
    local cell = getCell()
    local bid = BanditUtils.GetCharacterID(bandit)
    local bx = bandit:getX()
    local by = bandit:getY()
    local bz = bandit:getZ()
    local foundDist = math.huge
    local foundObj
    local cnt = 0
    for x=def:getX(), def:getX2() + 1 do
        for y=def:getY(), def:getY2() + 1 do
            local square = cell:getGridSquare(x, y, def:getZ())
            if square then
                local door = square:getIsoDoor()
                if door and door:isExterior() then
                    local dist = BanditUtils.DistTo(x, y, bx, by)
                    if dist < foundDist then
                        foundObj = door
                        foundDist = dist
                    end
                end
            end
            cnt = cnt + 1
        end
    end
    -- print ("EX DOOR CNT" .. cnt)
    return foundObj
end

BWOObjects.FindLightSwitch = function (bandit, def)
    local cell = getCell()
    local bid = BanditUtils.GetCharacterID(bandit)
    local bx = bandit:getX()
    local by = bandit:getY()
    local bz = bandit:getZ()
    local foundDist = math.huge
    local foundObj
    for x=def:getX(), def:getX2() do
        for y=def:getY(), def:getY2() do
            local square = cell:getGridSquare(x, y, def:getZ())
            if square and not square:isOutside() then
                local objects = square:getObjects()
                for i=0, objects:size()-1 do
                    local object = objects:get(i)
                    if instanceof(object, "IsoLightSwitch") then
                        local dist = math.sqrt(math.pow(x - bx, 2) + math.pow(y - by, 2))
                        if dist < foundDist then
                            foundObj = object
                            foundDist = dist
                        end
                    end
                end
            end
        end
    end
    return foundObj
end

BWOObjects.FindDeadBody = function (bandit)
    local gmd = GetBWOModData()
    local bx, by = bandit:getX(), bandit:getY()

    local result = {}
    result.dist = math.huge
    result.x = false
    result.y = false
    result.z = false

    for id, deadBody in pairs(gmd.DeadBodies) do
        local dist = BanditUtils.DistToManhattan(bx, by, deadBody.x, deadBody.y)
        if dist < result.dist then
            result.dist = dist
            result.x = deadBody.x
            result.y = deadBody.y
            result.z = deadBody.z
        end
    end

    return result
end

BWOObjects.FindGMD = function (bandit, otype)
    local gmd = GetBWOModData()
    local bx, by = bandit:getX(), bandit:getY()

    local result = {}
    result.dist = math.huge
    result.x = false
    result.y = false
    result.z = false

    local cnt = 0
    if gmd.Objects[otype] then
        for id, object in pairs(gmd.Objects[otype]) do
            local dist = BanditUtils.DistToManhattan(bx, by, object.x, object.y)
            if dist < result.dist then
                result.dist = dist
                result.x = object.x
                result.y = object.y
                result.z = object.z
            end
            cnt = cnt + 1
        end
    end
    
    -- print ("scanned " .. otype .. ": " .. cnt)
    return result
end