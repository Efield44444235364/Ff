local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId

-- ✅ Config
Antikick = Antikick or true
AutoExecute = AutoExecute or true
LowRendering = LowRendering or false

local ConfigFolder = "Optimization"
local ConfigFile = ConfigFolder .. "/Config_" .. PlaceId .. ".json"

-- ✅ สร้าง config ไฟล์ถ้ายังไม่มี
local function SaveConfig()
	if not isfolder(ConfigFolder) then
		makefolder(ConfigFolder)
	end

	local config = {
		Antikick = Antikick,
		AutoExecute = AutoExecute,
		LowRendering = LowRendering
	}
	writefile(ConfigFile, HttpService:JSONEncode(config))
end

-- ✅ โหลด config เมื่อ rejoin
local function LoadConfig()
	if isfile(ConfigFile) then
		local success, data = pcall(function()
			return HttpService:JSONDecode(readfile(ConfigFile))
		end)

		if success and typeof(data) == "table" then
			Antikick = data.Antikick
			AutoExecute = data.AutoExecute
			LowRendering = data.LowRendering
		end
	end
end

-- ✅ เก็บ config ปัจจุบันไว้
SaveConfig()

local TeleportCheck = false

-- ตรวจจับ executor
local function detectExecutor()
	local exec = identifyexecutor and identifyexecutor():lower() or "unknown"
	if exec:find("krnl") then return "krnl"
	elseif exec:find("ArceusX") then return "Arceus X"
	elseif exec:find("Delta") then return "Delta"
	elseif exec:find("Codex") then return "Codex"
	elseif exec:find("Trigon") then return "Trigon"
	elseif exec:find("Cryptic") then return "Cryptic"
	else return "Your Executor :) "
	end
end

-- บันทึก error log
local function SaveErrorToFile(message)
	local fileName = "AutoExec err log.json"
	local fullPath = ConfigFolder .. "/" .. fileName

	if not isfolder(ConfigFolder) then
		makefolder(ConfigFolder)
	end

	local logData = {
		error = message,
		timestamp = os.date("%Y-%m-%d %H:%M:%S"),
		game = PlaceId,
		player = LocalPlayer and LocalPlayer.Name or "Unknown"
	}
	writefile(fullPath, HttpService:JSONEncode(logData))
end

-- โหลด Script Optimization
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

-- ✅ ตอน teleport/rejoin: โหลด config แล้วใช้ใน queue_on_teleport
LocalPlayer.OnTeleport:Connect(function(State)
	if not TeleportCheck and queue_on_teleport then
		TeleportCheck = true

		local configStr = ""
		if isfile(ConfigFile) then
			local data = HttpService:JSONDecode(readfile(ConfigFile))
			configStr = string.format([[
				Antikick = %s
				AutoExecute = %s
				LowRendering = %s
			]], tostring(data.Antikick), tostring(data.AutoExecute), tostring(data.LowRendering))
		end

		queue_on_teleport(configStr .. "\n" ..
			"print(' [ ✅ ] Auto Exec when Rejoin Load!!')\n" ..
			"loadstring(game:HttpGet('https://raw.githubusercontent.com/Efield44444235364/Anti-ban/refs/heads/main/AutoExecNoti.lua'))()\n" ..
			"loadstring(game:HttpGet('https://raw.githubusercontent.com/Efield44444235364/Roblox/refs/heads/main/Opt%20for%20AUTOEXEC.lua'))()"
		)
	end
end)

print("[ 🔧 ] All core functions initialized successfully.")
warn("[ ⚙️ ] Script loaded - Do NOT put in AutoExec folder directly!")


--Anti Ban In dev!
loadstring(game:HttpGet("https://raw.githubusercontent.com/Efield44444235364/Anti-ban/refs/heads/main/Anti%20cheat%20delete.lua"))()
