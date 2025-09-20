BanditBrain = BanditBrain or {}

function BanditBrain.Get(zombie)
    local modData = zombie:getModData()
    return modData.brain or {}
end

function BanditBrain.Update(zombie, brain)
    local modData = zombie:getModData()
    modData.brain = brain or {}
end

function BanditBrain.Remove(zombie)
    local modData = zombie:getModData()
    modData.brain = {}
end
