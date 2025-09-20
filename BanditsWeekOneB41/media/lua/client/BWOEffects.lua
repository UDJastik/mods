BWOEffects = BWOEffects or {}

BWOEffects.tab = {}
BWOEffects.tick = 0

BWOEffects.Add = function(effect)
    table.insert(BWOEffects.tab, effect)
end

BWOEffects.Process = function()
    
    if isServer() then return end

    BWOEffects.tick = BWOEffects.tick + 1
    if BWOEffects.tick >= 16 then
        BWOEffects.tick = 0
    end

    if BWOEffects.tick % 2 == 0 then return end

    local cell = getCell()
    for i, effect in pairs(BWOEffects.tab) do

        local square = cell:getOrCreateGridSquare(effect.x, effect.y, effect.z+1)
        if square then

            if not effect.repCnt then effect.repCnt = 1 end
            if not effect.rep then effect.rep = 1 end

            if not effect.frame then 

                local dummy = IsoObject.new(square, "")

                dummy:setOffsetX(effect.offset)
                dummy:setOffsetY(effect.offset)
                -- square:AddTileObject(dummy)
                square:AddSpecialObject(dummy)
                if effect.frameRnd then
                    effect.frame = 1 + ZombRand(effect.frameCnt)
                else
                    effect.frame = 1
                end

                effect.object = dummy

            end
            
            if effect.frame > effect.frameCnt and effect.rep >= effect.repCnt then
                square:RemoveTileObject(effect.object)
                BWOEffects.tab[i] = nil
            else
                if effect.frame > effect.frameCnt then
                    effect.rep = effect.rep + 1
                    effect.frame = 1
                end

                -- local frameStr = string.format("%03d", effect.frame)
                -- local alpha = 0.1-- (effect.repCnt - effect.rep + 1) / effect.repCnt
                local sprite = effect.object:getSprite()
                
                if sprite then
                    local spriteName = effect.name .. "_" .. (effect.frame - 1)
                    
                    -- method 1
                    effect.object:setSprite(spriteName)

                    -- method 2
                    -- effect.object:setOverlaySprite(spriteName)
                    -- effect.object:setAttachedAnimSprite(ArrayList.new())

                    -- method 3
                    -- effect.object:getAttachedAnimSprite():add(getSprite(spriteName):newInstance())

                    -- method 4
                    -- effect.object:AttachAnim("Smoke", "03", 4, IsoFireManager.SmokeAnimDelay, 0, 12, true, 0, false, 0.7F, IsoFireManager.SmokeTintMod)

                    -- method b41
                    -- effect.object:setSprite(IsoSprite.new())
                    -- effect.object:getSprite():LoadFramesNoDirPageSimple("media/textures/FX/" .. effect.name .. "/" .. frameStr .. ".png")
                    -- effect.object:setAlpha(0.2)
                    if effect.colors then
                        effect.object:setCustomColor(effect.colors.r, effect.colors.g, effect.colors.b, effect.colors.a)
                    end
                    effect.frame = effect.frame + 1
                    
                    if effect.poison then
                        -- effect.object:setCustomColor(0.1,0.7,0.2, alpha)
                        if effect.frame % 10 == 1 then
                            local actors = BanditZombie.GetAll()
                            for _, actor in pairs(actors) do
                                local dist = math.sqrt(math.pow(actor.x - effect.x, 2) + math.pow(actor.y - effect.y, 2))
                                if dist < 3 then
                                    local character = BanditZombie.GetInstanceById(actor.id)
                                    local outfit = character:getOutfitName()
                                    if outfit ~= "ZSArmySpecialOps" then
                                        character:setHealth(character:getHealth() - 0.12)
                                    end
                                end
                            end
                            local player = getSpecificPlayer(0)
                            local immune = false
                            local mask = player:getWornItem("MaskEyes")
                            if mask then
                                if mask:getFullType() == "Base.Hat_GasMask" then 
                                    immune = true 
                                end
                            end
                            if not immune then
                                local dist = math.sqrt(math.pow(player:getX() - effect.x, 2) + math.pow(player:getY() - effect.y, 2))
                                if dist < 3 then
                                    local bodyDamage = player:getBodyDamage()
                                    local sick = bodyDamage:getFoodSicknessLevel()
                                    bodyDamage:setFoodSicknessLevel(sick + 2)

                                    local stats = player:getStats()
                                    local drunk = stats:getDrunkenness()
                                    stats:setDrunkenness(drunk + 4)
                                end
                            end
                        end
                    end
                end
            end
        else
            BWOEffects.tab[i] = nil
        end
    end
end

local onServerCommand = function(mod, command, args)
    if mod == "BWOEffects" then
        BWOEffects[command](args)
    elseif mod == "Commands" and command == "ZombieRemoveClient" then
        -- Ensure client also drops any local references/caches
        local id = args and args.id
        if id and BanditZombie and BanditZombie.Cache then
            BanditZombie.Cache[id] = nil
            if BanditZombie.CacheLight then BanditZombie.CacheLight[id] = nil end
            if BanditZombie.CacheLightZ then BanditZombie.CacheLightZ[id] = nil end
            if BanditZombie.CacheLightB then BanditZombie.CacheLightB[id] = nil end
        end
    elseif mod == "Commands" and command == "VehicleRemoveClient" then
        -- Hide any client ghost by id or by square lookup
        local id = args and args.id
        local cell = getCell()
        if cell then
            if id then
                local vehicles = cell:getVehicles()
                if vehicles then
                    for i = 0, vehicles:size() - 1 do
                        local v = vehicles:get(i)
                        if v and v:getId() == id then
                            v:setPhysicsActive(false)
                            v:permanentlyRemove()
                            break
                        end
                    end
                end
            end
            -- Fallback by position if still present
            if args and args.x and args.y then
                local square = cell:getGridSquare(args.x, args.y, args.z or 0)
                if square then
                    local v = square:getVehicleContainer()
                    if v then
                        v:setPhysicsActive(false)
                        v:permanentlyRemove()
                    end
                end
            end
        end
    end
end

Events.OnServerCommand.Add(onServerCommand)
Events.OnTick.Add(BWOEffects.Process)