ZombieActions = ZombieActions or {}

ZombieActions.Smoke = {}
ZombieActions.Smoke.onStart = function(zombie, task)
    local fakeItem = BanditCompatibility.InstanceItem("Bandits.Cigarette")
    zombie:setSecondaryHandItem(fakeItem)

    return true
end

ZombieActions.Smoke.onWorking = function(zombie, task)
    if task.time <= 0 then
        return true
    elseif math.floor(task.time) == 12 then
        local effect = {}
        effect.x = zombie:getX()
        effect.y = zombie:getY()
        effect.z = zombie:getZ()
        effect.offset = 300
        effect.name = "mist_01"
        effect.frameCnt = 60
        effect.frameRnd = false
        effect.repCnt = 2
        effect.colors = {r=0.1, g=0.7, b=0.2, a=0.2}
        table.insert(BanditEffects.tab, effect)
    else
        local bumpType = zombie:getBumpType()
        if bumpType ~= task.anim then 
            -- zombie:playSound("Smoke")
            zombie:setBumpType(task.anim)
        end
    end
end

ZombieActions.Smoke.onComplete = function(zombie, task)
    zombie:setSecondaryHandItem(nil)
    return true
end