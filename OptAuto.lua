





local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

------------------------------------------------------------------------
-- ✅ เปิด/ปิดระบบ Auto Execute จากภายนอก loadstring ด้วยตัวแปร:
-- ใส่ AutoExecute = true หรือ false ก่อน loadstring() ด้านนอก
------------------------------------------------------------------------

local TeleportCheck = false

-- ตรวจสอบชื่อ executor ที่ใช้งานอยู่
local function detectExecutor()
	local exec = identifyexecutor and identifyexecutor():lower() or "unknown"

	if exec:find("krnl") then
		return "krnl"
	elseif exec:find("ArceusX") then
		return "Arceus X"
	elseif exec:find("Delta") then
		return "Delta"
	elseif exec:find("Codex") then
		return "Codex"
	elseif exec:find("Trigon") then
		return "Trigon"
	elseif exec:find("Cryptic") then
		return "Cryptic"
	else
		return "Your Executor :) "
	end
end

-- ฟังก์ชันสร้าง log error ไฟล์ JSON
local function SaveErrorToFile(message)
	local folderPath = "Optimization"
	local fileName = "AutoExec err log.json"
	local fullPath = folderPath .. "/" .. fileName

	if not isfolder(folderPath) then
		makefolder(folderPath)
	end

	local logData = {
		error = message,
		timestamp = os.date("%Y-%m-%d %H:%M:%S"),
		game = game.PlaceId,
		player = LocalPlayer and LocalPlayer.Name or "Unknown"
	}

	writefile(fullPath, HttpService:JSONEncode(logData))
end

-- โหลด Script Optimization (พร้อม success check)
local success, err = pcall(function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/Efield44444235364/Roblox/refs/heads/main/opt.lua"))()
end)

if success then
	print("[ ✅ ] Optimization script loaded successfully.")
else
	local executorName = detectExecutor()
	warn("[ ❌ ] Failed to load optimization script. Executor:", executorName)
	SaveErrorToFile(err or "Unknown error.")
	LocalPlayer:Kick("[AutoExec Error] Pls check in File : " .. executorName .. "/Optimization/AutoExec err log.json")
	return
end

-- Auto Exec ตอน rejoin
LocalPlayer.OnTeleport:Connect(function(State)
	if AutoExecute and not TeleportCheck and queue_on_teleport then
		TeleportCheck = true
		queue_on_teleport(
			"print(' [ ✅ ] Auto Exec when Rejoin Load!!')\n" ..
			"loadstring(game:HttpGet('https://raw.githubusercontent.com/Efield44444235364/Anti-ban/refs/heads/main/AutoExecNoti.lua'))()\n" ..
			"loadstring(game:HttpGet('https://raw.githubusercontent.com/Efield44444235364/Roblox/refs/heads/main/Opt%20for%20AUTOEXEC.lua'))()"
		)
	end
end)

print("[ 🔧 ] All core functions initialized successfully.")
warn("[ ⚙️ ] Script loaded - Do NOT put in AutoExec folder directly!")

loadstring(game:HttpGet("https://raw.githubusercontent.com/Efield44444235364/Anti-ban/refs/heads/main/Anti%20cheat%20delete.lua"))()
