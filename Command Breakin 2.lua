local Players, ReplicatedStorage = game:GetService("Players"), game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Events = ReplicatedStorage:WaitForChild("Events")
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local NoteGui = PlayerGui:WaitForChild("Assets"):WaitForChild("Note"):WaitForChild("Note"):WaitForChild("Note")

local function GetHRP()
	local char = LocalPlayer.Character
	return char and char:FindFirstChild("HumanoidRootPart") or nil
end

local function TeleportTo(cf)
	local hrp = GetHRP()
	if hrp then hrp.CFrame = cf end
end

local function EquipAllTools()
	local backpack, char = LocalPlayer.Backpack, LocalPlayer.Character
	if not backpack or not char then return end
	for _, v in ipairs(backpack:GetChildren()) do
		if v:IsA("Tool") then v.Parent = char end
	end
end

local function UnequipAllTools()
	local backpack, char = LocalPlayer.Backpack, LocalPlayer.Character
	if not backpack or not char then return end
	for _, v in ipairs(char:GetChildren()) do
		if v:IsA("Tool") then v.Parent = backpack end
	end
end

local weaponItems = {
	["Crowbar 1"] = true, ["Crowbar 2"] = true, ["Bat"] = true,
	["Pitchfork"] = true, ["Hammer"] = true, ["Wrench"] = true, ["Broom"] = true,
}

local giving = false
local function GiveItem(Item)
	if giving then return end
	local backpack, char = LocalPlayer.Backpack, LocalPlayer.Character
	if not backpack or not char then return end
	if backpack:FindFirstChild(Item) or char:FindFirstChild(Item) then return end

	giving = true
	if Item == "Armor" then
		Events.Vending:FireServer(3, "Armor2", "Armor", LocalPlayer.Name, 1)
	elseif weaponItems[Item] then
		Events.Vending:FireServer(3, tostring(Item:gsub(" ", "")), "Weapons", LocalPlayer.Name, 1)
	else
		Events.GiveTool:FireServer(tostring(Item:gsub(" ", "")))
	end
	task.delay(0.3, function() giving = false end)
end

local function Train(Ability)
	Events.RainbowWhatStat:FireServer(Ability)
end

local function GetSecretEnding()
	for _, v in ipairs({"HatCollected", "MaskCollected", "CrowbarCollected"}) do
		Events.LarryEndingEvent:FireServer(v, true)
	end
end

local ItemsTable = {
	"Crowbar 1", "Crowbar 2", "Bat", "Pitchfork", "Hammer", "Wrench", "Broom",
	"Armor", "Key", "Gold Key", "Louise", "Lollipop", "Chips",
	"Golden Apple", "Pizza", "Gold Pizza", "Rainbow Pizza", "Rainbow Pizza Box",
	"Book", "Phone", "Cookie", "Apple", "Bloxy Cola", "Expired Bloxy Cola", "Bottle", "Ladder"
}

local commandMap = {
	["/equipalltools"] = EquipAllTools,
	["/heal"] = function()
		GiveItem("Pizza")
		task.wait(0.1)
		local tool = LocalPlayer.Backpack:FindFirstChild("Pizza")
		if tool then
			tool.Parent = LocalPlayer.Character
			Events.Energy:FireServer(25, "Pizza")
		end
	end,
	["/healall"] = function()
		UnequipAllTools()
		task.wait(0.1)
		GiveItem("Golden Apple")
		task.wait(0.2)
		local apple = LocalPlayer.Backpack:FindFirstChild("Golden Apple")
		if apple then
			apple.Parent = LocalPlayer.Character
			Events.Energy:FireServer(50, "Golden Apple")
		end
		task.wait(0.2)
		Events.HealTheNoobs:FireServer()
	end,
	["/speed"] = function() for _ = 1, 3 do Train("Speed") task.wait(0.05) end end,
	["/strength"] = function() for _ = 1, 3 do Train("Strength") task.wait(0.05) end end,
	["/getdog"] = function()
		for _, v in ipairs(NoteGui:GetChildren()) do
			if v.Name:match("Circle") and v.Visible then
				local name = tostring(v.Name:gsub("Circle", ""))
				GiveItem(name)
				task.wait(0.1)
				local tool = LocalPlayer.Backpack:FindFirstChild(name)
				if tool then tool.Parent = LocalPlayer.Character end
				TeleportTo(CFrame.new(-257.5, 29.4, -910.4))
				task.wait(0.4)
				Events.CatFed:FireServer(name)
			end
		end
		TeleportTo(CFrame.new(-203.5, 35.4, -790.9))
	end,
	["/getagent"] = function()
		GiveItem("Louise")
		task.wait(0.1)
		local tool = LocalPlayer.Backpack:FindFirstChild("Louise")
		if tool then tool.Parent = LocalPlayer.Character end
		Events.LouiseGive:FireServer(2)
	end,
	["/getuncle"] = function()
		GiveItem("Key")
		task.wait(0.1)
		local tool = LocalPlayer.Backpack:FindFirstChild("Key")
		if tool then tool.Parent = LocalPlayer.Character end
		task.wait(0.2)
		Events.KeyEvent:FireServer()
	end,
	["/secret ending"] = GetSecretEnding,
	["/spawnpizza"] = function()
		local hrp = GetHRP()
		if hrp then
			Events.OutsideFood:FireServer(6, {["item2"] = "Pizza", ["placement"] = hrp.Position})
		end
	end,
	["/spawncola"] = function()
		local hrp = GetHRP()
		if hrp then
			Events.OutsideFood:FireServer(6, {["item2"] = "BloxyPack", ["placement"] = hrp.Position})
		end
	end,
	["/get"] = function()
		GiveItem("Armor")
		task.wait(0.1)
		for _ = 1, 3 do
			Train("Speed")
			Train("Strength")
			task.wait(0.05)
		end
		UnequipAllTools()
		for _ = 1, 5 do
			GiveItem("Gold Pizza")
			task.wait(0.05)
		end
	end
}

-- รองรับคำสั่งเสกไอเท็มทั้งหมด
for _, itemName in ipairs(ItemsTable) do
	local cmd = "/" .. itemName:lower():gsub(" ", "")
	if not commandMap[cmd] then
		commandMap[cmd] = function() GiveItem(itemName) end
	end
end

-- ✅ ระบบ Chatted ครบ
LocalPlayer.Chatted:Connect(function(msg)
	if not msg:match("^/") then return end
	local args = msg:split(" ")
	local command = args[1]:lower()
	local secondArg = args[2]

	-- ✅ /tp PlayerName
	if command == "/tp" and secondArg then
		local targetName = table.concat(args, " ", 2)
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr.Name:lower():sub(1, #targetName) == targetName:lower() then
				local targetHRP = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
				if targetHRP then
					TeleportTo(targetHRP.CFrame + Vector3.new(0, 5, 0))
					return
				end
			end
		end
		warn("❌ Player not found or HRP missing:", targetName)
		return
	end

	-- ✅ เสกของหลายชิ้น /item 3
	for _, itemName in ipairs(ItemsTable) do
		local itemCmd = "/" .. itemName:lower():gsub(" ", "")
		if itemCmd == command then
			local amount = tonumber(secondArg) or 1
			for i = 1, amount do
				GiveItem(itemName)
				task.wait(0.05)
			end
			return
		end
	end

	-- ✅ คำสั่งอื่น
	if commandMap[command] then
		commandMap[command]()
	else
		warn("❌ Unknown command:", command)
	end
end)

-- แสดง Dev Console
pcall(function() game:GetService("StarterGui"):SetCore("DevConsoleVisible", true) end)
warn("✅ SCRIPT LOADED")
