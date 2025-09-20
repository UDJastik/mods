require "SoundFX/SoundFX"

local debug = false

RadioWavs = {}

RadioWavs.soundCache = {}

RadioWavs.files = RadioWavs.files or {}
-- Example
-- RadioWavs.files[1] = "ZenitramJrMuricanaNumber"

RadioWavs.cacheSize = 50			-- number of devices to keep in cache

------------------------------------------------------------------------------------
-- PLAY NEW SONG
------------------------------------------------------------------------------------

function RadioWavs.addSongs(_guid,name)
    RadioWavs.files[_guid] = name
end

function RadioWavs.PlaySound(_guid, device)
    local guid_queue = {}
    if not RadioWavs.files[_guid] then
        if debug then
            print("RadioWavs mod ERROR: sound number ".._guid.." not found! Checking Split")
        end
        for sound in _guid:gmatch("[^+]+") do
            table.insert(guid_queue, sound)
        end
        _guid = table.remove(guid_queue, 1)
    end

    local deviceData = device:getDeviceData()
    local sound = nil
    local ttt = {}
    
    local ttt2 = RadioWavs.getData(deviceData)

    if ttt2 then
        sound = ttt2.sound
        ttt = ttt2
    else
        sound = SoundFX:new()
    end

    if not RadioWavs.files[_guid] then
        if debug then
            print("RadioWavs mod ERROR: sound number ".._guid.." not found!")
        end
        return
    end

    if deviceData:isInventoryDevice() then
        sound:set3D(false)
        sound:setVolumeModifier(0.4)
    elseif deviceData:isIsoDevice() then
        sound:setPosAtObject(device)
        sound:setVolumeModifier(0.4)
    elseif deviceData:isVehicleDevice() then
        local vehiclePart = deviceData:getParent()
        if vehiclePart then
            local vehicle = vehiclePart:getVehicle()
            if vehicle then
                sound:setEmitter( vehicle:getEmitter() ) -- use car's emitter, car radios don't have one
                if vehicle == getSpecificPlayer(0):getVehicle() then -- player is in the car
                    sound:set3D(false)
                    sound:setVolumeModifier(0.4)
                else
                    sound:set3D(true)
                    sound:setVolumeModifier(0.1)
                end
            end
        end
    end

    sound:setVolume( deviceData:getDeviceVolume() )

    local timeMultiplier = UIManager.getSpeedControls():getCurrentGameSpeed()
    sound:emptyQueue()
    
    --Add queue elements
    for _, value in ipairs(guid_queue) do
        if RadioWavs.files[value] then
            sound:addToQueue(value)
        else
            if debug then
                print("RadioWavs mod ERROR: sound number "..value.." not found!")
            end
        end
    end

    if timeMultiplier > 1 then
        sound:play( "FastForward" )
    else
        sound:play( RadioWavs.files[_guid] )
    end

    ttt.device = device
    ttt.deviceData = deviceData
    ttt.channel = deviceData:getChannel()
    ttt.sound = sound

    tickCounter2 = 200

    local test = RadioWavs.soundCache

    table.insert( RadioWavs.soundCache, 1, ttt )
    if #RadioWavs.soundCache>RadioWavs.cacheSize then
        for i=20,#RadioWavs.soundCache do
            table.remove(RadioWavs.soundCache,i)
        end
    end

    return ttt
end


function RadioWavs.split(str,sep)
    local sep, fields = sep or ":", {}
    local pattern = string.format("([^%s]+)", sep)
    str:gsub(pattern, function(c) fields[#fields+1] = c end)
    return fields
end

--rekkie -- original code -- s
--[[
function RadioWavs.OnDeviceText(_interactCodes, _x, _y, _z, _line, _source)
	local codes = RadioWavs.split(_interactCodes, ",")
    local rData = _source:getDeviceData()
    for _,_v in ipairs(codes) do
        if _v:len() > 4 then
            local code = string.sub(_v, 1, 3)
            local op = string.sub(_v, 4, 4)
            local amount = tonumber(string.sub(_v, 5, _v:len()))
            if op=="-" then
            	amount = -amount
        	end
            if amount ~= nil and amount > 0 and code=="DRU" then
                RadioWavs.PlaySound(amount, _source)
            end
        end
    end
end
Events.OnDeviceText.Add( RadioWavs.OnDeviceText )
--]]
--rekkie -- original code -- e

--rekkie -- new code code -- s
function RadioWavs.OnDeviceText( _guid, _interactCodes, _x, _y, _z, _line, _device)
    local radio = _device;

    -- Radio Device: Walkie Talkie
    if radio == nil then
        if (_x==-1 and _y==-1 and _z==-1) then
            local player = getSpecificPlayer(0)
            if player and player:isDead() then player = nil end
            if player ~=nil then
                local items = player:getInventory():getItems();
                for i = 0, items:size()-1 do
                    local item = items:get(i);
                    if instanceof(item, "Radio") and item:getDeviceData() ~= nil then
                        radio = item
                    end
                end
            end
        else
            local sq = getCell():getGridSquare(_x, _y, _z);
            for i=0,sq:getObjects():size() - 1 do
                local item = sq:getObjects():get(i);
                -- Portable/HAM radio or television
                if instanceof(item, "IsoRadio") or instanceof(item, "IsoTelevision") and item:getDeviceData() ~= nil then
                    radio = item
                    break
                end

                -- Vehicle radio
                if instanceof(item, "IsoObject") then
                    local vehicle = sq:getVehicleContainer()
                    if vehicle then
                        local part = vehicle:getPartById("Radio");
                        if part and part:getDeviceData() then
                            radio = part
                            break
                        end
                    end
                end
            end
        end
    end

    -- If device not found (hopefully this never happens) exit out with error notice
    if radio == nil then
        if debug then
            print("RadioWavs mod ERROR: OnDeviceText() could not find radio device")
        end
        return
    end
    -- End Retrocompatibility

    local codes = RadioWavs.split(_interactCodes, ",")

    -- Added support for VHS programs
    if _guid ~= nil and _guid ~= "" then
        RadioWavs.PlaySound(_guid, radio)
    else
        --Where magic happens and audio is played based on codes, a tag that i have to add to the RadioData.xml lines
        for _,_v in ipairs(codes) do
            if _v:len() > 4 then
                local code = string.sub(_v, 1, 4)
                local guid = string.sub(_v, 6, _v:len())
                if guid ~= nil and code=="GUID" then
                    RadioWavs.PlaySound(guid, radio)
                end
            end
        end
    end
end
Events.OnDeviceText.Add( RadioWavs.OnDeviceText )
--rekkie -- new code code -- e

------------------------------------------------------------------------------------
-- INTERACTION OVERRIDES
------------------------------------------------------------------------------------


function RadioWavs.AddOverrides()

    local ISRadioAction_performToggleOnOff = ISRadioAction.performToggleOnOff
    function ISRadioAction:performToggleOnOff()
        ISRadioAction_performToggleOnOff(self)
        local t = RadioWavs.getData(self.deviceData)
        if t then
            if t.deviceData:getIsTurnedOn() and t.deviceData:getChannel() == t.channel then
                t.muted = false
            else
                t.muted = true -- mute sound instead of stopping it, so we can turn it back on
            end
            RadioWavs.updateVolume(t)
        end
    end
    
    local ISRadioAction_performSetChannel = ISRadioAction.performSetChannel
    function ISRadioAction:performSetChannel()
        local t = RadioWavs.getData(self.deviceData)
        if t then
            if t.channel == self.secondaryItem then -- switching back to saved channel
                t.muted = false
            else
                t.muted = true -- mute sound instead of stopping it, so we can switch back to the channel
            end
            RadioWavs.updateVolume(t)
        end
        ISRadioAction_performSetChannel(self)
    end
    
    local ISRadioAction_performSetVolume = ISRadioAction.performSetVolume
    function ISRadioAction:performSetVolume()
        if self:isValidSetVolume() then
            ISRadioAction_performSetVolume(self)
            local t = RadioWavs.getData(self.deviceData)
            if t then
                RadioWavs.updateVolume(t)
            end
        end
    end


    local ISEnterVehicle_perform = ISEnterVehicle.perform
    function ISEnterVehicle:perform()
        ISEnterVehicle_perform(self)
        local t = RadioWavs.getEmitter( self.character:getVehicle():getEmitter() )
        if t then
            t.sound:setVolumeModifier(0.4)
            t.sound:set3D(false) -- no 3d sound while in car, it sounds glitchy
            RadioWavs.updateVolume(t)
        end
    end
    
    local ISExitVehicle_perform = ISExitVehicle.perform
    function ISExitVehicle:perform()
        local t = RadioWavs.getEmitter( self.character:getVehicle():getEmitter() )
        if t then
            t.sound:setVolumeModifier(0.1)
            t.sound:set3D(true)
            RadioWavs.updateVolume(t)
        end
        ISExitVehicle_perform(self)
    end
end
Events.OnGameStart.Add(RadioWavs.AddOverrides)



------------------------------------------------------------------------------------
-- ADJUST SOUNDS BASED ON DISTANCE/STATE
------------------------------------------------------------------------------------


local minRange = 5
local maxRange = 50
local p = nil
local X = 0
local Y = 0
local vehicleEmitter = nil
local dropoffRange = 0
local volumeModifier = 0
local distanceToRadio = 0
local finalVolume = 0
local tickCounter1 = 0
local tickCounter2 = 0

function RadioWavs.adjustSounds()
    -- TODO: tickrates depend on framerate. find something time-based instead
    if tickCounter2 < 1000 then 
        tickCounter2=tickCounter2+1
    else
        p = getSpecificPlayer(0)
        X = p:getX()
        Y = p:getY()
        
        --attract zombies
        --[[
        for _,t in ipairs(RadioWavs.soundCache) do
            if RadioWavs.isPlaying(t) and t.deviceData:getHeadphoneType() == -1 and t.device == t.deviceData:getParent() then
                local range = t.deviceData:getDeviceVolume() * t.sound.volumeModifier*2.5 * maxRange
                if t.deviceData:isInventoryDevice() or t.deviceData:isVehicleDevice() then
                    addSound(p, X, Y, p:getZ(), range/4, range/2)
                else
                    addSound(t.device, t.device:getX()+0.5, t.device:getY()+0.5, t.device:getZ(), range/4, range/2) 
                end
            end
        end
        ]]
        tickCounter2 = 0
    end
    if tickCounter1 < 5 then tickCounter1=tickCounter1+1 return end
    tickCounter1 = 0


    p = getSpecificPlayer(0)
    X = p:getX()
    Y = p:getY()
    highestVolume = 0
    for _,t in ipairs(RadioWavs.soundCache) do
        -- Play Queue
        t.sound:playQueue() 
        -- sync states
        if t.sound and t.sound:isPlaying() then
            if not t.deviceData:isVehicleDevice() and t.device ~= t.deviceData:getParent() then 
                -- device object changed, this happens when the player picks up or places objects. no idea what's up with car radios
                t.device = t.deviceData:getParent() -- update our device reference
                if t.deviceData:isInventoryDevice() then
                    t.sound:set3D(false)
                else
                    t.sound:setPosAtObject(t.device)
                end
            end
            if t.deviceData:isInventoryDevice() and t.deviceData:getIsTurnedOn() and t.device:getType() ~= "CDplayer" then -- make an exception for CDplayer
                if t.device ~= p:getPrimaryHandItem() and t.device ~= p:getSecondaryHandItem() then -- devices only work if equipped & should be switched off otherwise
                    t.deviceData:setIsTurnedOn(false) -- turn device off in case zomboid didn't do so
                elseif t.deviceData:getIsTelevision() then
                    t.deviceData:setIsTurnedOn(false) -- always turn off tele because it's unplugged
                end
            end
            if not t.deviceData:getIsTurnedOn() and not t.muted then -- device was switched off without player action
                t.muted = true -- sync sound accordingly
                RadioWavs.updateVolume(t)
            end
        end
        --adjust volume based on distance
        if RadioWavs.isPlaying(t) then
            if t.deviceData:isInventoryDevice() then
                highestVolume = 1
            else
                if t.device and t.device:getX() and t.device:getY() then
                    distanceToRadio = IsoUtils.DistanceManhatten(t.device:getX(), t.device:getY(), X, Y)
                    if distanceToRadio < maxRange then
                        dropoffRange = (maxRange-minRange)*0.2 + t.deviceData:getDeviceVolume() * t.sound.volumeModifier*2.5 * (maxRange-minRange)*0.8
                        volumeModifier = (minRange + dropoffRange - distanceToRadio) / dropoffRange
                        if volumeModifier < 0 then volumeModifier = 0 end
                        t.sound:setVolume(t.deviceData:getDeviceVolume() * volumeModifier)
                        finalVolume = t.deviceData:getDeviceVolume() * t.sound.volumeModifier * volumeModifier
                        if finalVolume > highestVolume then highestVolume = finalVolume end
                    end
                end
            end
        end
    end
    --adjust Zomboid music volume
    local optionsVolume = getCore():getOptionMusicVolume()/10
    local optionsVolumeModified = optionsVolume - optionsVolume*highestVolume*10
    if optionsVolumeModified < 0 then optionsVolumeModified = 0 end
    getSoundManager():setMusicVolume(optionsVolumeModified)
end
Events.OnTick.Add( RadioWavs.adjustSounds )


function RadioWavs.OnMainMenuEnter()
    --reset Zomboid music volume again
    getSoundManager():setMusicVolume( getCore():getOptionMusicVolume()/10 )
end
Events.OnMainMenuEnter.Add( RadioWavs.OnMainMenuEnter )

------------------------------------------------------------------------------------
-- VARIOUS
------------------------------------------------------------------------------------


function RadioWavs.updateVolume(t)
    if not t.muted then
        t.sound:setVolume( t.deviceData:getDeviceVolume() )
    else
        t.sound:setVolume(0)
    end
end

function RadioWavs.isPlaying(t)
    if not t.deviceData:getIsTurnedOn() then return false end
    if t.muted then return false end
    if t.sound and t.sound:isPlaying() then return true end

    return false
end

function RadioWavs.getData(deviceData)
    for _,t in ipairs(RadioWavs.soundCache) do
        if t.deviceData == deviceData then
            return t
        end
    end
end
function RadioWavs.getEmitter(emitter)
    for _,t in ipairs(RadioWavs.soundCache) do
        if t.sound.emitter == emitter then
            return t
        end
    end
end

return RadioWavs