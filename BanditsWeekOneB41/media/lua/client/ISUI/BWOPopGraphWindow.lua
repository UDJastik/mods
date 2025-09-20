require "ISUI/ISPanelJoypad"
require "ISUI/ISButton"

-- Time-series graph for BWOPopControl metrics (StreetsMax, InhabitantsMax, SurvivorsMax)

BWOPopGraphWindow = ISPanelJoypad:derive("BWOPopGraphWindow")

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)

-- Shared history buffer (per session)
BWOPopGraphHistory = BWOPopGraphHistory or {
    labels = { "StreetsMax", "InhabitantsMax", "SurvivorsMax" },
    colors = {
        { r = 0.2, g = 0.7, b = 0.9 },  -- Streets
        { r = 0.9, g = 0.6, b = 0.2 },  -- Inhabitants
        { r = 0.5, g = 0.9, b = 0.4 },  -- Survivors
    },
    data = {
        {}, -- StreetsMax
        {}, -- InhabitantsMax
        {}, -- SurvivorsMax
    },
    maxSamples = 180, -- last 3 in-game hours (if EveryOneMinute)
}

local function pushSample(seriesIndex, value)
    local arr = BWOPopGraphHistory.data[seriesIndex]
    if not arr then return end
    arr[#arr + 1] = math.floor((value or 0) + 0.5)
    local overflow = #arr - (BWOPopGraphHistory.maxSamples or 180)
    if overflow > 0 then
        for i = 1, overflow do table.remove(arr, 1) end
    end
end

function BWOPopGraphWindow:initialise()
    ISPanelJoypad.initialise(self)

    self.refreshBtn = ISButton:new(10, 10, 80, 22, "Clear", self, BWOPopGraphWindow.onClear)
    self.refreshBtn:initialise()
    self.refreshBtn:instantiate()
    self.refreshBtn.borderColor = { r = 1, g = 1, b = 1, a = 0.2 }
    self:addChild(self.refreshBtn)

    self.closeBtn = ISButton:new(self.width - 90, 10, 80, 22, "Close", self, BWOPopGraphWindow.onClose)
    self.closeBtn:initialise()
    self.closeBtn:instantiate()
    self.closeBtn.borderColor = { r = 1, g = 1, b = 1, a = 0.2 }
    self:addChild(self.closeBtn)
end

function BWOPopGraphWindow:onClear()
    for i = 1, #BWOPopGraphHistory.data do
        BWOPopGraphHistory.data[i] = {}
    end
end

function BWOPopGraphWindow:onClose()
    self:setVisible(false)
    self:removeFromUIManager()
    BWOPopGraphWindow.instance = nil
end

function BWOPopGraphWindow:prerender()
    self.backgroundColor.a = 0.7
    self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b)
    self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b)

    self:drawTextCentre("Population Targets (EveryOneMinute)", self.width/2, 40, 1, 1, 1, 1, UIFont.Small)
end

function BWOPopGraphWindow:render()
    local left = 20
    local top = 70
    local right = self.width - 20
    local bottom = self.height - 20
    local graphWidth = right - left
    local graphHeight = bottom - top

    self:drawRectBorder(left, top, graphWidth, graphHeight, 1, 1, 1, 0.5)

    -- Build current metrics snapshot (Cnt, Nominal, Max for each group)
    local streetsCnt = math.floor((BWOPopControl and BWOPopControl.StreetsCnt) or 0)
    local streetsNom = math.floor((BWOPopControl and BWOPopControl.StreetsNominal) or 0)
    local streetsMax = math.floor((BWOPopControl and BWOPopControl.StreetsMax) or 0)
    local inhabCnt = math.floor((BWOPopControl and BWOPopControl.InhabitantsCnt) or 0)
    local inhabNom = math.floor((BWOPopControl and BWOPopControl.InhabitantsNominal) or 0)
    local inhabMax = math.floor((BWOPopControl and BWOPopControl.InhabitantsMax) or 0)
    local survCnt = math.floor((BWOPopControl and BWOPopControl.SurvivorsCnt) or 0)
    local survNom = math.floor((BWOPopControl and BWOPopControl.SurvivorsNominal) or 0)
    local survMax = math.floor((BWOPopControl and BWOPopControl.SurvivorsMax) or 0)

    local curValues = {
        streetsCnt, streetsNom, streetsMax,
        inhabCnt, inhabNom, inhabMax,
        survCnt,  survNom,  survMax,
    }

    local labels = {
        "Streets.Cnt", "Streets.Nom", "Streets.Max",
        "Inhab.Cnt",   "Inhab.Nom",   "Inhab.Max",
        "Surv.Cnt",    "Surv.Nom",    "Surv.Max",
    }

    -- Determine max for scaling
    local maxValue = 0
    for i = 1, #curValues do
        if curValues[i] > maxValue then maxValue = curValues[i] end
    end
    if maxValue <= 0 then maxValue = 1 end
    local scale = (graphHeight - 30) / maxValue

    -- Bars
    local barCount = #curValues
    local barGap = 10
    local barWidth = math.max(20, math.floor((graphWidth - (barGap * (barCount + 1))) / barCount))
    local x = left + barGap
    for i = 1, barCount do
        local value = curValues[i]
        local barHeight = math.floor(value * scale)
        local y = bottom - barHeight
        -- color per group of 3: Streets(blue), Inhab(orange), Surv(green)
        local c
        local mod = (i - 1) % 3
        if mod == 0 then
            c = { r = 0.2, g = 0.7, b = 0.9 }
        elseif mod == 1 then
            c = { r = 0.9, g = 0.6, b = 0.2 }
        else
            c = { r = 0.5, g = 0.9, b = 0.4 }
        end
        self:drawRect(x, y, barWidth, barHeight, 0.9, c.r, c.g, c.b)
        self:drawRectBorder(x, y, barWidth, barHeight, 1, 1, 1, 0.6)
        -- Labels and values
        self:drawTextCentre(tostring(value), x + barWidth/2, y - FONT_HGT_SMALL - 2, 1, 1, 1, 1, UIFont.Small)
        self:drawTextCentre(labels[i], x + barWidth/2, bottom + 4, 1, 1, 1, 1, UIFont.Small)
        x = x + barWidth + barGap
    end
end

function BWOPopGraphWindow:new(x, y, width, height)
    local o = ISPanelJoypad:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 0.6 }
    o.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 }
    o.resizable = true
    return o
end

function BWOPopGraphWindow.Open(player)
    if BWOPopGraphWindow.instance then
        BWOPopGraphWindow.instance:setVisible(true)
        BWOPopGraphWindow.instance:bringToTop()
        return BWOPopGraphWindow.instance
    end
    local plyNum = player and player:getPlayerNum() or 0
    local sw = getPlayerScreenWidth(plyNum)
    local sh = getPlayerScreenHeight(plyNum)
    local w = 820
    local h = 420
    local x = (sw - w) / 2
    local y = (sh - h) / 2
    local ui = BWOPopGraphWindow:new(x, y, w, h)
    ui:initialise()
    ui:addToUIManager()
    ui:setVisible(true)
    BWOPopGraphWindow.instance = ui
    return ui
end

-- Sampler: update once per in-game minute
local function BWOPopGraph_Sample()
    if not BWOPopControl then return end
    pushSample(1, BWOPopControl.StreetsMax or 0)
    pushSample(2, BWOPopControl.InhabitantsMax or 0)
    pushSample(3, BWOPopControl.SurvivorsMax or 0)
end

Events.EveryOneMinute.Add(BWOPopGraph_Sample)



