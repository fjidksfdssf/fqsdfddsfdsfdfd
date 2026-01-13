
-- LocalScript | StarterPlayerScripts 

-- =====================
-- SERVICES
-- =====================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LP = Players.LocalPlayer

-- =====================
-- Preloader blackscreen
local function showPreloader()
	local preGui = Instance.new("ScreenGui")
	preGui.Name = "rj3yBlackscreen"
	preGui.ResetOnSpawn = false
	-- Ensure this ScreenGui displays above all other PlayerGui ScreenGuis for this player
	preGui.DisplayOrder = 10000
	preGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	preGui.Parent = LP:WaitForChild("PlayerGui")

	local black = Instance.new("Frame", preGui)
	black.Size = UDim2.fromScale(1, 1)
	black.Position = UDim2.fromScale(0, 0)
	black.BackgroundColor3 = Color3.new(0, 0, 0)
	black.BorderSizePixel = 0
	black.ZIndex = 9998

	local mainLabel = Instance.new("TextLabel", black)
	mainLabel.Size = UDim2.fromScale(0.9, 0.18)
	mainLabel.Position = UDim2.fromScale(0.05, 0.4)
	mainLabel.BackgroundTransparency = 1
	mainLabel.Text = "loading nxcnt.win basic..."
	mainLabel.Font = Enum.Font.GothamBold
	mainLabel.TextColor3 = Color3.new(1, 1, 1)
	mainLabel.TextScaled = true
	mainLabel.TextWrapped = true
	mainLabel.TextYAlignment = Enum.TextYAlignment.Center
	mainLabel.TextTransparency = 0
	mainLabel.ZIndex = 9999

	local subLabel = Instance.new("TextLabel", black)
	subLabel.Size = UDim2.fromScale(0.9, 0.08)
	subLabel.Position = UDim2.fromScale(0.05, 0.62)
	subLabel.BackgroundTransparency = 1
	subLabel.Text = "made by rj3y on discord"
	subLabel.Font = Enum.Font.Gotham
	subLabel.TextColor3 = Color3.new(1, 1, 1)
	subLabel.TextScaled = true
	subLabel.TextWrapped = true
	subLabel.TextYAlignment = Enum.TextYAlignment.Center
	subLabel.TextTransparency = 0
	subLabel.ZIndex = 9999

	-- display for a short time then fade out
	spawn(function()
		wait(2.5)
		local t1 = TweenService:Create(black, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
		local t2 = TweenService:Create(mainLabel, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {TextTransparency = 1})
		local t3 = TweenService:Create(subLabel, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {TextTransparency = 1})
		t1:Play(); t2:Play(); t3:Play()
		t1.Completed:Wait()
		preGui:Destroy()
	end)
end

-- show the preloader immediately
pcall(showPreloader)

-- =====================
-- SETTINGS
-- =====================
local Settings = {
	Highlight = true,
	Names = true,
	Distance = true,
	Lines = false,
	Rainbow = true,
	LockOn = false,
	LockTarget = "Head",
	LockVisibleOnly = false,
	Crosshair = false
	,SilentAim = false
}

local VERSION = "v0.6b"

local Performance = {
	MaxDistance = 700,
	TextUpdateRate = 0.3,
	LineUpdateRate = 0.05,
	SkipOffscreen = true
}

-- =====================
-- STORAGE
-- =====================
local ESP = {}
local hue = 0
local lastTextUpdate = 0
local lastLineUpdate = 0
local SilentCooldown = 0.2
local lastSilent = 0

-- Crosshair drawing objects
local crossHor = Drawing.new("Line")
crossHor.Thickness = 3
crossHor.Transparency = 1
crossHor.Visible = false

local crossVer = Drawing.new("Line")
crossVer.Thickness = 3
crossVer.Transparency = 1
crossVer.Visible = false

local crossText = Drawing.new("Text")
crossText.Size = 20
crossText.Color = Color3.new(1,1,1)
crossText.Center = true
crossText.Outline = true
crossText.OutlineColor = Color3.new(0,0,0)
crossText.Text = "nxcnt.win basic"
crossText.Visible = false

-- spinning crosshair state
local crossAngle = 0
local crossSpinSpeed = math.pi -- radians per second

-- =====================
-- GUI (DRAGGABLE MENU)
-- =====================
local gui = Instance.new("ScreenGui")
gui.Name = "nxcnt.win basic"
gui.ResetOnSpawn = false
-- Keep this GUI above most other GUIs (preloader uses 10000)
gui.DisplayOrder = 9999
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = LP:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
local isTouch = UserInputService.TouchEnabled
if isTouch then
	frame.Size = UDim2.fromScale(0.85, 0.6)
	frame.Position = UDim2.fromScale(0.07, 0.18)
else
	frame.Size = UDim2.fromScale(0.23, 0.42)
	frame.Position = UDim2.fromScale(0.05, 0.28)
end
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.Active = true
	frame.Draggable = false

Instance.new("UICorner", frame).CornerRadius = UDim.new(0,16)

local title = Instance.new("TextLabel", frame)
local titleHeight = isTouch and 0.12 or 0.16
title.Size = UDim2.fromScale(1, titleHeight)
title.BackgroundTransparency = 1
title.Text = "nxcnt.win basic " .. VERSION
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.TextColor3 = Color3.new(1,1,1)

-- Custom drag handler (works on both mouse and touch)
do
	local dragging = false
	local dragStart = Vector2.new(0,0)
	local startPos = UDim2.new()

	title.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not dragging then return end
		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
		local delta = input.Position - dragStart
		local absStartX = startPos.X.Scale * Camera.ViewportSize.X + startPos.X.Offset
		local absStartY = startPos.Y.Scale * Camera.ViewportSize.Y + startPos.Y.Offset
		local newX = absStartX + delta.X
		local newY = absStartY + delta.Y
		newX = math.clamp(newX, 0, Camera.ViewportSize.X - frame.AbsoluteSize.X)
		newY = math.clamp(newY, 0, Camera.ViewportSize.Y - frame.AbsoluteSize.Y)
		frame.Position = UDim2.new(0, newX, 0, newY)
	end)
end

-- Close / Open buttons
local closeBtn = Instance.new("TextButton", frame)
closeBtn.Size = UDim2.fromScale(0.12, titleHeight)
closeBtn.Position = UDim2.fromScale(0.86, 0)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextScaled = true
closeBtn.BackgroundColor3 = Color3.fromRGB(160,60,60)
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,6)

local openBtn = Instance.new("TextButton", gui)
openBtn.Size = isTouch and UDim2.fromScale(0.18,0.08) or UDim2.fromScale(0.09,0.05)
openBtn.Position = isTouch and UDim2.fromScale(0.02,0.9) or UDim2.fromScale(0.02,0.9)
openBtn.Text = "nxcnt.win basic"
openBtn.Font = Enum.Font.GothamBold
openBtn.TextScaled = true
openBtn.BackgroundColor3 = Color3.fromRGB(80,80,80)
openBtn.Visible = false
openBtn.Parent = gui
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(0,8)

closeBtn.MouseButton1Click:Connect(function()
	frame.Visible = false
	openBtn.Visible = true
end)
openBtn.MouseButton1Click:Connect(function()
	frame.Visible = true
	openBtn.Visible = false
end)

-- =====================
-- TOGGLE CREATOR
-- =====================
local Buttons = {}

local function setSubmenuVisible(name, visible, instant)
	local info = Buttons[name]
	if not info then return end
	local btn = info.btn
	local order = info.order
	local btnHeight = isTouch and 0.12 or 0.11
	local gap = isTouch and 0.03 or 0.12
	local y = titleHeight + order * (btnHeight + gap)
	local onX = info.xOffset
	local offX = 1.05
	local target = UDim2.fromScale(visible and onX or offX, y)

	if instant then
		btn.Position = target
		btn.Visible = visible
		return
	end

	if visible then
		btn.Visible = true
		local tween = TweenService:Create(btn, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = target})
		tween:Play()
	else
		local tween = TweenService:Create(btn, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = target})
		tween:Play()
		tween.Completed:Connect(function()
			btn.Visible = false
		end)
	end
end

local function toggleChanged(name, value)
	if name == "LockOn" then
		setSubmenuVisible("LockVisibleOnly", value)
	end

	if name == "Lines" and value == false then
		for _, data in pairs(ESP) do
			if data.Line then
				data.Line.Visible = false
			end
		end
	end
end


local function createToggle(name, order)
	local btn = Instance.new("TextButton", frame)
	local btnHeight = isTouch and 0.12 or 0.11
	local gap = isTouch and 0.03 or 0.12
	local xOffset = (name == "LockVisibleOnly") and 0.12 or 0.05
	local width = (name == "LockVisibleOnly") and 0.83 or 0.9
	btn.Size = UDim2.fromScale(width, btnHeight)
	btn.Position = UDim2.fromScale(xOffset, titleHeight + order * (btnHeight + gap))
	btn.Font = Enum.Font.GothamBold
	btn.TextScaled = true
	btn.TextColor3 = Color3.new(1,1,1)

	Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)

	local function refresh()
		btn.Text = name .. ": " .. (Settings[name] and "ON" or "OFF")
		btn.BackgroundColor3 = Settings[name] and Color3.fromRGB(60,160,60)
			or Color3.fromRGB(160,60,60)
	end

	btn.MouseButton1Click:Connect(function()
		Settings[name] = not Settings[name]
		refresh()
		if toggleChanged then toggleChanged(name, Settings[name]) end
	end)

	Buttons[name] = { btn = btn, order = order, xOffset = xOffset, width = width }

	refresh()
end

createToggle("Highlight", 0)
createToggle("Names", 1)
createToggle("Distance", 2)
createToggle("Lines", 3)
createToggle("Rainbow", 4)
createToggle("LockOn", 5)
createToggle("LockVisibleOnly", 6)
createToggle("Crosshair", 8)
createToggle("SilentAim", 9)
-- Selector creator: cycles through options for a setting (responsive)
local function createSelector(name, order, options)
	local btn = Instance.new("TextButton", frame)
	local btnHeight = isTouch and 0.12 or 0.11
	local gap = isTouch and 0.03 or 0.12
	btn.Size = UDim2.fromScale(0.9, btnHeight)
	btn.Position = UDim2.fromScale(0.05, titleHeight + order * (btnHeight + gap))
	btn.Font = Enum.Font.GothamBold
	btn.TextScaled = true
	btn.TextColor3 = Color3.new(1,1,1)

	Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)

	local idx = 1
	for i, v in ipairs(options) do
		if Settings[name] == v then idx = i; break end
	end

	local function refresh()
		btn.Text = name .. ": " .. tostring(Settings[name])
		btn.BackgroundColor3 = Color3.fromRGB(80,80,80)
	end

	btn.MouseButton1Click:Connect(function()
		idx = idx % #options + 1
		Settings[name] = options[idx]
		refresh()
	end)

	refresh()
end

createSelector("LockTarget", 7, {"Head", "Torso", "HumanoidRootPart", "Legs"})

-- initialize submenu visibility
-- initialize submenu visibility (instant)
if Buttons["LockVisibleOnly"] then
	setSubmenuVisible("LockVisibleOnly", Settings.LockOn, true)
end

-- =====================
-- ESP CREATION
-- =====================
local function createESP(player, char)
	if ESP[char] then return end

	local data = {}

	local h = Instance.new("Highlight")
	h.FillTransparency = 0.6
	h.OutlineTransparency = 0
	h.Adornee = char
	h.Parent = workspace
	data.Highlight = h

	local head = char:FindFirstChild("Head")
	if head then
		local bill = Instance.new("BillboardGui", head)
		bill.Size = UDim2.fromScale(6,1.4)
		bill.StudsOffset = Vector3.new(0,3,0)
		bill.AlwaysOnTop = true

		local label = Instance.new("TextLabel", bill)
		label.Size = UDim2.fromScale(1,1)
		label.BackgroundTransparency = 1
		label.TextScaled = true
		label.Font = Enum.Font.GothamBold
		label.TextStrokeTransparency = 0
		label.TextColor3 = Color3.new(1,1,1)

		data.Billboard = bill
		data.Label = label
	end

	local line = Drawing.new("Line")
	line.Thickness = 1.5
	line.Transparency = 1
	line.Visible = false
	data.Line = line

	ESP[char] = data
end

local function removeESP(char)
	if not ESP[char] then return end
	for _, v in pairs(ESP[char]) do
		if typeof(v) == "Instance" then v:Destroy() end
		if typeof(v) == "userdata" then v:Remove() end
	end
	ESP[char] = nil
end

local function handlePlayer(p)
	if p == LP then return end

	if p.Character then
		createESP(p, p.Character)
	end

	p.CharacterAdded:Connect(function(c)
		createESP(p, c)
	end)

	p.CharacterRemoving:Connect(removeESP)
end

for _, p in ipairs(Players:GetPlayers()) do
	handlePlayer(p)
end
Players.PlayerAdded:Connect(handlePlayer)

local function getTargetPosition(char, target)
	if not char then return nil end
	if target == "Head" then
		local part = char:FindFirstChild("Head")
		if part then return part.Position end
	elseif target == "Torso" then
		local part = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("LowerTorso")
		if part then return part.Position end
	elseif target == "HumanoidRootPart" then
		local part = char:FindFirstChild("HumanoidRootPart")
		if part then return part.Position end
	elseif target == "Legs" then
		local legNames = {"LeftFoot","RightFoot","LeftLeg","RightLeg","LeftLowerLeg","RightLowerLeg"}
		local sum = Vector3.new(0,0,0)
		local count = 0
		for _, name in ipairs(legNames) do
			local p = char:FindFirstChild(name)
			if p then sum = sum + p.Position; count = count + 1 end
		end
		if count > 0 then return sum / count end
	end
	return nil
end

local function isTargetVisible(pos, char)
	local origin = Camera.CFrame.Position
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Blacklist
	params.FilterDescendantsInstances = {LP.Character}
	params.IgnoreWater = true

	-- Try multiple nearby target offsets to be more robust against small occluders
	local offsets = {
		Vector3.new(0,0,0),
		Vector3.new(0,0.15,0),
		Vector3.new(0.15,0,0),
		Vector3.new(-0.15,0,0),
		Vector3.new(0,0.15,0.15),
	}

	for _, off in ipairs(offsets) do
		local target = pos + off
		local dir = target - origin
		local result = workspace:Raycast(origin, dir, params)
		if result and result.Instance and result.Instance:IsDescendantOf(char) then
			return true
		end
	end

	return false
end

local function findNearestTarget()
	if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return nil end
	local myPos = LP.Character.HumanoidRootPart.Position
	local nearestPos = nil
	local nearestDist = math.huge
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LP and p.Character then
			local pos = getTargetPosition(p.Character, Settings.LockTarget)
			if pos then
				local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
				if Settings.LockVisibleOnly then
					if not onScreen then
						continue
					end
					if not isTargetVisible(pos, p.Character) then
						continue
					end
				end
				local dist = (myPos - pos).Magnitude
				if dist < nearestDist then
					nearestDist = dist
					nearestPos = pos
				end
			end
		end
	end
	return nearestPos, nearestDist
end

RunService.RenderStepped:Connect(function(dt)
	hue = (hue + dt * 0.25) % 1
	local rainbow = Color3.fromHSV(hue, 1, 1)

	if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
	local myPos = LP.Character.HumanoidRootPart.Position
	local now = tick()

	-- Crosshair handling (spinning)
	local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
	local chLen = isTouch and 18 or 10
	local chColor = Settings.Rainbow and rainbow or Color3.new(1,1,1)
	if Settings.Crosshair then
		crossHor.Visible = true
		crossVer.Visible = true
		crossText.Visible = true
		crossAngle = (crossAngle + dt * crossSpinSpeed) % (2 * math.pi)
		local a1 = crossAngle
		local a2 = crossAngle + math.pi/2
		local v1 = Vector2.new(math.cos(a1), math.sin(a1))
		local v2 = Vector2.new(math.cos(a2), math.sin(a2))
		crossHor.From = center + v1 * chLen
		crossHor.To = center - v1 * chLen
		crossVer.From = center + v2 * chLen
		crossVer.To = center - v2 * chLen
		crossHor.Color = chColor
		crossVer.Color = chColor
		crossText.Position = Vector2.new(center.X, center.Y + (isTouch and 26 or 14))
		crossText.Color = chColor
	else
		crossHor.Visible = false
		crossVer.Visible = false
		crossText.Visible = false
	end

	-- Lock camera to nearest selected target when enabled
	if Settings.LockOn and not Settings.SilentAim then
		local targetPos, hdDist = findNearestTarget()
		if targetPos and hdDist and hdDist <= Performance.MaxDistance then
			Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
		end
	end

	for char, data in pairs(ESP) do
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not hrp then continue end

		local dist = (myPos - hrp.Position).Magnitude

		if dist > Performance.MaxDistance then
			data.Highlight.Enabled = false
			if data.Billboard then data.Billboard.Enabled = false end
			data.Line.Visible = false
			continue
		end

		local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
		if Performance.SkipOffscreen and not onScreen then
			data.Line.Visible = false
			continue
		end

		local color = Settings.Rainbow and rainbow or Color3.new(1,0,0)

		data.Highlight.Enabled = Settings.Highlight
		data.Highlight.FillColor = color
		data.Highlight.OutlineColor = color

		if data.Label and now - lastTextUpdate >= Performance.TextUpdateRate then
			data.Billboard.Enabled = Settings.Names or Settings.Distance

			if Settings.Names and Settings.Distance then
				data.Label.Text = char.Name .. " | " .. math.floor(dist) .. " studs"
			elseif Settings.Names then
				data.Label.Text = char.Name
			elseif Settings.Distance then
				data.Label.Text = math.floor(dist) .. " studs"
			end
		end

		-- Ensure lines stay off when the setting is disabled
		if not Settings.Lines then
			data.Line.Visible = false
		else
			if onScreen and now - lastLineUpdate >= Performance.LineUpdateRate then
				data.Line.Visible = true
				data.Line.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
				data.Line.To = Vector2.new(screenPos.X, screenPos.Y)
				data.Line.Color = color
			else
				data.Line.Visible = false
			end
		end
	end

	if now - lastTextUpdate >= Performance.TextUpdateRate then
		lastTextUpdate = now
	end
	if now - lastLineUpdate >= Performance.LineUpdateRate then
		lastLineUpdate = now
	end
end)

	-- Silent-aim: brief, on-click camera snap towards nearest target (client-side only)
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
		if not Settings.SilentAim then return end

		local now = tick()
		if now - lastSilent < SilentCooldown then return end
		lastSilent = now

		local targetPos, dist = findNearestTarget()
		if not targetPos or not dist then return end
		if dist > Performance.MaxDistance then return end

		-- temporarily snap camera to face the target, then restore
		local prev = Camera and Camera.CFrame
		if prev then
			Camera.CFrame = CFrame.new(prev.Position, targetPos)
			spawn(function()
				wait(0.06)
				if Camera and prev then
					Camera.CFrame = prev
				end
			end)
		end
	end)
