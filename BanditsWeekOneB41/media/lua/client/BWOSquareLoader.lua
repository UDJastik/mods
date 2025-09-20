BWOSquareLoader = BWOSquareLoader or {}

-- table for objects to be added to the map
BWOSquareLoader.map = {}

-- table for objects to be removed from the map
BWOSquareLoader.remove = {}

-- table of coordinates of location based events
BWOSquareLoader.events = {}

-- table of nuclear strike coordinates
-- BWOSquareLoader.nukes = {}

-- table of protest gathering point coordinates
BWOSquareLoader.protests = {}

-- table of exclusion zones where certain events are removed or modified
BWOSquareLoader.exclusions = {}

-- populating tables
local addBarricadeNorth = function(x1, x2, y)
    for x=x1, x2 do
        local z = 0
        local id 
        local sprite1
        local sprite2
        
        id = x .. "-" .. y .. "-" .. z
        if x % 2 == 0 then
            sprite1 = "fencing_01_88"
        else
            sprite1 = "fencing_01_89"
        end
        BWOSquareLoader.map[id] = {}
        table.insert(BWOSquareLoader.map[id], sprite1)

        id = x .. "-" .. (y - 1) .. "-" .. z
        if x % 3 == 0 then
            sprite2 = "fencing_01_96"
        else
            sprite2 = "carpentry_02_13"
        end
        BWOSquareLoader.map[id] = {}
        table.insert(BWOSquareLoader.map[id], sprite2)
    end
end

local addBarricadeSouth = function(x1, x2, y)
    for x=x1, x2 do
        local z = 0
        local id 
        local sprite1
        local sprite2
    
        id = x .. "-" .. y .. "-" .. z
        if x % 2 == 0 then
            sprite1 = "fencing_01_88"
        else
            sprite1 = "fencing_01_89"
        end
    
        if x % 3 == 0 then
            sprite2 = "fencing_01_96"
        else
            sprite2 = "carpentry_02_13"
        end
        BWOSquareLoader.map[id] = {}
        table.insert(BWOSquareLoader.map[id], sprite1)
        table.insert(BWOSquareLoader.map[id], sprite2)
    end
end

local addBarricadeWest = function(y1, y2, x)
    for y=y1, y2 do
        local z = 0
        local id 
        local sprite
        
        id = x .. "-" .. y .. "-" .. z
        if y % 2 == 0 then
            sprite = "fencing_01_90"
        else
            sprite = "fencing_01_91"
        end
        BWOSquareLoader.map[id] = {}
        table.insert(BWOSquareLoader.map[id], sprite)
    
        id = (x - 1) .. "-" .. y .. "-" .. z
        if y % 3 == 0 then
            sprite = "fencing_01_96"
        else
            sprite = "carpentry_02_12"
        end
        BWOSquareLoader.map[id] = {}
        table.insert(BWOSquareLoader.map[id], sprite)
    end
end

local addBarricadeEast = function(y1, y2, x)
    for y=y1, y2 do
        local z = 0
        local id 
        local sprite1
        local sprite2
    
        id = x .. "-" .. y .. "-" .. z
        if y % 2 == 0 then
            sprite1 = "fencing_01_90"
        else
            sprite1 = "fencing_01_91"
        end

        if y % 3 == 0 then
            sprite2 = "fencing_01_96"
        else
            sprite2 = "carpentry_02_12"
        end
        BWOSquareLoader.map[id] = {}
        table.insert(BWOSquareLoader.map[id], sprite1)
        table.insert(BWOSquareLoader.map[id], sprite2)
    end
end

-- muldrough road blocks
addBarricadeSouth(10576, 10602, 10679)
table.insert(BWOSquareLoader.events, {phase="ArmyGuards", x=10592, y=10675, z=0})

for i = 0, 14 do
    table.insert(BWOSquareLoader.events, {phase="AbandonedVehicle", x=10587, y=10660 - (i * 6), z=0, dir=IsoDirections.S}) 
end

for i = 0, 3 do
    table.insert(BWOSquareLoader.events, {phase="AbandonedVehicle", x=10597, y=10685 + (i * 6), z=0, dir=IsoDirections.N})
end

addBarricadeSouth(10775, 10805, 10715)
table.insert(BWOSquareLoader.events, {phase="ArmyGuards", x=10790, y=10706, z=0})

addBarricadeWest(9306, 9329, 11097)
table.insert(BWOSquareLoader.events, {phase="ArmyGuards", x=11091, y=9317, z=0})

addBarricadeNorth(10950, 10970, 8928)
table.insert(BWOSquareLoader.events, {phase="ArmyGuards", x=10962, y=8932, z=0})

addBarricadeNorth(10570, 10608, 9148)
table.insert(BWOSquareLoader.events, {phase="ArmyGuards", x=10591, y=9152, z=0})

for i = 0, 4 do
    table.insert(BWOSquareLoader.events, {phase="AbandonedVehicle", x=10587, y=9140 - (i * 6), z=0, dir=IsoDirections.S}) 
end

for i = 0, 10 do
    table.insert(BWOSquareLoader.events, {phase="AbandonedVehicle", x=10597, y=9153 + (i * 6), z=0, dir=IsoDirections.N})
end

addBarricadeEast(9726, 9744, 10576)
table.insert(BWOSquareLoader.events, {phase="ArmyGuards", x=10579, y=9736, z=0})

-- march ridge road blocks
addBarricadeNorth(10345, 10380, 12414)
table.insert(BWOSquareLoader.events, {phase="ArmyGuards", x=10361, y=12419, z=0})
table.insert(BWOSquareLoader.events, {phase="ArmyGuards", x=10363, y=12397, z=0})

-- dixie
addBarricadeWest(8750, 8776, 11400)
table.insert(BWOSquareLoader.events, {phase="ArmyGuards", x=11405, y=8764, z=0})

addBarricadeNorth(11628, 11656, 8690)
table.insert(BWOSquareLoader.events, {phase="ArmyGuards", x=11643, y=8694, z=0})

-- westpoint
addBarricadeSouth(11680, 11750, 7157)
table.insert(BWOSquareLoader.events, {phase="ArmyGuards", x=11753, y=7182, z=0})

addBarricadeWest(7157, 7200, 11750)
table.insert(BWOSquareLoader.events, {phase="ArmyGuards", x=11708, y=7147, z=0})

addBarricadeWest(6890, 6925, 11090)
table.insert(BWOSquareLoader.events, {phase="ArmyGuards", x=11094, y=6900, z=0})

addBarricadeEast(7159, 7205, 12172)
table.insert(BWOSquareLoader.events, {phase="ArmyGuards", x=12165, y=7182, z=0})

addBarricadeEast(6890, 6908, 12172)
table.insert(BWOSquareLoader.events, {phase="ArmyGuards", x=12166, y=6899, z=0})

-- riverside
addBarricadeEast(5440, 5500, 7000)
addBarricadeSouth(6515, 6540, 5615)
addBarricadeSouth(5872, 5888, 5460)
addBarricadeWest(5385, 5394, 5710)

-- military base
addBarricadeEast(12478, 12491, 5823)

-- remove fence in westpoint gunshop
BWOSquareLoader.remove["12072-6759-0"] = {}
BWOSquareLoader.remove["12072-6760-0"] = {}

-- outofgas signs
BWOSquareLoader.remove["10615-9768-0"] = {}
BWOSquareLoader.remove["10615-9766-0"] = {}
BWOSquareLoader.remove["10642-10628-0"] = {}

-- protests
local protests = {}
table.insert(protests, {x=10590, y=10670, z=0}) --muldraugh n blockade
table.insert(protests, {x=10590, y=9172, z=0}) --muldraugh s blockade
table.insert(protests, {x=10590, y=9737, z=0}) --muldraugh middle road
table.insert(protests, {x=10653, y=9940, z=0}) --muldraugh cafeteria, liquorstore, slothing store complex
table.insert(protests, {x=10740, y=10340, z=0}) --muldraugh offices
table.insert(protests, {x=10760, y=10160, z=0}) --muldraugh church
table.insert(protests, {x=10634, y=10431, z=0}) --muldraugh police
table.insert(protests, {x=12160, y=6900, z=0}) --westpoint e traintack
table.insert(protests, {x=12050, y=6883, z=0}) --westpoint gigamart
table.insert(protests, {x=11955, y=6805, z=0}) --westpoint spiffos
table.insert(protests, {x=11927, y=6893, z=0}) --westpoint townhall
table.insert(protests, {x=11933, y=6871, z=0}) --westpoint townhall inside
table.insert(protests, {x=11109, y=6898, z=0}) --westpoint barricade w
table.insert(protests, {x=11920, y=6963, z=0}) --westpoint police
table.insert(protests, {x=6992, y=5468, z=0}) --riverside blockade e
table.insert(protests, {x=6399, y=5427, z=0}) --riverside school
table.insert(protests, {x=6381, y=5283, z=0}) --riverside central road
table.insert(protests, {x=6090, y=5280, z=0}) --riverside police
table.insert(protests, {x=6545, y=5261, z=0}) --riverside community centre
table.insert(protests, {x=5881, y=5445, z=0}) --riverside blockade w
table.insert(protests, {x=8100, y=11740, z=0}) --rosewood police
table.insert(protests, {x=8100, y=11645, z=0}) --rosewood court of justice
table.insert(protests, {x=8093, y=11363, z=0}) --rosewood spiffos
table.insert(protests, {x=8313, y=15583, z=0}) --rosewood school
table.insert(protests, {x=10362, y=12416, z=0}) --marchridge exit
table.insert(protests, {x=10007, y=12692, z=0}) --marchridge crossroads
table.insert(protests, {x=10326, y=12768, z=0}) --marchridge church
table.insert(protests, {x=12611, y=1522, z=0}) --louisville country clerk / city hall
table.insert(protests, {x=12506, y=1800, z=0}) --lmbw radio
table.insert(protests, {x=12964, y=1357, z=0}) --police station
table.insert(protests, {x=13790, y=2560, z=0}) --police station
table.insert(protests, {x=13220, y=3105, z=0}) --police station
table.insert(protests, {x=12500, y=1571, z=0}) --police station / courthhouse

BWOSquareLoader.protests = protests

-- mechanic cars - since b42 we can spawn cars in buildings - yay

table.insert(BWOSquareLoader.events, {phase="CarMechanic", x=5467, y=9652, z=0, dir=IsoDirections.E}) -- riverside
table.insert(BWOSquareLoader.events, {phase="CarMechanic", x=5467, y=9661, z=0, dir=IsoDirections.E}) -- riverside
table.insert(BWOSquareLoader.events, {phase="CarMechanic", x=10610, y=9405, z=0, dir=IsoDirections.E}) -- muldraugh
table.insert(BWOSquareLoader.events, {phase="CarMechanic", x=10610, y=9410, z=0, dir=IsoDirections.E}) -- muldraugh
table.insert(BWOSquareLoader.events, {phase="CarMechanic", x=10179, y=10936, z=0, dir=IsoDirections.W}) -- muldraugh
table.insert(BWOSquareLoader.events, {phase="CarMechanic", x=10179, y=10945, z=0, dir=IsoDirections.W}) -- muldraugh
table.insert(BWOSquareLoader.events, {phase="CarMechanic", x=5430, y=5960, z=0, dir=IsoDirections.E}) -- riverside
table.insert(BWOSquareLoader.events, {phase="CarMechanic", x=5430, y=5964, z=0, dir=IsoDirections.E}) -- riverside
table.insert(BWOSquareLoader.events, {phase="CarMechanic", x=8151, y=11322, z=0, dir=IsoDirections.W}) -- rosewood
table.insert(BWOSquareLoader.events, {phase="CarMechanic", x=8151, y=11331, z=0, dir=IsoDirections.W}) -- rosewood
table.insert(BWOSquareLoader.events, {phase="CarMechanic", x=11897, y=6809, z=0, dir=IsoDirections.N}) -- westpoint
table.insert(BWOSquareLoader.events, {phase="CarMechanic", x=12274, y=6927, z=0, dir=IsoDirections.W}) -- westpoint
table.insert(BWOSquareLoader.events, {phase="CarMechanic", x=12274, y=6934, z=0, dir=IsoDirections.W}) -- westpoint

-- building emitters
table.insert(BWOSquareLoader.events, {phase="Emitter", x=13458, y=3043, z=0, len=110000, sound="ZSBuildingGigamart"}) -- gigamart lousville 
table.insert(BWOSquareLoader.events, {phase="Emitter", x=6505, y=5345, z=0, len=110000, sound="ZSBuildingGigamart"}) -- gigamart riverside
table.insert(BWOSquareLoader.events, {phase="Emitter", x=12024, y=6856, z=0, len=110000, sound="ZSBuildingGigamart"}) -- gigamart westpoint

table.insert(BWOSquareLoader.events, {phase="Emitter", x=6472, y=5266, z=0, len=42000, sound="ZSBuildingPharmabug"}) -- pharmabug riverside
table.insert(BWOSquareLoader.events, {phase="Emitter", x=13235, y=1284, z=0, len=42000, sound="ZSBuildingPharmabug"}) -- pharmabug lv
table.insert(BWOSquareLoader.events, {phase="Emitter", x=13120, y=2126, z=0, len=42000, sound="ZSBuildingPharmabug"}) -- pharmabug lv
table.insert(BWOSquareLoader.events, {phase="Emitter", x=11932, y=6804, z=0, len=42000, sound="ZSBuildingPharmabug"}) -- pharmabug westpoint

table.insert(BWOSquareLoader.events, {phase="Emitter", x=12228, y=3029, z=0, len=62000, sound="ZSBuildingZippee"}) -- zippee market lv
table.insert(BWOSquareLoader.events, {phase="Emitter", x=12998, y=3115, z=0, len=62000, sound="ZSBuildingZippee"}) -- zippee market lv
table.insert(BWOSquareLoader.events, {phase="Emitter", x=13065, y=1923, z=0, len=62000, sound="ZSBuildingZippee"}) -- zippee market lv
table.insert(BWOSquareLoader.events, {phase="Emitter", x=12660, y=1366, z=0, len=62000, sound="ZSBuildingZippee"}) -- zippee market lv
table.insert(BWOSquareLoader.events, {phase="Emitter", x=13523, y=1670, z=0, len=62000, sound="ZSBuildingZippee"}) -- zippee market lv
table.insert(BWOSquareLoader.events, {phase="Emitter", x=12520, y=1482, z=0, len=62000, sound="ZSBuildingZippee"}) -- zippee market lv
table.insert(BWOSquareLoader.events, {phase="Emitter", x=12646, y=2290, z=0, len=62000, sound="ZSBuildingZippee"}) -- zippee market lv
table.insert(BWOSquareLoader.events, {phase="Emitter", x=10604, y=9612, z=0, len=62000, sound="ZSBuildingZippee"}) -- zippee market muldraugh
table.insert(BWOSquareLoader.events, {phase="Emitter", x=8088, y=11560, z=0, len=62000, sound="ZSBuildingZippee"}) -- zippee market rosewood
table.insert(BWOSquareLoader.events, {phase="Emitter", x=13656, y=5764, z=0, len=62000, sound="ZSBuildingZippee"}) -- zippee market valley station
table.insert(BWOSquareLoader.events, {phase="Emitter", x=11660, y=7067, z=0, len=62000, sound="ZSBuildingZippee"}) -- zippee market west point

table.insert(BWOSquareLoader.events, {phase="Emitter", x=10619, y=10527, z=0, len=73700, sound="ZSBuildingRestaurant"}) -- restaurant muldraugh
table.insert(BWOSquareLoader.events, {phase="Emitter", x=10605, y=10112, z=0, len=73700, sound="ZSBuildingRestaurant"}) -- pizza whirled muldraugh
table.insert(BWOSquareLoader.events, {phase="Emitter", x=10647, y=9927, z=0, len=73700, sound="ZSBuildingRestaurant"}) -- cafeteria muldraugh
table.insert(BWOSquareLoader.events, {phase="Emitter", x=10615, y=9646, z=0, len=73700, sound="ZSBuildingRestaurant"}) -- spiffos muldraugh
table.insert(BWOSquareLoader.events, {phase="Emitter", x=10616, y=9565, z=0, len=73700, sound="ZSBuildingRestaurant"}) -- jays muldraugh
table.insert(BWOSquareLoader.events, {phase="Emitter", x=10620, y=9513, z=0, len=73700, sound="ZSBuildingRestaurant"}) -- pileocrepe muldraugh
table.insert(BWOSquareLoader.events, {phase="Emitter", x=12078, y=7076, z=0, len=73700, sound="ZSBuildingRestaurant"}) -- burgers westpoint
table.insert(BWOSquareLoader.events, {phase="Emitter", x=11976, y=6812, z=0, len=73700, sound="ZSBuildingRestaurant"}) -- spiffos westpoint
table.insert(BWOSquareLoader.events, {phase="Emitter", x=11930, y=6917, z=0, len=73700, sound="ZSBuildingRestaurant"}) -- restaurant westpoint
table.insert(BWOSquareLoader.events, {phase="Emitter", x=11663, y=7085, z=0, len=73700, sound="ZSBuildingRestaurant"}) -- pizza whirled westpoint
table.insert(BWOSquareLoader.events, {phase="Emitter", x=6395, y=5303, z=0, len=73700, sound="ZSBuildingRestaurant"}) -- restaurant riverside
table.insert(BWOSquareLoader.events, {phase="Emitter", x=6189, y=5338, z=0, len=73700, sound="ZSBuildingRestaurant"}) -- fancy restaurant riverside
table.insert(BWOSquareLoader.events, {phase="Emitter", x=6121, y=5303, z=0, len=73700, sound="ZSBuildingRestaurant"}) -- spiffos riverside
table.insert(BWOSquareLoader.events, {phase="Emitter", x=5422, y=5914, z=0, len=73700, sound="ZSBuildingRestaurant"}) -- diner riverside
table.insert(BWOSquareLoader.events, {phase="Emitter", x=7232, y=8202, z=0, len=73700, sound="ZSBuildingRestaurant"}) -- burger joint doe valley
table.insert(BWOSquareLoader.events, {phase="Emitter", x=10103, y=12749, z=0, len=73700, sound="ZSBuildingRestaurant"}) -- restaurant march ridge 
table.insert(BWOSquareLoader.events, {phase="Emitter", x=8076, y=11455, z=0, len=73700, sound="ZSBuildingRestaurant"}) -- restaurant rosewood
table.insert(BWOSquareLoader.events, {phase="Emitter", x=8072, y=11344, z=0, len=73700, sound="ZSBuildingRestaurant"}) -- spiffos rosewood

-- non-stop party buildings

-- LV strip club
table.insert(BWOSquareLoader.events, {phase="BuildingParty", x=12320, y=1279, z=0, intensity=10, roomName="stripclub"})

-- GUNSHOP GUARDS
table.insert(BWOSquareLoader.events, {phase="GunshopGuard", x=12065, y=6762, z=0})

-- MILITARY BASE FINALE SETUP

-- exclusion zones
table.insert(BWOSquareLoader.exclusions, {x1=5000, y1=12000, x2=6200, y2=13000}) -- military research lab

-- alarm emitters
table.insert(BWOSquareLoader.events, {phase="Emitter", x=5572, y=12489, z=0, len=2460, sound="ZSBuildingBaseAlert", light={r=1, g=0, b=0, t=10}}) -- fake control room
table.insert(BWOSquareLoader.events, {phase="Emitter", x=5575, y=12473, z=0, len=2460, sound="ZSBuildingBaseAlert", light={r=1, g=0, b=0, t=10}}) -- entrance
table.insert(BWOSquareLoader.events, {phase="Emitter", x=5562, y=12464, z=0, len=2460, sound="ZSBuildingBaseAlert", light={r=1, g=0, b=0, t=10}}) -- back

-- defender teams
table.insert(BWOSquareLoader.events, {phase="BaseDefenders", x=5572, y=12489, z=0, intensity = 2}) -- control room
table.insert(BWOSquareLoader.events, {phase="BaseDefenders", x=5582, y=12486, z=0, intensity = 3}) -- entrance in
table.insert(BWOSquareLoader.events, {phase="BaseDefenders", x=5582, y=12480, z=0, intensity = 3}) -- entrance in
table.insert(BWOSquareLoader.events, {phase="BaseDefenders", x=5586, y=12483, z=0, intensity = 2}) -- entrance out
table.insert(BWOSquareLoader.events, {phase="BaseDefenders", x=5573, y=12484, z=0, intensity = 1}) -- door
table.insert(BWOSquareLoader.events, {phase="BaseDefenders", x=5609, y=12483, z=0, intensity = 4}) -- gateway
table.insert(BWOSquareLoader.events, {phase="BaseDefenders", x=5833, y=12490, z=0, intensity = 2}) -- booth
table.insert(BWOSquareLoader.events, {phase="BaseDefenders", x=5831, y=12484, z=0, intensity = 4}) -- szlaban
table.insert(BWOSquareLoader.events, {phase="BaseDefenders", x=5530, y=12489, z=0, intensity = 5}) -- back
-- table.insert(BWOSquareLoader.events, {phase="BaseDefenders", x=5558, y=12447, z=-16, intensity = 3}) -- underground armory

-- checks if a point is inside any exclusion zone
BWOSquareLoader.IsInExclusion = function(x, y)
    for _, exclusion in pairs(BWOSquareLoader.exclusions) do
        if x > exclusion.x1 and x < exclusion.x2 and y > exclusion.y1 and y < exclusion.y2 then
            return true
        end
    end
    return false
end

BWOSquareLoader.Burn = function(square)

    if square:getZ() < 0 then return end

    square:BurnWalls(false)
    local md = square:getModData()
    if not md.BWO then md.BWO = {} end
    md.BWO.burnt = true

    if BanditUtils.HasZoneType(square:getX(), square:getY(), square:getZ(), "Nav") then
        local objects = square:getObjects()
        for i=0, objects:size()-1 do
            local object = objects:get(i)
            local sprite = object:getSprite()
            if sprite then
                local spriteName = sprite:getName()
                if spriteName and spriteName:embodies("street") then
                    local rn = ZombRand(8)
                    local overlaySprite
                    if rn < 2  then
                        overlaySprite = "floors_overlay_street_01_" .. ZombRand(44)
                    elseif rn == 2 then
                        overlaySprite = "blends_streetoverlays_01_" .. ZombRand(32)
                    end
                    if overlaySprite then
                        local attachments = object:getAttachedAnimSprite()
                        if not attachments or attachments:size() == 0 then
                            object:setAttachedAnimSprite(ArrayList.new())
                        end
                        object:getAttachedAnimSprite():add(getSprite(overlaySprite):newInstance())
                    end
                    break
                end
            end
        end
    elseif BanditUtils.HasZoneType(square:getX(), square:getY(), square:getZ(), "TownZone") then
        local rnd = ZombRand(10)
        if rnd == 1 then
            local obj = IsoObject.new(square, "floors_burnt_01_1", "")
            square:AddSpecialObject(obj)
            obj:transmitCompleteItemToClients()
        elseif rnd == 2 or rnd == 3 then
            local rn = ZombRand(54)
            local sprite = "trash_01_" .. tostring(rn)
            local obj = IsoObject.new(square, sprite, "")
            square:AddSpecialObject(obj)
            obj:transmitCompleteItemToClients()
        end
    end
end

local spriteMap = {}
spriteMap["location_business_bank_01_64"] = "atm"
spriteMap["location_business_bank_01_65"] = "atm"
spriteMap["location_business_bank_01_66"] = "atm"
spriteMap["location_business_bank_01_67"] = "atm"
spriteMap["street_decoration_01_18"] = "mailbox"
spriteMap["street_decoration_01_19"] = "mailbox"
spriteMap["street_decoration_01_20"] = "mailbox"
spriteMap["street_decoration_01_21"] = "mailbox"
BWOSquareLoader.spriteMap = spriteMap

local customNameMap = {}
customNameMap["Flowerbed"] = "flowerbed"
customNameMap["Trash"] = "trash"
customNameMap["Bench"] = "sittable"
customNameMap["Chair"] = "sittable"
BWOSquareLoader.customNameMap = customNameMap

-- updates square to implement prepandemic world and manage add/remove objects
BWOSquareLoader.OnLoad = function(square)

    local clearObjects = function(square)
        local objects = square:getObjects()
        local destroyList = {}
        local legalSprites = {}
        table.insert(legalSprites, "fencing_01_88")
        table.insert(legalSprites, "fencing_01_90")
        table.insert(legalSprites, "fencing_01_90")
        table.insert(legalSprites, "fencing_01_91")
        table.insert(legalSprites, "carpentry_02_13")
        table.insert(legalSprites, "carpentry_02_12")
        table.insert(legalSprites, "fencing_01_96")
    
        for i=0, objects:size()-1 do
            local object = objects:get(i)
            if object then
                local sprite = object:getSprite()
                if sprite then 
                    local spriteName = sprite:getName()
                    local spriteProps = sprite:getProperties()
    
                    local isSolidFloor = spriteProps:Is(IsoFlagType.solidfloor)
                    local isAttachedFloor = spriteProps:Is(IsoFlagType.attachedFloor)
    
                    isLegalSprite = false
                    --[[
                    for _, sp in pairs(legalSprites) do
                        if sp == spriteName then
                            isLegalSprite = true
                            break
                        end
                    end
                    ]]
    
                    if not isSolidFloor and not isLegalSprite then
                        table.insert(destroyList, object)
                    end
                end
            end
        end
    
        for k, obj in pairs(destroyList) do
            if isClient() then
                sledgeDestroy(obj);
            else
                square:transmitRemoveItemFromSquare(obj)
            end
        end
    end

    local addObject = function(square, objectList)
        for _, sprite in pairs(objectList) do
            local obj = IsoObject.new(square, sprite, "")
            square:AddSpecialObject(obj)
            obj:transmitCompleteItemToServer()
            print ("added")
        end
    end

    local isInCircle = function(x, y, cx, cy, r)
        local d2 = ((x - cx) * (x - cx)) + ((y - cy) * (y - cy))
        return d2 <= r * r
    end

    function bxor(a, b)
        local result = 0
        local bitval = 1
        while a > 0 or b > 0 do
            local abit, bbit = a % 2, b % 2
            if abit ~= bbit then
                result = result + bitval
            end
            a = math.floor(a / 2)
            b = math.floor(b / 2)
            bitval = bitval * 2
        end
        return result
    end
    
    function hash(x, y, seed)
        return (bxor(x * 73856093, bxor(y * 19349663, seed * 83492791))) % 1000000
    end
    
    function shouldPlaceCorpse(x, y, density, seed)
        local threshold = density * 1000000  -- Scale density to hash range
        return hash(x, y, seed) < threshold
    end

    local map = BWOSquareLoader.map
    local remove = BWOSquareLoader.remove
    local spriteMap = BWOSquareLoader.spriteMap
    local customNameMap = BWOSquareLoader.customNameMap

	local x = square:getX()
    local y = square:getY()
    local z = square:getZ()
    local md = square:getModData()
    if not md.BWO then md.BWO = {} end

    local id = x .. "-" .. y .. "-" .. z

    -- spawn map objects
    if map[id] then
        clearObjects(square)
        addObject(square, map[id])
        BWOSquareLoader.map[id] = nil
    end

    -- remove map objects
    if BWOScheduler.World.ObjectRemover then
        if remove[id] then
            clearObjects(square)
            BWOSquareLoader.remove[id] = nil
        end
    end

    -- remove deadbodies
    if BWOScheduler.World.DeadBodyRemover then
        local corpse = square:getDeadBody()
        local gmd = GetBWOModData()
        local id = x .. "-" .. y .. "-" .. z
        if corpse and not gmd.DeadBodies[id] then
            -- local args = {x=x, y=y, z=z}
            -- sendClientCommand(getSpecificPlayer(0), 'Commands', 'DeadBodyAdd', args)
            square:removeCorpse(corpse, true)
            -- sq:AddWorldInventoryItem(corpse:getItem(), 0.5, 0.5, 0)
        end

        if square:haveBlood() then
            square:removeBlood(false, false)
        end
    end
    
    local objects = square:getObjects()
    for i=0, objects:size()-1 do
        local object = objects:get(i)
        local sprite = object:getSprite()
        if sprite then
            local props = sprite:getProperties()

            -- register global objects
            if BWOScheduler.World.GlobalObjectAdder then

                if instanceof(object, "IsoBarbecue") and square:isOutside() then
                    local args = {x=x, y=y, z=z, otype="barbecue"}
                    local player = getPlayer()
                    sendClientCommand(player, 'Commands', 'ObjectAdd', args)
                    break
                end

                local attachments = object:getAttachedAnimSprite()
                if attachments then
                    for i=0, attachments:size()-1 do
                        local attachment = attachments:get(i)
                        if attachment and (attachment:getName():embodies("blood") or attachment:getName():embodies("grime")) then
                            object:clearAttachedAnimSprite()
                            break
                        end
                    end
                end

                local spriteName = sprite:getName()
                if spriteMap[spriteName] and square:isOutside() then 
                    local args = {x=x, y=y, z=z, otype=spriteMap[spriteName]}
                    local player = getPlayer()
                    sendClientCommand(player, 'Commands', 'ObjectAdd', args)
                    break
                end

                if props:Is("CustomName") then
                    local customName = props:Val("CustomName")
                    if customNameMap[customName] and square:isOutside() then 
                        local args = {x=x, y=y, z=z, otype=customNameMap[customName]}
                        local player = getPlayer()
                        sendClientCommand(player, 'Commands', 'ObjectAdd', args)
                        break
                    end
                end

                -- this makes npcs disregard windows for pathfinding
                -- unfortunately will impact zombies aswell
                if instanceof(object, "IsoWindow") or instanceof(object, "IsoWindowFrame") then
                    if props:Is(IsoFlagType.canPathN) then
                        props:UnSet(IsoFlagType.canPathN)
                    end
                    if props:Is(IsoFlagType.canPathW) then
                        props:UnSet(IsoFlagType.canPathW)
                    end
                    
                    props:UnSet(IsoFlagType.WindowN)
                    props:UnSet(IsoFlagType.WindowW)
                end
            else
                -- restore window behavior
                if instanceof(object, "IsoWindow") or instanceof(object, "IsoWindowFrame") then
                    if props:Is(IsoFlagType.cutN) then
                        props:Set(IsoFlagType.canPathN)
                        props:Set(IsoFlagType.WindowN)
                    elseif props:Is(IsoFlagType.cutW) then
                        props:Set(IsoFlagType.canPathW)
                        props:Set(IsoFlagType.WindowW)
                    end
                end
            end
        end
    end

    -- dead body placer
    if BWOScheduler.World.DeadBodyAdderDensity and BWOScheduler.World.DeadBodyAdderDensity > 0 then

        if not md.BWO.dbs then
            local seed = 12345
            if BanditUtils.HasZoneType(x, y, z, "TownZone") then
                local density = BWOScheduler.World.DeadBodyAdderDensity

                local zone = square:getZone()
                local multiplier = 0
                if zone then
                    local zoneType = zone:getType()
                    if zoneType then
                        if zoneType == "TownZone" or zoneType == "TrailerPark" then
                            multiplier = 1
                        elseif zoneType == "Farm" or zoneType == "Ranch" then
                            multiplier = 0.6
                        elseif zoneType == "Nav" then
                            multiplier = 0.3
                        elseif zoneType == "Vegitation" then
                            multiplier = 0.1
                        end
                    end
                end
                density = density * multiplier

                if not square:isOutside() then density = density * 8 end

                if density > 0 and shouldPlaceCorpse(x, y, density, seed) then
                    local outfit = BanditUtils.Choice({"Generic01", "Generic02", "Generic03", "Generic04", "Generic05", "Generic05", "Classy", "IT", "Student", "Teacher", "Police", "Young"})
                    local zombieList = BanditCompatibility.AddZombiesInOutfit(x, y, z, outfit, 50, false, false, false, false, false, false, 2)
                    for i=0, zombieList:size()-1 do
                        -- print ("place body at x:" .. x .. " y:" .. y)
                        local zombie = zombieList:get(i)
                        local banditVisuals = zombie:getHumanVisual()
                        local id = BanditUtils.GetCharacterID(zombie)
                        local r = 1 + math.abs(id) % 5 
                        if zombie:isFemale() then
                            banditVisuals:setSkinTextureName("FemaleBody0" .. tostring(r))
                        else
                            banditVisuals:setSkinTextureName("MaleBody0" .. tostring(r))
                        end
                        zombie:Kill(nil)
                    end
                end
            end
        end
    end

    -- post nuke world destroyer
    if BWOScheduler.World.PostNuclearTransformator then
        if not md.BWO.burnt then
            local gmd = GetBWOModData()
            local nukes = gmd.Nukes
            -- local nukes = BWOSquareLoader.nukes
            for _, nuke in pairs(nukes) do
                if isInCircle(x, y, nuke.x, nuke.y, nuke.r) then
                    BWOSquareLoader.Burn(square)
                    local vehicle = square:getVehicleContainer()
                    if vehicle then
                        BWOVehicles.Burn(vehicle)
                    end
                end
            end
            md.BWO.burnt = true
        end
    end
    md.BWO.dbs = true
end

-- spawns location events when player is near
BWOSquareLoader.LocationEvents = function(ticks)
    if ticks % 10 > 0 then return end

    local tab = BWOSquareLoader.events
    local player = getPlayer()
    local cell = getCell()
    for i, event in pairs(tab) do
        local square = cell:getGridSquare(event.x, event.y, event.z)
        if square then
            if BanditUtils.DistToManhattan(player:getX(), player:getY(), event.x, event.y) < 70 then
                if BWOEventsPlace[event.phase] then
                    BWOEventsPlace[event.phase](event)
                end
                table.remove(BWOSquareLoader.events, i)
                break
            end
        end
    end
end

-- removes burnt / smashed vehicles
-- apparently vehicle loading is deffered relative to square load, so this needs to be handled separately
BWOSquareLoader.VehicleFixOrRemove = function()
    if not BWOScheduler.World.VehicleFixer then return end

    local vehicleList = getCell():getVehicles()
    local toDelete = {}
    for i=0, vehicleList:size()-1 do
        local vehicle = vehicleList:get(i)
        if vehicle then
            local md = vehicle:getModData()
            if not md.BWO then md.BWO = {} end

            if not md.BWO.wasRepaired then
                local scriptName = vehicle:getScriptName()
                local engine = vehicle:getPartById("Engine")
                if scriptName:embodies("Burnt") or scriptName:embodies("Smashed") or not engine or engine:getCondition() < 50 then
                    table.insert(toDelete, vehicle)
                else
                    BWOVehicles.Repair(vehicle)
                    vehicle:removeKeyFromDoor()
                    vehicle:removeKeyFromIgnition()
                    vehicle:setTrunkLocked(true)
                    for i=0, vehicle:getMaxPassengers() - 1 do 
                        local part = vehicle:getPassengerDoor(i)
                        if part then 
                            local door = part:getDoor()
                            if door then
                                door:setLocked(true)
                            end
                        end
                    end

                    if ZombRand(12) == 0 then
                        vehicle:addKeyToGloveBox()
                    end

                    local key = vehicle:getCurrentKey()
                    if not key then 
                        key = vehicle:createVehicleKey()
                    end

                    if key then
                        local result = BanditUtils.GetClosestBanditVehicle(vehicle)
                        if result.id then
                            local bandit = BanditZombie.GetInstanceById(result.id)
                            if bandit then
                                local inventory = bandit:getInventory()
                                inventory:AddItem(key)
                                Bandit.UpdateItemsToSpawnAtDeath(bandit)
                            end
                        end
                    end

                    md.BWO.wasRepaired = true
                end
            end
        end
    end

    for _, vehicle in pairs(toDelete) do
        -- Request authoritative removal on server to avoid client-only flicker
        local player = getSpecificPlayer(0)
        local args = { id = vehicle:getId() }
        local sq = vehicle:getSquare()
        if sq then args.x = sq:getX(); args.y = sq:getY(); args.z = sq:getZ() end
        sendClientCommand(player, 'Commands', 'VehicleRemove', args)
    end
end

BWOSquareLoader.OnNewFire = function(fire)
    local params ={}
    params.x = fire:getX()
    params.y = fire:getY()
    params.z = fire:getZ()
    params.hostile = true
    BWOScheduler.Add("CallFireman", params, 4800)

    local args = {x=params.x, y=params.y, z=params.z, otype="fire", ttl=BanditUtils.GetTime()+25000}
    local player = getPlayer()
    sendClientCommand(player, 'Commands', 'ObjectAdd', args)
end

Events.LoadGridsquare.Add(BWOSquareLoader.OnLoad)
Events.OnTick.Add(BWOSquareLoader.LocationEvents)
Events.EveryOneMinute.Add(BWOSquareLoader.VehicleFixOrRemove)
Events.OnNewFire.Add(BWOSquareLoader.OnNewFire)