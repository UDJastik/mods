BanditGlobalData = {}
BanditGlobalDataPlayers = {}

local QUEUE_MAX = 400
local _pruneQueueIfNeeded = function(gmd)
    if not gmd or not gmd.Queue then return end
    local count = 0
    for _ in pairs(gmd.Queue) do
        count = count + 1
    end
    if count <= QUEUE_MAX then return {} end
    local entries = {}
    for id, brain in pairs(gmd.Queue) do
        local born = 0
        if brain and brain.born then born = brain.born end
        table.insert(entries, { id = id, born = born })
    end
    table.sort(entries, function(a, b) return a.born < b.born end)
    local toRemove = count - QUEUE_MAX
    local removed = {}
    for i = 1, toRemove do
        local rid = entries[i] and entries[i].id
        if rid then
            gmd.Queue[rid] = nil
            table.insert(removed, rid)
        end
    end
    return removed
end

local _pendingRemovalIds = nil
local _removeZombiesByIdsServer = function(ids)
    if not ids or #ids == 0 then return end
    local cell = getCell()
    if not cell then return end
    local lookup = {}
    for _, id in ipairs(ids) do
        lookup[id] = true
    end
    local zombieList = cell:getZombieList()
    for i = 0, zombieList:size() - 1 do
        local zombie = zombieList:get(i)
        if zombie and BanditUtils and BanditUtils.GetCharacterID then
            local zid = BanditUtils.GetCharacterID(zombie)
            if zid and lookup[zid] then
                zombie:removeFromSquare()
                zombie:removeFromWorld()
            end
        end
    end
end

local _serverStartupCleanTick = function()
    if not _pendingRemovalIds or #_pendingRemovalIds == 0 then
        Events.OnTick.Remove(_serverStartupCleanTick)
        return
    end
    local cell = getCell()
    if not cell then return end
    _removeZombiesByIdsServer(_pendingRemovalIds)
    _pendingRemovalIds = {}
    Events.OnTick.Remove(_serverStartupCleanTick)
end

function InitBanditModData(isNewGame)

    -- BANDIT GLOBAL MODDATA
    local globalData = ModData.getOrCreate("Bandit")
    if isClient() then
        ModData.request("Bandit")
    end

    if not globalData.Queue then globalData.Queue = {} end
    if isServer() then
        local removedIds = _pruneQueueIfNeeded(globalData)
        if removedIds and #removedIds > 0 then
            _pendingRemovalIds = removedIds
            Events.OnTick.Add(_serverStartupCleanTick)
        end
    end
    
    -- uncomment these to reset all bandits on server restart
    -- if isServer() then
    --    globalData.Queue = {}
    -- end
    
    if not globalData.Scenes then globalData.Scenes = {} end
    if not globalData.Bandits then globalData.Bandits = {} end
    if not globalData.Posts then globalData.Posts = {} end
    if not globalData.Bases then globalData.Bases = {} end
    if not globalData.Kills then globalData.Kills = {} end
    if not globalData.VisitedBuildings then globalData.VisitedBuildings = {} end
    BanditGlobalData = globalData

    -- BANDIT PLAYERS GLOBAL MODDATA
    local globalDataPlayers = ModData.getOrCreate("BanditPlayers")
    if isClient() then
        ModData.request("BanditPlayers")
    end
   
    globalDataPlayers.OnlinePlayers = {}
    BanditGlobalDataPlayers = globalDataPlayers
end

function LoadBanditModData(key, globalData)
    if isClient() then
        if key and globalData then
            if key == "Bandit" then
                BanditGlobalData = globalData
            elseif key == "BanditPlayers" then
                BanditGlobalDataPlayers = globalData
            end
        end
    end
end

function GetBanditModData()
    return BanditGlobalData
end

function GetBanditModDataPlayers()
    return BanditGlobalDataPlayers
end

function TransmitBanditModData()
    ModData.transmit("Bandit")
end

function TransmitBanditModDataPlayers()
    ModData.transmit("BanditPlayers")
end

Events.OnInitGlobalModData.Add(InitBanditModData)
Events.OnReceiveGlobalModData.Add(LoadBanditModData)