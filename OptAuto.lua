-- ⚙️ CONFIG / SERVICES
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId

Antikick = Antikick or true
AutoExecute = AutoExecute or true
LowRendering = LowRendering or false

local ConfigFolder = "Optimization"
local ConfigFile = ConfigFolder .. "/Config_" .. PlaceId .. ".json"

-- 💾 SAVE/LOAD CONFIG
local function SaveConfig()
	if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end
	writefile(ConfigFile, HttpService:JSONEncode({
		Antikick = Antikick,
		AutoExecute = AutoExecute,
		LowRendering = LowRendering
	}))
end

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

-- 🔍 EXECUTOR DETECT
local function detectExecutor()
	local exec = identifyexecutor and identifyexecutor():lower() or "unknown"
	if exec:find("krnl") then return "krnl"
	elseif exec:find("arceusx") then return "Arceus X"
	elseif exec:find("delta") then return "Delta"
	elseif exec:find("codex") then return "Codex"
	elseif exec:find("trigon") then return "Trigon"
	elseif exec:find("cryptic") then return "Cryptic"
	else return "Your Executor :) "
	end
end

-- 🧨 LOG ERROR
local function SaveErrorToFile(message)
	local fullPath = ConfigFolder .. "/AutoExec err log.json"
	if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end
	writefile(fullPath, HttpService:JSONEncode({
		error = message,
		timestamp = os.date("%Y-%m-%d %H:%M:%S"),
		game = PlaceId,
		player = LocalPlayer and LocalPlayer.Name or "Unknown"
	}))
end

-- ✅ UI: Notification System
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SmoothNotificationQueue"
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local notifications = {}
local MAX_NOTIFICATIONS = 3

function createNotification(titleText, messageText)
	local function build()
		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(0, 260, 0, 70)
		frame.Position = UDim2.new(1, 300, 0, 20)
		frame.AnchorPoint = Vector2.new(1, 0)
		frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		frame.BackgroundTransparency = 0.05
		frame.Parent = screenGui
		frame.ClipsDescendants = true

		Instance.new("UIStroke", frame).Color = Color3.fromRGB(210, 210, 210)
		Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

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
		for i, notif in ipairs(notifications) do
			TweenService:Create(notif, TweenInfo.new(0.45, Enum.EasingStyle.Quart), {
				Position = UDim2.new(1, -20, 0, 20 + ((i - 1) * 80))
			}):Play()
		end

		TweenService:Create(frame, TweenInfo.new(0.6, Enum.EasingStyle.Quart), {
			Position = UDim2.new(1, -20, 0, 20)
		}):Play()

		local dismissed = false
		frame.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 and not dismissed then
				dismissed = true
				table.remove(notifications, table.find(notifications, frame))
				TweenService:Create(frame, TweenInfo.new(0.4), {Size = UDim2.new(0, 0, 0, 0)}):Play()
				task.delay(0.4, function() frame:Destroy() end)
			end
		end)

		task.delay(4, function()
			if not dismissed and frame and frame.Parent then
				dismissed = true
				table.remove(notifications, table.find(notifications, frame))
				TweenService:Create(frame, TweenInfo.new(0.4), {Size = UDim2.new(0, 0, 0, 0)}):Play()
				task.delay(0.4, function() frame:Destroy() end)
			end
		end)
	end

	if #notifications >= MAX_NOTIFICATIONS then
		local old = table.remove(notifications)
		old:Destroy()
		build()
	else
		build()
	end
end

-- 🧠 โหลด Optimization script
local success, err = pcall(function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/Efield44444235364/Roblox/refs/heads/main/opt.lua"))()
end)

if success then
	print("[ ✅ ] Optimization script loaded successfully.")
else
	local executorName = detectExecutor()
	warn("[ ❌ ] Failed to load optimization script. Executor:", executorName)
	SaveErrorToFile(err or "Unknown error.")
	LocalPlayer:Kick("[AutoExec Error] Check: Optimization/AutoExec err log.json")
	return
end

-- 🔁 AutoExec when Rejoin
local TeleportCheck = false
LocalPlayer.OnTeleport:Connect(function(State)
	if AutoExecute and not TeleportCheck and queue_on_teleport then
		TeleportCheck = true

		local cfg = isfile(ConfigFile) and HttpService:JSONDecode(readfile(ConfigFile)) or {}
		local auto = cfg.AutoExecute and "✅" or "❌"
		local anti = "❗"
		local lowr = cfg.LowRendering and "✅" or "❌"

		local configVars = string.format("Antikick = %s\nAutoExecute = %s\nLowRendering = %s",
			tostring(cfg.Antikick), tostring(cfg.AutoExecute), tostring(cfg.LowRendering))

		local notify = string.format([[
			task.wait(1)
			createNotification("📦 Config Load", "AutoExecute %s | AntiBan %s | LowRendering %s")
			createNotification("🔧 หมายเหตุ", "AntiBan = ❗ (In dev)")
		]], auto, anti, lowr)

		queue_on_teleport(configVars .. "\n" ..
			"local Players = game:GetService('Players')\n" ..
			"local player = Players.LocalPlayer\n" ..
			"local gui = player:WaitForChild('PlayerGui'):FindFirstChild('SmoothNotificationQueue')\n" ..
			"if gui and getfenv().createNotification then\n" ..
			notify .. "\nend\n" ..
			"loadstring(game:HttpGet('https://raw.githubusercontent.com/Efield44444235364/Anti-ban/refs/heads/main/AutoExecNoti.lua'))()\n" ..
			"loadstring(game:HttpGet('https://raw.githubusercontent.com/Efield44444235364/Roblox/refs/heads/main/Opt%20for%20AUTOEXEC.lua'))()"
		)
	end
end)

-- ✅ แสดงว่าระบบโหลดครบ
createNotification(" [ ✅ ] Auto Execute", "Script Loaded Successfully")
warn("[ ⚙️ ] Script loaded - Do NOT put in AutoExec folder directly!")

-- 🛡️ โหลดระบบ Anti-Cheat Delete
loadstring(game:HttpGet("https://raw.githubusercontent.com/Efield44444235364/Anti-ban/refs/heads/main/Anti%20cheat%20delete.lua"))()
