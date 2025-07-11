local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")
local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId

-- default config
Antikick = Antikick or true
AutoExecute = AutoExecute or true
LowRendering = LowRendering or false

local ConfigFolder = "Optimization"
local ConfigFile = ConfigFolder .. "/Config_" .. PlaceId .. ".json"

-- save config function
local function SaveConfig()
	if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end
	writefile(ConfigFile, HttpService:JSONEncode({
		Antikick = Antikick,
		AutoExecute = AutoExecute,
		LowRendering = LowRendering
	}))
end

-- load config function
local function LoadConfig()
	if isfile(ConfigFile) then
		local ok, data = pcall(function()
			return HttpService:JSONDecode(readfile(ConfigFile))
		end)
		if ok and typeof(data) == "table" then
			Antikick = data.Antikick
			AutoExecute = data.AutoExecute
			LowRendering = data.LowRendering
		end
	end
end

LoadConfig()
SaveConfig()

-- notification ui function (for current session)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SmoothNotificationQueue"
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local notifications = {}
local MAX_NOTIFICATIONS = 3

local function createNotification(titleText, messageText)
	local function build()
		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(0, 260, 0, 70)
		frame.Position = UDim2.new(1, 300, 0, 20)
		frame.AnchorPoint = Vector2.new(1, 0)
		frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		frame.BackgroundTransparency = 0.05
		frame.Parent = screenGui
		frame.ClipsDescendants = true

		local stroke = Instance.new("UIStroke", frame)
		stroke.Thickness = 1.2
		stroke.Transparency = 0.3
		stroke.Color = Color3.fromRGB(210, 210, 210)

		local corner = Instance.new("UICorner", frame)
		corner.CornerRadius = UDim.new(0, 12)

		local title = Instance.new("TextLabel", frame)
		title.Size = UDim2.new(1, -20, 0, 22)
		title.Position = UDim2.new(0, 10, 0, 10)
		title.Text = titleText
		title.Font = Enum.Font.GothamMedium
		title.TextSize = 16
		title.TextColor3 = Color3.fromRGB(30, 30, 30)
		title.BackgroundTransparency = 1
		title.TextXAlignment = Enum.TextXAlignment.Left

		local message = Instance.new("TextLabel", frame)
		message.Size = UDim2.new(1, -20, 0, 20)
		message.Position = UDim2.new(0, 10, 0, 36)
		message.Text = messageText
		message.Font = Enum.Font.Gotham
		message.TextSize = 14
		message.TextColor3 = Color3.fromRGB(90, 90, 90)
		message.BackgroundTransparency = 1
		message.TextXAlignment = Enum.TextXAlignment.Left

		table.insert(notifications, 1, frame)

		-- reposition notifications
		for i, notif in ipairs(notifications) do
			TweenService:Create(notif, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				Position = UDim2.new(1, -20, 0, 20 + ((i - 1) * 80))
			}):Play()
		end

		TweenService:Create(frame, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Position = UDim2.new(1, -20, 0, 20)
		}):Play()

		local dismissed = false
		frame.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 and not dismissed then
				dismissed = true
				local i = table.find(notifications, frame)
				if i then table.remove(notifications, i) end
				TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
					Size = UDim2.new(0, 0, 0, 0),
					BackgroundTransparency = 1
				}):Play()
				task.delay(0.4, function()
					frame:Destroy()
				end)
			end
		end)

		task.delay(4, function()
			if not dismissed and frame and frame.Parent then
				dismissed = true
				local i = table.find(notifications, frame)
				if i then table.remove(notifications, i) end
				TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
					Size = UDim2.new(0, 0, 0, 0),
					BackgroundTransparency = 1
				}):Play()
				task.delay(0.4, function()
					frame:Destroy()
				end)
			end
		end)
	end

	if #notifications >= MAX_NOTIFICATIONS then
		local oldest = table.remove(notifications, #notifications)
		if oldest then oldest:Destroy() end
		build()
	else
		build()
	end
end

-- ฟังก์ชัน detect executor
function detectExecutor()
	local exec = identifyexecutor and identifyexecutor():lower() or "unknown"
	if exec:find("krnl") then return "krnl"
	elseif exec:find("arceusx") then return "Arceus X"
	elseif exec:find("delta") then return "Delta"
	elseif exec:find("codex") then return "Codex"
	elseif exec:find("trigon") then return "Trigon"
	elseif exec:find("cryptic") then return "Cryptic"
	else return "Your Executor :)"
	end
end

-- ฟังก์ชัน save log (error หรือ warn) และเตะผู้เล่น
function SaveLogToFile(message, logType)
	local folderPath = ConfigFolder
	local fileName = "AutoExec err log.txt"
	local fullPath = folderPath .. "/" .. fileName

	if not isfolder(folderPath) then
		makefolder(folderPath)
	end

	local current = isfile(fullPath) and readfile(fullPath) or ""

	local playerName = LocalPlayer and LocalPlayer.Name or "Unknown"
	local hwid = (gethwid and gethwid()) or "Unavailable"
	local jobId = game.JobId or "N/A"
	local mapName = "Unknown"
	pcall(function()
		mapName = MarketplaceService:GetProductInfo(PlaceId).Name
	end)
	local executorName = detectExecutor()

	-- ส่วน header log จะมีข้อมูลทั้งหมด + executor
	local logHeader = string.format([[
--[[ Player name: %s
HWID: %s
Mapname: %s
MapID: %s
JobId: %s
Executor: %s

This section is a log record. If the script encounters bugs or critical issues, please send this file to the developer for debugging purposes.
]]

]], playerName, hwid, mapName, tostring(PlaceId), jobId, executorName)

	-- ดึงข้อมูล log ที่มีอยู่แล้ว (แยก error กับ warn)
	local errorLog = current:match("%-%- Error log\n(.-)\n\n%-%-warn log") or ""
	local warnLog = current:match("%-%-warn log\n(.-)$") or ""

	if logType == "error" then
		errorLog = errorLog .. "\n[" .. os.date("%H:%M:%S") .. "] " .. tostring(message)
	elseif logType == "warn" then
		warnLog = warnLog .. "\n[" .. os.date("%H:%M:%S") .. "] " .. tostring(message)
	end

	local fullLog = logHeader .. "\n-- Error log\n" .. errorLog .. "\n\n--warn log\n" .. warnLog
	writefile(fullPath, fullLog)

	-- เตะผู้เล่นพร้อมข้อความ
	if logType == "error" then
		LocalPlayer:Kick("[AutoExec Error] Check Optimization/AutoExec err log.txt")
	elseif logType == "warn" then
		LocalPlayer:Kick("[AutoExec Warning] Check Optimization/AutoExec err log.txt")
	end
end

-- โหลด optimization script
local success, err = pcall(function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/Efield44444235364/Roblox/refs/heads/main/opt.lua"))()
end)

if success then
	print("[ ✅ ] Optimization script loaded successfully.")
else
	local executorName = detectExecutor()
	warn("[ ❌ ] Failed to load optimization script. Executor:", executorName)
	SaveLogToFile(err or "Unknown error.", "error")
	return
end

-- แจ้งเตือนตอนโหลดสคริปต์ครั้งแรก
createNotification(" [ ✅ ] Auto Execute", "Script Loaded Successfully")
warn("[ ⚙️ ] Script loaded - Do NOT put in AutoExec folder directly!")

-- โหลด Anti-Cheat Delete
loadstring(game:HttpGet("https://raw.githubusercontent.com/Efield44444235364/Anti-ban/refs/heads/main/Anti%20cheat%20delete.lua"))()
