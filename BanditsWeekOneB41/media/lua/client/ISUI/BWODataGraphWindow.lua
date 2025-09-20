require "ISUI/ISPanelJoypad"
require "ISUI/ISButton"

-- Simple UI window to visualize ModData (GMD) fill levels for Bandits and BanditWeekOne

BWODataGraphWindow = ISPanelJoypad:derive("BWODataGraphWindow")

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)

local function countTableEntries(tbl)
	if not tbl then return 0 end
	local count = 0
	for _ in pairs(tbl) do
		count = count + 1
	end
	return count
end

local function buildMetrics()
	local metrics = {}

	-- Bandits (base mod) ModData
	local bandit = nil
	if GetBanditModData ~= nil then
		bandit = GetBanditModData()
	end

	metrics[#metrics+1] = { label = "Bandit.Queue", value = countTableEntries(bandit and bandit.Queue) }
	metrics[#metrics+1] = { label = "Bandit.Scenes", value = countTableEntries(bandit and bandit.Scenes) }
	metrics[#metrics+1] = { label = "Bandit.Bandits", value = countTableEntries(bandit and bandit.Bandits) }
	metrics[#metrics+1] = { label = "Bandit.Posts", value = countTableEntries(bandit and bandit.Posts) }
	metrics[#metrics+1] = { label = "Bandit.Bases", value = countTableEntries(bandit and bandit.Bases) }
	metrics[#metrics+1] = { label = "Bandit.Kills", value = countTableEntries(bandit and bandit.Kills) }
	metrics[#metrics+1] = { label = "Bandit.VisitedBuildings", value = countTableEntries(bandit and bandit.VisitedBuildings) }

	-- BanditsWeekOne (Week One) ModData
	local bwo = nil
	if GetBWOModData ~= nil then
		bwo = GetBWOModData()
	end

	metrics[#metrics+1] = { label = "WeekOne.DeadBodies", value = countTableEntries(bwo and bwo.DeadBodies) }
	metrics[#metrics+1] = { label = "WeekOne.Objects", value = countTableEntries(bwo and bwo.Objects) }
	metrics[#metrics+1] = { label = "WeekOne.EventBuildings", value = countTableEntries(bwo and bwo.EventBuildings) }
	metrics[#metrics+1] = { label = "WeekOne.Nukes", value = countTableEntries(bwo and bwo.Nukes) }

	-- Determine max for scaling
	local maxValue = 0
	for _, m in ipairs(metrics) do
		if m.value > maxValue then maxValue = m.value end
	end
	return metrics, maxValue
end

function BWODataGraphWindow:initialise()
	ISPanelJoypad.initialise(self)

	-- Request latest ModData from server when opening on client
	if isClient() then
		if ModData and ModData.request then
			ModData.request("Bandit")
			ModData.request("BanditWeekOne")
		end
	end

    self.refreshBtn = ISButton:new(10, 10, 80, 22, "Refresh", self, BWODataGraphWindow.onRefresh)
	self.refreshBtn:initialise()
	self.refreshBtn:instantiate()
	self.refreshBtn.borderColor = { r = 1, g = 1, b = 1, a = 0.2 }
	self:addChild(self.refreshBtn)

    self.closeBtn = ISButton:new(self.width - 90, 10, 80, 22, "Close", self, BWODataGraphWindow.onClose)
	self.closeBtn:initialise()
	self.closeBtn:instantiate()
	self.closeBtn.borderColor = { r = 1, g = 1, b = 1, a = 0.2 }
	self:addChild(self.closeBtn)

	self.metrics, self.maxValue = buildMetrics()
end

function BWODataGraphWindow:onRefresh()
	if isClient() then
		if ModData and ModData.request then
			ModData.request("Bandit")
			ModData.request("BanditWeekOne")
		end
	end
	self.metrics, self.maxValue = buildMetrics()
end

function BWODataGraphWindow:onClose()
	self:setVisible(false)
	self:removeFromUIManager()
	BWODataGraphWindow.instance = nil
end

function BWODataGraphWindow:prerender()
	self.backgroundColor.a = 0.7
	self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b)
	self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b)

	self:drawTextCentre("GMD Fill Levels (Bandits + WeekOne)", self.width/2, 40, 1, 1, 1, 1, UIFont.Small)
end

function BWODataGraphWindow:render()
	-- Graph area
	local left = 20
	local top = 70
	local right = self.width - 20
	local bottom = self.height - 20
	local graphWidth = right - left
	local graphHeight = bottom - top

	-- Draw axis
	self:drawRectBorder(left, top, graphWidth, graphHeight, 1, 1, 1, 0.5)

	if not self.metrics or #self.metrics == 0 then
		self:drawText("No data", left + 10, top + 10, 1, 1, 1, 1, UIFont.Small)
		return
	end

	local barCount = #self.metrics
	local barGap = 6
	local barWidth = math.max(8, math.floor((graphWidth - (barGap * (barCount + 1))) / barCount))
	local scale = self.maxValue > 0 and (graphHeight - 30) / self.maxValue or 1

	local x = left + barGap
	for i, m in ipairs(self.metrics) do
		local barHeight = math.floor(m.value * scale)
		local y = bottom - barHeight
		local r, g, b = 0.2, 0.7, 0.9
		if string.find(m.label, "WeekOne", 1, true) then
			r, g, b = 0.9, 0.6, 0.2
		end
		self:drawRect(x, y, barWidth, barHeight, 0.9, r, g, b)
		self:drawRectBorder(x, y, barWidth, barHeight, 1, 1, 1, 0.6)
		-- Labels
		self:drawTextCentre(tostring(m.value), x + barWidth/2, y - FONT_HGT_SMALL - 2, 1, 1, 1, 1, UIFont.Small)
		self:drawTextCentre(m.label, x + barWidth/2, bottom + 4, 1, 1, 1, 1, UIFont.Small)
		x = x + barWidth + barGap
	end
end

function BWODataGraphWindow:new(x, y, width, height)
	local o = ISPanelJoypad:new(x, y, width, height)
	setmetatable(o, self)
	self.__index = self
	o.backgroundColor = { r = 0, g = 0, b = 0, a = 0.6 }
	o.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 }
	o.resizable = true
	return o
end

function BWODataGraphWindow.Open(player)
	if BWODataGraphWindow.instance then
		BWODataGraphWindow.instance:setVisible(true)
		BWODataGraphWindow.instance:bringToTop()
		return BWODataGraphWindow.instance
	end
	local plyNum = player and player:getPlayerNum() or 0
	local sw = getPlayerScreenWidth(plyNum)
	local sh = getPlayerScreenHeight(plyNum)
	local w = 820
	local h = 420
	local x = (sw - w) / 2
	local y = (sh - h) / 2
	local ui = BWODataGraphWindow:new(x, y, w, h)
	ui:initialise()
	ui:addToUIManager()
	ui:setVisible(true)
	BWODataGraphWindow.instance = ui
	return ui
end


