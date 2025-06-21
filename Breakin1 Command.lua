-- Breakin 1 Commands Script (ไม่มีตรวจสอบ PlaceId)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ฟังก์ชันรอให้ตัวละครพร้อม
local function GetHRP()
	local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	return char:WaitForChild("HumanoidRootPart")
end

-- ตารางคำสั่งสำหรับ Breakin 1
local Breakin1Commands = {
	["/chips"] = function()
		ReplicatedStorage.RemoteEvents.GiveTool:FireServer("Chips")
	end,
	["/cola"] = function()
		ReplicatedStorage.RemoteEvents.GiveTool:FireServer("BloxyCola")
	end,
	["/apple"] = function()
		ReplicatedStorage.RemoteEvents.GiveTool:FireServer("Apple")
	end,
	["/pizza"] = function()
		ReplicatedStorage.RemoteEvents.GiveTool:FireServer("Pizza2")
	end,
	["/cookie"] = function()
		ReplicatedStorage.RemoteEvents.GiveTool:FireServer("Cookie")
	end,
	["/medkit"] = function()
		ReplicatedStorage.RemoteEvents.GiveTool:FireServer("MedKit")
	end,

	["/get police"] = function()
		ReplicatedStorage.RemoteEvents.OutsideRole:FireServer("Gun", true)
	end,
	["/get swat"] = function()
		ReplicatedStorage.RemoteEvents.OutsideRole:FireServer("SwatGun", true)
	end,

	["/tp house"] = function()
		local hrp = GetHRP()
		hrp.CFrame = CFrame.new(71, -15, -163)
	end,
	["/tp shop"] = function()
		local hrp = GetHRP()
		hrp.CFrame = CFrame.new(-422, 3, -121)
	end,
	["/tp ew"] = function()
		local hrp = GetHRP()
		hrp.CFrame = CFrame.new(-16, 35, -220)
	end,
	["/tp swere"] = function()
		local hrp = GetHRP()
		hrp.CFrame = CFrame.new(129, 3, -125)
	end,
	["/tp boss"] = function()
		local hrp = GetHRP()
		hrp.CFrame = CFrame.new(-39, -287, -1480)
	end,

	["/bat"] = function()
		ReplicatedStorage.RemoteEvents.GiveTool:FireServer("Bat")
	end,
	["/teddy"] = function()
		ReplicatedStorage.RemoteEvents.GiveTool:FireServer("TeddyBloxpin")
	end,
	["/noob sword"] = function()
		ReplicatedStorage.RemoteEvents.GiveTool:FireServer("LinkedSword")
	end,
	["/sword"] = function()
		ReplicatedStorage.RemoteEvents.GiveTool:FireServer("LinkedSword")
	end,
}

-- ฟังชั่นรับคำสั่งจากแชท
LocalPlayer.Chatted:Connect(function(msg)
	if type(msg) ~= "string" then return end
	local command = msg:lower()
	if Breakin1Commands[command] then
		local success, err = pcall(Breakin1Commands[command])
		if not success then
			warn("Error executing command " .. command .. ": " .. tostring(err))
		end
	else
		warn("Unknown command: " .. command)
	end
end)

warn("Breakin 1 command script loaded successfully.")
pcall(function()
    game:GetService("StarterGui"):SetCore("DevConsoleVisible", true)
end)
