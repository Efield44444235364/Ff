-- ✅ FULL OPTIMIZED SCRIPT with /get command

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Events = ReplicatedStorage:WaitForChild("Events")

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local NoteGui = PlayerGui:WaitForChild("Assets"):WaitForChild("Note"):WaitForChild("Note"):WaitForChild("Note")

local function GetHRP()
	local char = LocalPlayer.Character
	if char then
		return char:FindFirstChild("HumanoidRootPart")
	end
	return nil
end

local function TeleportTo(cf)
	local hrp = GetHRP()
	if hrp then
		hrp.CFrame = cf
	end
end

local function EquipAllTools()
	local backpack = LocalPlayer.Backpack
	local char = LocalPlayer.Character
	if not backpack or not char then return end
	for _, v in pairs(backpack:GetChildren()) do
		if v:IsA("Tool") then
			v.Parent = char
		end
	end
end

local function UnequipAllTools()
	local char = LocalPlayer.Character
	local backpack = LocalPlayer.Backpack
	if not char or not backpack then return end
	for _, v in pairs(char:GetChildren()) do
		if v:IsA("Tool") then
			v.Parent = backpack
		end
	end
end

local weaponItems = {
	["Crowbar 1"] = true, ["Crowbar 2"] = true, ["Bat"] = true,
	["Pitchfork"] = true, ["Hammer"] = true, ["Wrench"] = true, ["Broom"] = true,
}

local function GiveItem(Item)
	local backpack = LocalPlayer.Backpack
	local char = LocalPlayer.Character
	if not backpack or not char then return end

	if backpack:FindFirstChild(Item) or char:FindFirstChild(Item) then
		return
	end

	if Item == "Armor" then
		Events.Vending:FireServer(3, "Armor2", "Armor", LocalPlayer.Name, 1)
	elseif weaponItems[Item] then
		Events.Vending:FireServer(3, tostring(Item:gsub(" ", "")), "Weapons", LocalPlayer.Name, 1)
	else
		Events.GiveTool:FireServer(tostring(Item:gsub(" ", "")))
	end
end

local function Train(Ability)
	Events.RainbowWhatStat:FireServer(Ability)
end

local SecretEndingTable = {
	"HatCollected", "MaskCollected", "CrowbarCollected"
}

local function GetSecretEnding()
	for _, v in next, SecretEndingTable do
		Events.LarryEndingEvent:FireServer(v, true)
	end
end

local commandMap = {
	["/equipalltools"] = EquipAllTools,

	["/heal"] = function()
		GiveItem("Pizza")
		task.wait(0.1)
		local tool = LocalPlayer.Backpack and LocalPlayer.Backpack:FindFirstChild("Pizza")
		if tool then
			tool.Parent = LocalPlayer.Character
			Events.Energy:FireServer(25, "Pizza")
		end
	end,

	["/healall"] = function()
		UnequipAllTools()
		task.wait(0.1)
		GiveItem("Golden Apple")
		task.wait(0.3)
		local apple = LocalPlayer.Backpack and LocalPlayer.Backpack:FindFirstChild("Golden Apple")
		if apple then
			apple.Parent = LocalPlayer.Character
			Events.Energy:FireServer(50, "Golden Apple")
		end
		task.wait(0.3)
		Events.HealTheNoobs:FireServer()
	end,

	["/speed"] = function()
		for i = 1, 5 do
			Train("Speed")
			task.wait(0.05)
		end
	end,

	["/strength"] = function()
		for i = 1, 5 do
			Train("Strength")
			task.wait(0.05)
		end
	end,

	["/getdog"] = function()
		local children = NoteGui:GetChildren()
		for _, v in pairs(children) do
			if v.Name:match("Circle") and v.Visible == true then
				local name = tostring(v.Name:gsub("Circle", ""))
				GiveItem(name)
				task.wait(0.1)
				local tool = LocalPlayer.Backpack and LocalPlayer.Backpack:FindFirstChild(name)
				if tool then tool.Parent = LocalPlayer.Character end
				TeleportTo(CFrame.new(-257.56839, 29.4499969, -910.452637))
				task.wait(0.5)
				Events.CatFed:FireServer(name)
			end
		end
		task.wait(1)
		local tpPos = CFrame.new(-203.533081, 30.4500484, -790.901428) + Vector3.new(0, 5, 0)
		for _ = 1, 3 do
			TeleportTo(tpPos)
			task.wait(0.1)
		end
	end,

	["/getagent"] = function()
		GiveItem("Louise")
		task.wait(0.1)
		local tool = LocalPlayer.Backpack and LocalPlayer.Backpack:FindFirstChild("Louise")
		if tool then tool.Parent = LocalPlayer.Character end
		Events.LouiseGive:FireServer(2)
	end,

	["/getuncle"] = function()
		GiveItem("Key")
		task.wait(0.1)
		local tool = LocalPlayer.Backpack and LocalPlayer.Backpack:FindFirstChild("Key")
		if tool then tool.Parent = LocalPlayer.Character end
		task.wait(0.3)
		Events.KeyEvent:FireServer()
	end,

	["/rainbowpizza"] = function()
		GiveItem("Rainbow Pizza Box")
	end,

	["/medkit"] = function()
		GiveItem("Med Kit")
	end,

	["/gettools"] = function()
		local children = NoteGui:GetChildren()
		for _, v in pairs(children) do
			if v.Name:match("Circle") and v.Visible == true then
				GiveItem(tostring(v.Name:gsub("Circle", "")))
			end
		end
	end,

	["/secret ending"] = GetSecretEnding,

	["/spawnpizza"] = function()
		local hrp = GetHRP()
		if hrp then
			Events.OutsideFood:FireServer(6, {
				["item2"] = "Pizza",
				["placement"] = hrp.Position
			})
		end
	end,

	["/spawncola"] = function()
		local hrp = GetHRP()
		if hrp then
			Events.OutsideFood:FireServer(6, {
				["item2"] = "BloxyPack",
				["placement"] = hrp.Position
			})
		end
	end,

	["/get"] = function()
		task.wait(0.1)
		GiveItem("Armor")
		task.wait(0.1)
		for i = 1, 5 do
			Train("Speed")
			Train("Strength")
		end
		task.wait(0.1)
		UnequipAllTools()
		for i = 1, 15 do
			GiveItem("Gold Pizza")
			task.wait(0.05)
		end
	end,

	["/check"] = function()
		local passed, failed = 0, 0
		local function SafeTest(name, func)
			local ok, err = pcall(func)
			if ok then
				print("✅ " .. name .. " passed.")
				passed += 1
			else
				warn("❌ " .. name .. " failed: " .. tostring(err))
				failed += 1
			end
		end

		print(" [ 🔍 ] Starting Function Test...")
		SafeTest("GiveItem", function() GiveItem("Apple") end)
		SafeTest("Train", function() Train("Speed") end)
		SafeTest("Heal", function()
			GiveItem("Pizza")
			Events.Energy:FireServer(25, "Pizza")
		end)
		SafeTest("HealAll", function()
			GiveItem("Golden Apple")
			Events.HealTheNoobs:FireServer()
		end)
		SafeTest("GetDog", function()
			GiveItem("Book")
			Events.CatFed:FireServer("Book")
		end)
		SafeTest("GetAgent", function()
			GiveItem("Louise")
			Events.LouiseGive:FireServer(2)
		end)
		SafeTest("GetUncle", function()
			GiveItem("Key")
			Events.KeyEvent:FireServer()
		end)
		SafeTest("GetSecretEnding", GetSecretEnding)

		print("✅ Passed:", passed, "❌ Failed:", failed)
	end,
}

local ItemsTable = {
	"Crowbar 1", "Crowbar 2", "Bat", "Pitchfork", "Hammer", "Wrench", "Broom",
	"Armor", "Key", "Gold Key", "Louise", "Lollipop", "Chips",
	"Golden Apple", "Pizza", "Gold Pizza", "Rainbow Pizza", "Rainbow Pizza Box",
	"Book", "Phone", "Cookie", "Apple", "Bloxy Cola", "Expired Bloxy Cola", "Bottle", "Ladder"
}

for _, itemName in pairs(ItemsTable) do
	local cmd = "/" .. itemName:lower():gsub(" ", "")
	if not commandMap[cmd] then
		commandMap[cmd] = function() GiveItem(itemName) end
	end
end

LocalPlayer.Chatted:Connect(function(msg)
	if not msg:match("^/") then return end
	local command = msg:lower()
	if commandMap[command] then
		commandMap[command]()
	else
		warn("❌ Unknown command:", command)
	end
end)


pcall(function()
    game:GetService("StarterGui"):SetCore("DevConsoleVisible", true)
end)
warn("run")
