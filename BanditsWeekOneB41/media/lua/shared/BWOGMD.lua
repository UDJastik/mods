BWOGlobalData = {}

function InitBWOModData(isNewGame)

    -- BANDIT GLOBAL MODDATA
    local globalData = ModData.getOrCreate("BanditWeekOne")
    if isClient() then
        ModData.request("BanditWeekOne")
    end
    
    if not globalData.DeadBodies then globalData.DeadBodies = {} end
    if not globalData.Objects then globalData.Objects = {} end
    if not globalData.EventBuildings then globalData.EventBuildings = {} end
    if not globalData.Nukes then globalData.Nukes = {} end
    BWOGlobalData = globalData

end

function LoadBWOModData(key, globalData)
    if isClient() then
        if key and globalData then
            if key == "BanditWeekOne" then
                BWOGlobalData = globalData
            end
        end
    end
end

function GetBWOModData()
    return BWOGlobalData
end

function TransmitBWOModData()
    ModData.transmit("BanditWeekOne")
end


Events.OnInitGlobalModData.Add(InitBWOModData)
Events.OnReceiveGlobalModData.Add(LoadBWOModData)
