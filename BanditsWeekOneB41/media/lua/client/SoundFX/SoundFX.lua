SoundFX = {
    emitter = nil,
    id = nil,
    x = 0,
    y = 0,
    z = 0,
    volume = 1,
    volumeModifier = 1,
    sound3D = false,
    soundQueue = {},
}

function SoundFX:new()
    local o = {}
	setmetatable(o, self)
    self.__index = self
	return o
end


function SoundFX:setEmitter(emitter)
    self.emitter = emitter
end

function SoundFX:play(sound)
    local hasEmitter = self.emitter
    local hadId = self.id
    
    if hasEmitter then
        if self.emitter:isPlaying("FastForward") == false or (self.emitter:isPlaying("FastForward") and sound ~= "FastForward") then --Stop audio that is not FastForward clip
            self:stop()
        end
    else
        self.emitter = IsoWorld.instance:getFreeEmitter()
        self.emitter:setPos(self.x, self.y, self.z)
    end
    if self.emitter:isPlaying("FastForward") == false or (self.emitter:isPlaying("FastForward") and sound ~= "FastForward") then --Start next clip when it's not FastForward clip
        local gameSound = GameSounds.getSound(sound)
        local gameSoundClip = gameSound:getRandomClip()
        self.id = self.emitter:playClip(gameSoundClip, nil)
        self.emitter:setVolume(self.id, self.volume * self.volumeModifier)
        self.emitter:set3D(self.id, self.sound3D)
        self.emitter:tick()
    end
end

function SoundFX:addToQueue(code)
    table.insert(self.soundQueue, code)
end

function SoundFX:emptyQueue()
    self.soundQueue = {}
end

-- Play the Queue if it's not empty and not playing

function SoundFX:playQueue()
    if self.emitter and self.id then
        if #self.soundQueue ~= 0 and not (self.emitter and self.emitter:isPlaying(self.id)) then
            local nextSound = table.remove(self.soundQueue, 1)
            self:play(nextSound)
        end
    end
end

function SoundFX:stop()
    if self.emitter and self.id then
        self.emitter:stopSound(self.id)
    end
    self.id = nil
end

function SoundFX:isPlaying()
    if not self.id then return false end
    return self.emitter and self.emitter:isPlaying(self.id)
end

function SoundFX:setVolume(value)
    self.volume = value
    if self.id then
        self.emitter:setVolume(self.id, self.volume * self.volumeModifier)
        self.emitter:tick()
    end
end
function SoundFX:setVolumeModifier(value)
    self.volumeModifier = value
    if self.id then
        self:setVolume(self.volume)
    end
end

function SoundFX:setPos(x,y,z)
    self.x = x+0.5
    self.y = y+0.5
    self.z = z or 0
    self:set3D(true)
    
    if self.emitter then
        self.emitter:setPos(x, y, z)
        self.emitter:tick()
    end
end
function SoundFX:setPosAtObject(obj)
    if not obj then return end
    self:setPos(obj:getX(), obj:getY(), obj:getZ())
end

function SoundFX:set3D(bool)
    if bool == nil then bool = true end
    self.sound3D = bool
    if self.id then
        self.emitter:set3D(self.id, self.sound3D)
        self.emitter:tick()
    end
end