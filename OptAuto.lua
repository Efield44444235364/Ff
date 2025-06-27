--[[
 ⚠️ WARNING: DO NOT place this script directly into the KRNL AutoExec folder. ⚠️
 This script may cause bugs or unpredictable behavior when executed automatically on game load via KRNL ❗❗
 
 ✨ It is designed to be used manually or executed at runtime, and it includes:
 - Auto execution on teleporting/rejoining a new server
 - Loading of performance optimization scripts with success/error checks

 🛠️ Author: Kawnew
 🌐 Script URLs: GitHub Hosted (see loadstring calls)
 💡 Recommended usage: Attach in-game with a manual executor
--]]

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

------------------------------ On/off --------------------------------
local KeepESP = true -- เปิด/ปิด Auto Exec
------------------------------------------------------------------------

local TeleportCheck = false

-- ตรวจสอบชื่อ executor ที่ใช้งานอยู่
local function detectExecutor()
	local exec = identifyexecutor and identifyexecutor():lower() or "unknown"

	if exec:find("krnl") then
		return "krnl"
	elseif exec:find("arceus") then
		return "Arceus X"
	elseif exec:find("delta") then
		return "Delta"
	elseif exec:find("codex") then
		return "Codex"
	elseif exec:find("trigon") then
		return "Trigon"
	elseif exec:find("cryptic") then
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
	if KeepESP and not TeleportCheck and queue_on_teleport then
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
