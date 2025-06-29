local HttpService = game:GetService("HttpService")
local filePath = "WindUI/Glitch/deadrails.json"

getgenv().Settings = {
  ["Language"] = getgenv().Settings and getgenv().Settings["Language"] or "TH"
}

local defaults = {
	ESP = {
		["Money Bag ESP"] = false,
		["Monster ESP"] = false,
		["Dead Monster ESP"] = false,
		["Animal ESP"] = false,
		["Dead Animal ESP"] = false,
		["Item ESP"] = false,
		["Vault Code ESP"] = false,
		["Train ESP"] = false,
		["Ore ESP"] = false
	},
	Language = getgenv().Settings["Language"] or "TH",
	ExtraPrompt = 1,
	AutoCollectBags = false,
	AutoPickTools = false,
	AutoPickOther = false,
	AutoPickArmor = false,
	AutoPickBonds = false,
	Noclip = false,
	NC = false,
	ShowTime = false,
	ShowDistance = false,
	ShowSpeed = false,
	ShowFuel = false,
	InstantInteract = false,
	GunAura = false,
	MeleeAura = false,
	AutoReload = false,
	Raycast = false,
	Aimbot = false,
	Mode = "Distance",
	NoVoid = false,
	SaveBulltets = false,
	BandageUse = 0,
	OilUse = 0,
	OilUseCooldown = 5,
	GunRadius = 500,
	ThrowPower = 100,
}

local vals = table.clone(defaults)
vals.ESP = table.clone(defaults.ESP)

local function SaveSetting()
	local json = HttpService:JSONEncode(vals)
	writefile(filePath, json)
end

local function LoadSetting()
	if isfile(filePath) then
		local json = readfile(filePath)
		local loadedData = HttpService:JSONDecode(json)
		for k, v in pairs(defaults) do
			if loadedData[k] == nil then
				loadedData[k] = v
			end
		end
		for k, v in pairs(defaults.ESP) do
			if loadedData.ESP[k] == nil then
				loadedData.ESP[k] = v
			end
		end

		vals = loadedData
	else
		SaveSetting()
	end
end

LoadSetting()

local function getGlobalTable()
	return typeof(getfenv().getgenv) == "function" and typeof(getfenv().getgenv()) == "table" and getfenv().getgenv() or _G
end


local WindUI = loadstring(game:HttpGet("https://tree-hub.vercel.app/api/UI/WindUI"))()
local espLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/MITUMAxDev/Glitch/refs/heads/main/loads/libs/esp.lua", true))()

local plr = game:GetService("Players").LocalPlayer

if game.PlaceId == 116495829188952 then
	warn("PLEASE ONLY EXECUTE IN GAME")
return
end

espLib.Values = vals.ESP

local function rs(times)
	local times = math.max(math.round(tonumber(times) or 1), 1)
	local dt = 0
	for i=1, times do
		dt = dt + game:GetService("RunService").RenderStepped:Wait()
	end
	return dt / times
end
local espFunc = espLib.ApplyESP

local closed = false
local cons = {}
local prompts = {}
local oprompts = {}
local hooks = {}

local cd = {}
local fppn = false
local fpp = getfenv().fireproximityprompt

local probablyDead = {}
local deathAmmo = {}

local function renderWait(t)
	local start = tick()
	t = tonumber(t) or 0

	rs()
	task.wait(t / 2)
	rs()
	task.wait(t / 2)
	rs()

	return tick() - start
end


local function isDead(hum)
	if probablyDead[hum] then
		return true
	end

	if hum and hum.Parent then
		if not hum:IsA("Humanoid") then
			hum = hum:FindFirstChild("Humanoid")
		end

		if hum then
			if probablyDead[hum] then
				return true
			end

			local dead = hum.Health <= 0.01 and hum.PlatformStand
			if dead then
				probablyDead[hum] = true
			end

			return dead
		end
	end

	return true
end

local myGuns = {}
local melee = {}
local heals = {
	Bandage = {},
	["Snake Oil"] = {}
}

local function bp(v)
	if v and v:IsA("Tool") then
		if v:FindFirstChild("WeaponConfiguration") and not myGuns[v] then
			myGuns[v] = true
		elseif v:FindFirstChild("SwingEvent") and not melee[v] then
			melee[v] = true
		elseif heals[v.Name] and not heals[v.Name][v] then
			heals[v.Name][v] = true
		end
	end
end

local toolsMt = setmetatable({}, {
	__index = function(self, value)
		if value == "GetChildren" then
			local tools = plr.Backpack:GetChildren()

			if plr.Character then
				for i,v in plr.Character:GetChildren() do
					if v and v:IsA("Tool") then
						table.insert(tools, 1, v)
					end
				end
			end

			return tools
		end
		if plr and plr.Character and plr.Character:FindFirstChildOfClass("Tool") and plr.Character:FindFirstChildOfClass("Tool").Name == value then
			return plr.Character:FindFirstChildOfClass("Tool")
		end
		return plr.Backpack:FindFirstChild(value)
	end
})

for i,v in toolsMt.GetChildren do
	bp(v)
end
cons[#cons+1] = plr.Backpack.ChildAdded:Connect(bp)

local cooldown = {}
local function setCooldown(gun)
	cooldown[gun] = true
	task.wait((gun.WeaponConfiguration.FireDelay.Value * 1.5) + 0.25)
	cooldown[gun] = false
end

local function addFunction(t,v)
	if v == nil or typeof(t) ~= "table" then return end
	local i = 1
	while true do
		if v == nil or typeof(v) == "Instance" and v.Parent == nil then
			return -1
		end
		if t[i] == nil or typeof(t[i]) == "Instance" and t[i].Parent == nil then
			t[i] = v
			return i
		end
		i = i + 1
	end
end
local function add(t,v)
	task.spawn(addFunction, t, v)
end
local function remove(t,v)
	task.spawn(pcall, table.remove, t, table.find(t, v))
end
local function count(t)
	local amnt = 0
	for i,v in t do
		if typeof(v) == "Instance" and v.Parent ~= nil or typeof(v) ~= "Instance" and v ~= nil then
			amnt = amnt + 1
		end
	end
	return amnt
end
local function getFirst(t)
	for v,i in t do
		if typeof(v) == "Instance" and (v.Parent == plr.Character or v.Parent == plr.Backpack) or typeof(v) ~= "Instance" and v ~= nil then
			return v
		else
			remove(t, v)
		end
	end
end

local function fuseTables(t1, t2)
	for i,v in t2 do
		add(t1, v)
	end

	return t1
end

local RunService = game:GetService("RunService")
local player = game:GetService("Players").LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local noclipConnection

local function toggleNoclip(state)
    if state then
        noclipConnection = RunService.Stepped:Connect(function()
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end)
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end


toggleNoclip(vals.Noclip)


local function raycast(from, to, ignore)
	local raycastParams = RaycastParams.new()

	raycastParams.IgnoreWater = true
	raycastParams.FilterDescendantsInstances = fuseTables(plr.Character and plr.Character:GetDescendants() or {}, ignore or {})

	local result = workspace:Raycast(from, (to - from).Unit * (to - from).Magnitude, raycastParams)
	return result and result.Instance
end

local s = game:GetService("ReplicatedStorage").Remotes.Weapon.Shoot
local r = game:GetService("ReplicatedStorage").Remotes.Weapon.Reload
local function shoot(gun, target)
	if not isDead(target) and (vals.Raycast and not raycast(workspace.CurrentCamera.CFrame.Position, target:GetPivot().Position, target:GetDescendants()) or not vals.Raycast) and (workspace.CurrentCamera.CFrame.Position - target:GetPivot().Position).Magnitude <= vals.GunRadius then
		local head = target:FindFirstChild("Head") or target:GetPivot()

		local hits = {}
		for i=1, gun.WeaponConfiguration.PelletsPerBullet.Value do
			hits[tostring(i)] = target.Humanoid
		end

		if target.Humanoid.Health - gun.WeaponConfiguration.BulletDamage.Value < 0 and gun.ServerWeaponState.CurrentAmmo.Value >= 1 and not cooldown[gun] then
			deathAmmo[target.Humanoid] = (tonumber(deathAmmo[target.Humanoid]) or 3) - 1
			if deathAmmo[target.Humanoid] <= 0 then
				probablyDead[target.Humanoid] = true
			end
			task.spawn(setCooldown, gun)
		end

		s:FireServer(workspace:GetServerTimeNow(), gun, CFrame.lookAt(head.Position + (head.CFrame.LookVector * 10), head.Position), hits)
	end
end
local function reload(gun)
	r:FireServer(workspace:GetServerTimeNow(), gun)
end

if fpp then
	pcall(function()
		task.spawn(function()
			local pp = Instance.new("ProximityPrompt", workspace)
			local con; con = pp.Triggered:Connect(function()
				con:Disconnect()
				fppn = true
				task.wait(0.1)
				pp.Parent = nil
				task.wait(0.1)
				pp:Destroy()
			end)
			task.wait(0.1)
			fpp(pp)
			task.wait(1.5)
			if pp and pp.Parent then
				con:Disconnect()
				task.wait(0.1)
				pp.Parent = nil
				task.wait(0.1)
				pp:Destroy()
			end
		end)
	end)
end

local function fppFunc(pp)
	cd[pp] = true
	local a,b,c,d,e = pp.MaxActivationDistance, pp.Enabled, pp.Parent, pp.HoldDuration, pp.RequiresLineOfSight
	local obj = Instance.new("Part", workspace)
	obj.Transparency = 1
	obj.CanCollide = false
	obj.Size = Vector3.new(0.1, 0.1, 0.1)
	obj.Anchored = true
	pp.Parent = obj
	pp.MaxActivationDistance = math.huge
	pp.Enabled = true
	pp.HoldDuration = 0
	pp.RequiresLineOfSight = false
	if not pp or not pp.Parent then
		obj:Destroy()
		return
	end
	obj:PivotTo(workspace.CurrentCamera.CFrame + (workspace.CurrentCamera.CFrame.LookVector / 5))
	rs()
	obj:PivotTo(workspace.CurrentCamera.CFrame + (workspace.CurrentCamera.CFrame.LookVector / 5))
	rs()
	obj:PivotTo(workspace.CurrentCamera.CFrame + (workspace.CurrentCamera.CFrame.LookVector / 5))
	pp:InputHoldBegin()
	rs()
	pp:InputHoldEnd()
	rs()
	if pp.Parent == obj then
		pp.Parent = c
		pp.MaxActivationDistance = a
		pp.Enabled = b
		pp.HoldDuration = d
		pp.RequiresLineOfSight = e
	end
	obj:Destroy()
	cd[pp] = false
end
local function canGetPivot(pp)
	return pp.Parent.GetPivot
end
local fireproximityprompt = function(pp, i)
	if not i and (typeof(pp) ~= "Instance" or not pp:IsA("ProximityPrompt") or not pcall(canGetPivot, pp) or cd[pp] or not workspace.CurrentCamera or ((game.Players.LocalPlayer and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and game.Players.LocalPlayer.Character.HumanoidRootPart or workspace.CurrentCamera).CFrame.Position - pp.Parent:GetPivot().Position).Magnitude > pp.MaxActivationDistance * 2) then return end
	if fppn then
		return fpp(pp)
	end
	task.spawn(fppFunc, pp)
end

local function insertCum(str)
	local new = str:gsub("(%u)", " %1")
	if new:sub(1, 1) == " " then
		new = new:sub(2)
	end

	return new:gsub("  ", " "):gsub("_", "") .. ""
end

local function getSelectedObject()
	return game:GetService("ReplicatedStorage").Client.Handlers.DraggableItemHandlers.ClientDraggableObjectHandler.DragHighlight.Adornee
end

local function throwObject(object)
	if (object:GetPivot().Position - plr.Character:GetPivot().Position).Magnitude > 20 then
		return
	end

	game:GetService("ReplicatedStorage").Shared.Remotes.RequestStartDrag:FireServer(object)

	local par

	while true do
		local drag1 = object:FindFirstChild("DragAttachment", math.huge)
		local drag2 = object:FindFirstChild("DragAlignPosition", math.huge)
		local drag3 = object:FindFirstChild("DragAlignOrientation", math.huge)

		if not drag1 and not drag2 and not drag3 and par then
			break
		end

		if drag1 then
			par = drag1.Parent
			drag1:Destroy()
			continue
		end
		if drag2 then
			par = drag2.Parent
			drag2:Destroy()
			continue
		end
		if drag3 then
			par = drag3.Parent
			drag3:Destroy()
			continue
		end

		task.wait()
	end

	task.wait()

	if par then
		par.AssemblyLinearVelocity = CFrame.lookAt(workspace.CurrentCamera.CFrame.Position, par:GetPivot().Position + Vector3.new(0, ((10000 - vals.ThrowPower)/10000) * 5 - 0.25)).LookVector * vals.ThrowPower
		task.wait()
	end

	game:GetService("ReplicatedStorage").Shared.Remotes.RequestStopDrag:FireServer()
end


local function BypassEnd()
  pcall(function()
    local w = CFrame.new(-424, 30, -49041)
repeat task.wait()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = w
until game.Players.LocalPlayer.Character.Humanoid.Sit
  end
  )
end

local function GoToTrainTP()
  pcall(function()
    local SeatDriver = workspace.Train.TrainControls.ConductorSeat:FindFirstChild("VehicleSeat")
    if SeatDriver and game:GetService("Players").LocalPlayer.Character.Humanoid.Health > 0 then
      repeat task.wait()
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = SeatDriver.CFrame * CFrame.new(0, 0.2, 0)
      until game.Players.LocalPlayer.Character.Humanoid.Sit
      end
    end
  )
end

local function throw()
	local obj = getSelectedObject()
	if not obj then
	  local noti = WindUI:Notify({
    Title = "No!",
    Content = "Look at object you want to throw",
    Duration = 5,
})
		return
	end

	throwObject(obj)
end

local esps = {}
local desps = {}
local monsters = {}

local tools = {}
local bonds = {}
local other = {}
local equippables = {}

local pickupable = { "Consumable", "Gun", "Weapon", "Melee", "Playable", "Tool" }
local activateable = { "Ammo" }
local armor = { "Equippable" }

local infoStored = {}

local function getInfo(object)
	rs(2)
	if not object or not object.Parent then return end
	if infoStored[object.Name] then return infoStored[object.Name] end

	local info = {}
	for i,v in object:WaitForChild("ObjectInfo", 9e9):GetChildren() do
		if v.Name ~= "Title" and v:IsA("TextLabel") then
			add(info, v.Text)
		end
	end

	infoStored[object.Name] = info
	return info
end

local function hasProperty(object, prop)
	if not object:FindFirstChild("ObjectInfo") then return false end

	local info = getInfo(object)

	if not info then return false end

	for i,v in info do
		if v == prop then
			return true
		end
	end

	return false
end

local function getColor(v)
	local val = v and v:GetAttribute("Value")
	if v.Name == "Bond" then
		return Color3.fromRGB(255, 170)
	elseif v.Name == "Coal" then
		return Color3.new(0.2, 0.2, 0.2)
	elseif v.Name == "Unicorn" then
		return Color3.fromRGB(85, 255, 255)
	elseif v.Name == "Bandage" then
		return Color3.fromRGB(255, 85, 255)
	elseif v.Name == "Snake Oil" then
		return Color3.fromRGB(0, 170)
	elseif hasProperty(v, "Ammo") then
		return Color3.fromRGB(255, 170, 125)
	elseif hasProperty(v, "Weapon") or hasProperty(v, "Gun") or hasProperty(v, "Melee") then
		return Color3.new(0.75, 0.5, 0.5)
	elseif val then
		if val <= 50 then
			return Color3.new(0.8, 0.8, 0.8):Lerp(Color3.fromRGB(255, 255, 75), val / 50)
		elseif val <= 175 then
			return Color3.fromRGB(255, 255, 75):Lerp(Color3.fromRGB(75, 255, 255), (val - 50) / 175)
		else
			return Color3.fromRGB(75, 255, 255):Lerp(Color3.fromRGB(255, 125, 255), (val - 175) / 325)
		end
	end
	return Color3.new(0.8, 0.8, 0.8)
end

local function getText(obj)
	local n = obj.Name
	local l = n:lower()
	
	if l:match("vase") then
		return "Vase"
	elseif l:match("outlaw") then
		return "Outlaw"
	elseif l:match("zombie") then
		return "Zombie"
	elseif l:match("nikola") then
		return "Nikola Boss"
	end
	
	return insertCum(n)
end




local function getItemText(object)
	local text = getText(object)
	local price = object:GetAttribute("Value")
	local fuel = object:GetAttribute("Fuel")

	if not price or price <= 0 then
		price = nil
	end
	if not fuel or fuel <= 0 then
		fuel = nil
	end
	
	local otherText = ""

	if price then
		otherText = otherText .. " $" .. price
	end
	if fuel then
		otherText = otherText .. "\nFuel: "  .. (math.round((fuel / 240) * 1000) / 10) .. " %"
	end
	
	if otherText ~= "" then
		return text .. otherText
	else
		return text
	end
end




local checked = {}
local function main(v)
	renderWait()

	if v and v.Parent and not checked[v] then
		if v:IsA("ProximityPrompt") and not oprompts[v] then
			oprompts[v] = v.MaxActivationDistance
			v.MaxActivationDistance = oprompts[v] * vals.ExtraPrompt
		elseif v:IsA("Humanoid") and not game:GetService("Players"):GetPlayerFromCharacter(v.Parent) then
			checked[v] = true
			checked[v.Parent] = true
			
			if v.Parent:GetAttribute("DangerScore") or v.Parent.Parent and (v.Parent.Parent.Name:lower():match("enemies") or v.Parent.Parent.Name:lower():match("enemy")) then
				local monster = esps[v.Parent.Name] or {HighlightEnabled = false, Color = Color3.new(0.35):Lerp(Color3.new(1), (v.Parent:GetAttribute("DangerScore") or 10) / 100), Text = getItemText(v.Parent), ESPName = "Monster ESP"}
				esps[v.Parent.Name] = monster

				espFunc(v.Parent, monster)
				add(monsters, v.Parent)

				repeat task.wait() until not v or not v.Parent or isDead(v)

				pcall(espLib.DeapplyESP, v.Parent)

				local dead = desps[v.Parent.Name] or {HighlightEnabled = true, Color = Color3.fromRGB(200, 150, 50):Lerp(Color3.fromRGB(255, 75, 0), (v.Parent:GetAttribute("DangerScore") / 10) / 100), Text = getItemText(v.Parent), ESPName = "Dead Monster ESP"}
				desps[v.Parent.Name] = dead
				
				remove(monsters, v.Parent)

				return espFunc(v.Parent, dead)
			elseif v:GetAttribute("BloodColor") then
				local animal = esps[v.Parent.Name] or {HighlightEnabled = true, Color = getColor(v.Parent), Text = getItemText(v.Parent), ESPName = "Animal ESP"}
				esps[v.Name] = animal

				espFunc(v.Parent, animal)

				repeat task.wait() until not v or not v.Parent or isDead(v)

				pcall(espLib.DeapplyESP, v.Parent)

				local dead = desps[v.Parent.Name] or {HighlightEnabled = true, Color = Color3.new(1, 0.7, 0.7), Text = getItemText(v.Parent), ESPName = "Dead Animal ESP"}
				desps[v.Parent.Name] = dead

				return espFunc(v.Parent, dead)
			end
		elseif (v:IsA("BillboardGui") and v.Name == "ObjectInfo" and (getBase(v.Parent) and not getBase(v.Parent).Anchored or not getBase(v.Parent)) or v.Parent == workspace.RuntimeItems and v.Name ~= "Moneybag") and not checked[v] and not checked[v.Parent] then
			renderWait(0.01)
			if not v or not v.Parent or checked[v] or checked[v.Parent] then return end
			
			v = v:IsA("BillboardGui") and v or v:FindFirstChildWhichIsA("Instance")
			local tool = esps[v.Parent.Name] or {HighlightEnabled = false, Color = getColor(v.Parent), Text = getItemText(v.Parent), ESPName = "Item ESP"}

			esps[v.Parent.Name] = tool

			espFunc(v.Parent, tool)

			for i,va in pickupable do
				if hasProperty(v.Parent, va) then
					return add(tools, v.Parent)
				end
			end
			
			if v.Parent.Name == "Electrocutioner" or v.Parent.Name:lower():match("sword") then
				return add(tools, v.Parent)
			end

			if hasProperty(v.Parent, "Currency") then
				return add(bonds, v.Parent)
			end

			for i,va in armor do
				if hasProperty(v.Parent, va) then
					return add(equippables, v.Parent)
				end
			end

			if v.Parent:GetAttribute("ActivateText") then
				return add(other, v.Parent)
			end
		elseif v:IsA("Model") and v.Name == "Vault" and v:FindFirstChild("Combination") then
			checked[v] = true
			
			espFunc(v, {HighlightEnabled = true, Color = Color3.fromRGB(85, 170, 0), Text = "[" .. tostring(v.Combination.Value):gsub("", " ") .. "]", ESPName = "Vault CodeESP"})
		elseif v:IsA("MeshPart") and v.Name == "MoneyBag" then
			checked[v] = true
			checked[v.Parent] = true
			
			local price = tonumber(v:WaitForChild("BillboardGui", 9e9):WaitForChild("TextLabel", 9e9).Text:gsub("%$", "") .. "")
			local bag = esps[price] or {HighlightEnabled = true, Color = Color3.fromRGB(40, 85):Lerp(Color3.fromRGB(85, 255), math.min(price / 50, 1)), Text = price .. "$", ESPName = "Money Bag ESP"}

			esps[price] = bag

			espFunc(v, bag)
			add(prompts, v:WaitForChild("CollectPrompt", 9e9))
		end
	end
end


local function addOreESP()
    if not vals.ESP["Ore ESP"] then return end
    for _, ore in pairs(workspace.Ore:GetChildren()) do
        if ore:IsA("Model") then
            local oreESP = {
                HighlightEnabled = true,
                Color = Color3.fromRGB(255, 255, 255),
                Text = (ore.Name or "Unknown Ore"),
                ESPName = "Ore ESP"
            }
            esps[ore] = oreESP
            espFunc(ore, oreESP)
        end
    end
end

addOreESP()

workspace.Ore.ChildAdded:Connect(function(ore)
    task.wait()
    if ore:IsA("Model") and vals.ESP["Ore ESP"] then
        local oreESP = {
            HighlightEnabled = true,
            Color = Color3.fromRGB(255, 255, 255),
            Text = (ore.Name or "Unknown Ore"),
            ESPName = "Ore ESP"
        }
        esps[ore] = oreESP
        espFunc(ore, oreESP)
    end
end)




local function getClosestMonster(mode)
	mode = mode or vals.Mode
	if mode == "Angle" and workspace.CurrentCamera then
		local a, d, m = math.huge, math.huge, nil
		for i,v in monsters do
			if v and v.Parent and not isDead(v) then
				if vals.Raycast and raycast(workspace.CurrentCamera.CFrame.Position, v:GetPivot().Position, v:GetDescendants()) or (workspace.CurrentCamera.CFrame.Position - v:GetPivot().Position).Magnitude > vals.GunRadius then
					continue
				end

				local di = (plr.Character:GetPivot().Position - v:GetPivot().Position).Magnitude
				local an = ((workspace.CurrentCamera.CFrame.Position + (workspace.CurrentCamera.CFrame.LookVector * di)) - v:GetPivot().Position).Magnitude

				if an <= a then
					d = di
					a = an
					m = v
				end
			end
		end

		return m, d
	elseif mode == "Random" then
		local allowedMonsters = {}
		for i,v in monsters do
			if v and v.Parent and not isDead(v) then
				if vals.Raycast and raycast(workspace.CurrentCamera.CFrame.Position, v:GetPivot().Position, v:GetDescendants()) or (workspace.CurrentCamera.CFrame.Position - v:GetPivot().Position).Magnitude > vals.GunRadius then
					continue
				end

				add(allowedMonsters, v)
			end
		end

		if #allowedMonsters > 0 then
			local monster = allowedMonsters[math.random(1, #allowedMonsters)]
			return monster, monster and (plr.Character:GetPivot().Position - monster:GetPivot().Position).Magnitude
		end
	else
		local d, m = math.huge, nil
		for i,v in monsters do
			if v and v.Parent and not isDead(v) then
				if vals.Raycast and raycast(workspace.CurrentCamera.CFrame.Position, v:GetPivot().Position, v:GetDescendants()) or (workspace.CurrentCamera.CFrame.Position - v:GetPivot().Position).Magnitude > vals.GunRadius then
					continue
				end

				local di = (plr.Character:GetPivot().Position - v:GetPivot().Position).Magnitude

				if di <= d then
					d = di
					m = v
				end
			end
		end

		return m, d
	end
end

local gncm, hmm = getfenv().getnamecallmethod, getfenv().hookmetamethod
if hmm and gncm then
	local old; old = hmm(game, "__namecall", function(self, ...)
		if vals.Aimbot and self == s and gncm() == "FireServer" then
			local args = { ... }

			local m = getClosestMonster()

			if m then
				local hits = {}
				for i=1, args[2].WeaponConfiguration.PelletsPerBullet.Value do
					hits[tostring(i)] = m.Humanoid
				end

				local head = m:FindFirstChild("Head") or m:GetPivot()

				args[3] = CFrame.lookAt(head.Position + Vector3.new(0, 1), head.Position)
				args[4] = hits
			elseif vals.SaveBullets then
				args[2].ClientWeaponState.CurrentAmmo.Value += 1
				error("Cancel shoot", 0)
			end

			return s.FireServer(s, unpack(args))
		elseif vals.SaveBullets and self == s and gncm() == "FireServer" and not getClosestMonster() then
			({ ... })[2].ClientWeaponState.CurrentAmmo.Value += 1
			error("Cancel shoot", 0)
		end

		return old(self, ...)
	end)

	hooks[#hooks + 1] = function()
		hmm(game, "__namecall", old)
	end
end

task.spawn(function()
	while not closed and task.wait(0.1) do
		if vals.GunAura and plr.Character then
			local m = getClosestMonster()
			if m then
				for v in myGuns do
					if v and v.Parent and v:FindFirstChild("WeaponConfiguration") then
						pcall(shoot, v, m)
						task.wait(0.01)
					end
				end
			end
		end
	end
end)
task.spawn(function()
	while not closed and task.wait(0.1) do
		if vals.AutoReload and plr.Character then
			for v in myGuns do
				if v and v.Parent and v:FindFirstChild("WeaponConfiguration") then
					pcall(reload, v)
				end
			end
		end
	end
end)

local ad = 30
local farEvents = {}

local function equipUntilNoZombie(tool, zombie)
	tool.Parent = plr.Character

	if not farEvents[zombie] then
		farEvents[zombie] = Instance.new("BindableEvent")
		repeat task.wait() until not vals.MeleeAura or isDead(zombie)

		farEvents[zombie]:Fire()

		farEvents[zombie]:Destroy()
		farEvents[zombie] = nil
	else
		farEvents[zombie].Event:Wait()
	end

	tool.Parent = plr.Backpack
end

task.spawn(function()
	while not closed and task.wait(0.1) do
		if vals.MeleeAura then
			local m, d = getClosestMonster("Distance")
			if m and d <= ad then
				for v in melee do
					if v and v.Parent and v:FindFirstChild("SwingEvent") then
						if v.Parent == plr.Backpack then
							task.spawn(equipUntilNoZombie, v, m)
						end

						v.SwingEvent:FireServer(CFrame.lookAt(plr.Character:GetPivot().Position, m:GetPivot().Position + Vector3.new(0, 2)).LookVector)
					end
				end
			end
		end
	end
end)

for i,v in workspace:GetDescendants() do
	task.spawn(main, v)
end
cons[#cons+1] = workspace.DescendantAdded:Connect(main)

local void = pcall(function()
	workspace.FallenPartsDestroyHeight = workspace.FallenPartsDestroyHeight
end)

local oilCooldown = false
cons[#cons+1] = game:GetService("RunService").RenderStepped:Connect(function()
	if vals.FB then
		game.Lighting.Ambient = Color3.new(1, 1, 1)
		game.Lighting.Brightness = 1.5
	end
	if vals.NC then
		plr.CameraMode = Enum.CameraMode.Classic
	end
	if void then
		workspace.FallenPartsDestroyHeight = vals.NoVoid and 0/0 or -500
	end
	plr.DevCameraOcclusionMode = vals.NC and Enum.DevCameraOcclusionMode.Invisicam or Enum.DevCameraOcclusionMode.Zoom
	game.Lighting.GlobalShadows = not vals.FB
	if vals.AutoCollectBags then
		for i,v in prompts do
			if v and v.Parent then
				fireproximityprompt(v)
			else
				remove(prompts, v)
			end
		end
	end
	if vals.AutoPickTools then
			for i,v in tools do
				if v and v.Parent then
					if (v:GetPivot().Position - plr.Character:GetPivot().Position).Magnitude <= 30 then
						game:GetService("ReplicatedStorage").Remotes.Tool.PickUpTool:FireServer(v)
					end
				else
					remove(prompts, v)
				end
			end
		end
		if vals.AutoPickOther then
			for i,v in other do
				if v and v.Parent then
					if (v:GetPivot().Position - plr.Character:GetPivot().Position).Magnitude <= 30 then
						game:GetService("ReplicatedStorage").Packages.RemotePromise.Remotes.C_ActivateObject:FireServer(v)
					end
				else
					remove(prompts, v)
				end
			end
		end
		if vals.AutoPickBonds then
			for i,v in bonds do
				if v and v.Parent then
					if (v:GetPivot().Position - plr.Character:GetPivot().Position).Magnitude <= 30 then
						game:GetService("ReplicatedStorage").Packages.RemotePromise.Remotes.C_ActivateObject:FireServer(v)
					end
				else
					remove(prompts, v)
				end
			end
		end
		if vals.AutoPickArmor then
			for i,v in equippables do
				if v and v.Parent then
					if (v:GetPivot().Position - plr.Character:GetPivot().Position).Magnitude <= 30 then
						game:GetService("ReplicatedStorage").Remotes.Object.EquipObject:FireServer(v)
					end
				else
					remove(prompts, v)
				end
			end
		end

		local bandage = getFirst(heals.Bandage)
		if bandage and bandage.Parent and plr.Character:FindFirstChildOfClass("Humanoid").Health <= vals.BandageUse then
			return bandage.Use:FireServer(bandage)
		end

		local oil = getFirst(heals["Snake Oil"])
		if not oilCooldown and oil and oil.Parent and plr.Character:FindFirstChildOfClass("Humanoid").Health <= vals.OilUse then
			oilCooldown = true
			oil.Use:FireServer(oil)
			task.wait(vals.OilUseCooldown)
			oilCooldown = false
		end
	end
)

cons[#cons+1] = game:GetService("ProximityPromptService").PromptButtonHoldBegan:Connect(function(pp)
	if vals.InstantInteract then
		fireproximityprompt(pp, true)
	end
end)

local languageMenu = vals.Language or "EN"

if languageMenu == "TH" then
  local Window = WindUI:CreateWindow({
    Title = "VortexHub", -- UI Title
    Icon = "rbxassetid://71315952129083", -- Url or rbxassetid or lucide
    Author = "Dead Rails - ในเกม", -- Author & Creator
    Folder = "VortexHub", -- Folder name for saving data (And key)
    Size = UDim2.fromOffset(380, 260), -- UI Size
    Transparent = true,-- UI Transparency
    Theme = "Dark", -- UI Theme
    SideBarWidth = 170, -- UI Sidebar Width (number)
    HasOutline = true, -- Adds Outlines to the window
})

Window:EditOpenButton({
    Title = "VortexHub", -- Title
    Icon = "rbxassetid://71315952129083", -- Icon
    CornerRadius = UDim.new(0,5), -- Radius
    StrokeThickness = 1, -- Stroke Thickness
    Color = ColorSequence.new( -- Gradient
        Color3.fromHex("FF0F7B"), 
        Color3.fromHex("F89B29")
    ),
    Position = UDim2.new(0.5,0,0.5,0), -- Position
    Enabled = true,   -- true or false
    Draggable = true, -- true or false
})





local General = Window:Tab({Title = "ทั่วไป", Icon = "globe"})

General:Section({ 
    Title = "👤หัวข้อ: ตัวละคร",
    TextXAlignment = "Left",
    TextSize = 17, -- Default Size
})

General:Toggle({
    Title = "เดินทะลุ",
    Desc = "เดินทะลุสิ่งต่างๆ (ระวังตกแมพ)",
    Icon = "check", -- Icon
    Value = vals.Noclip,
    Callback = function(state)
        vals.Noclip = state
        SaveSetting()
        toggleNoclip(state)
    end,
})

General:Section({ 
    Title = "💰หัวข้อ: เก็บของ",
    TextXAlignment = "Left",
    TextSize = 17, -- Default Size
})

General:Toggle({
    Title = "เก็บถุงเงิน",
    Desc = "เก็บถุงเงินอัตโนมัติ",
    Icon = "check", -- Icon
    Value = vals.AutoCollectBags,
    Callback = function(state)
        vals.AutoCollectBags = state
        SaveSetting()
    end,
})

General:Toggle({
    Title = "เก็บอาวุธ",
    Desc = "เก็บอาวุธอัตโนมัติ",
    Icon = "check", -- Icon
    Value = vals.AutoPickTools,
    Callback = function(state)
        vals.AutoPickTools = state
        SaveSetting()
    end,
})

General:Toggle({
    Title = "เก็บเกราะ",
    Desc = "เก็บเกราะอัตโนมัติ",
    Icon = "check", -- Icon
    Value = vals.AutoPickArmor,
    Callback = function(state)
        vals.AutoPickArmor = state
        SaveSetting()
    end,
})

General:Toggle({
    Title = "เก็บเงินแดง",
    Desc = "เก็บเงินแดงอัตโนมัติ",
    Icon = "check", -- Icon
    Value = vals.AutoPickBonds,
    Callback = function(state)
        vals.AutoPickBonds = state
        SaveSetting()
    end,
})

General:Toggle({
    Title = "เก็บอื่นๆ",
    Desc = "เก็บไอเทมอื่นๆอัตโนมัติ เช่นกระสุน ผ้าพันแผล",
    Icon = "check", -- Icon
    Value = vals.AutoPickOther,
    Callback = function(state)
        vals.AutoPickOther = state
        SaveSetting()
    end,
})

General:Section({ 
    Title = "🎮หัวข้อ: ปรับแต่งเกม",
    TextXAlignment = "Left",
    TextSize = 17, -- Default Size
})

General:Toggle({
    Title = "กดปุ่มทันที",
    Desc = "กดปุ่ม ซื้อ/เก็บ ของทันทีแบบไม่ดีเลย์",
    Icon = "check", -- Icon
    Value = vals.InstantInteract,
    Callback = function(state)
        vals.InstantInteract = state
        SaveSetting()
    end,
})

General:Slider({
    Title = "ระยะการกดปุ่ม ( x เท่าตัว )",
    Step = 0.01,
    Value = {
        Min = 1,
        Max = 2,
        Default = vals.ExtraPrompt,
    },
    Callback = function(value)
        vals.ExtraPrompt = value
        SaveSetting()
	for i,v in oprompts do
		if i and i.Parent and v then
			i.MaxActivationDistance = v * value
		end
	end
    end
})

General:Button({
    Title = "บายพาสไปจุดจบ",
    Desc = "ควรเปิด Kill Aura ก่อน\nและรอเวลาเซิฟ 10 นาที ก่อนกดสะพาน",
    Callback = function()
        BypassEnd()
    end,
})

General:Button({
    Title = "วาร์ปไปที่รถไฟ",
    Desc = "อาจวาร์ปไม่ได้ ถ้าอยู่ไกลเกินไป",
    Callback = function()
        GoToTrainTP()
    end,
})

if void then
  General:Toggle({
    Title = "ลบใต้โลก",
    Desc = "ลบ void ใต้แมพออก ให้ตกโลกไม่ตาย",
    Icon = "check", -- Icon
    Value = vals.NoVoid,
    Callback = function(state)
        vals.NoVoid = state
        SaveSetting()
    end,
})
end


General:Section({ 
    Title = "♥️หัวข้อ: ฮีลเลือด",
    TextXAlignment = "Left",
    TextSize = 17, -- Default Size
})


General:Slider({
    Title = "ใช้ผ้าพันแผลอัตโนมัติ เมื่อเลือดเหลือ:",
    Step = 0.5,
    Value = {
        Min = 0,
        Max = 99.5,
        Default = vals.BandageUse,
    },
    Callback = function(value)
        vals.BandageUse = value
        SaveSetting()
    end
})


General:Slider({
    Title = "ใช้น้ำมันงูอัตโนมัติ เมื่อเลือดเหลือ:",
    Step = 0.5,
    Value = {
        Min = 0,
        Max = 100,
        Default = vals.OilUse,
    },
    Callback = function(value)
        vals.OilUse = value
        SaveSetting()
    end
})

General:Slider({
    Title = "ระยะเวลารอระหว่างการใช้น้ำมันงู:",
    Step = 0.1,
    Value = {
        Min = 0,
        Max = 10,
        Default = vals.OilUseCooldown,
    },
    Callback = function(value)
        vals.OilUseCooldown = value
        SaveSetting()
    end
})



local Visual = Window:Tab({Title = "โปรมอง", Icon = "scan-eye"})


Visual:Section({ 
    Title = "📃หัวข้อ: ข้อมูลรถไฟ",
    TextXAlignment = "Left",
    TextSize = 17, -- Default Size
})

local ShowDistance = Visual:Paragraph({
    Title = "ระยะทาง: N/A",
    Image = "train-front", -- lucide or URL or rbxassetid://
    ImageSize = 20,
})

local ShowTime = Visual:Paragraph({
    Title = "เวลา: N/A",
    Image = "alarm-clock", -- lucide or URL or rbxassetid://
    ImageSize = 20,
})

local ShowSpeed = Visual:Paragraph({
    Title = "ความเร็ว: N/A",
    Image = "clock-arrow-up", -- lucide or URL or rbxassetid://
    ImageSize = 20,
})


local ShowFuel = Visual:Paragraph({
    Title = "เชื้อเพลิง: N/A",
    Image = "flame", -- lucide or URL or rbxassetid://
    ImageSize = 20,
})

local ShowTimePlay = Visual:Paragraph({
    Title = "เวลาเซิฟเวอร์: N/A",
    Image = "clock-10", -- lucide or URL or rbxassetid://
    ImageSize = 20,
})

Visual:Section({ 
    Title = "👁️หัวข้อ: การมองเห็น",
    TextXAlignment = "Left",
    TextSize = 17, -- Default Size
})


Visual:Toggle({
    Title = "เพิ่มแสง",
    Desc = "มองตอนกลางคืนได้",
    Icon = "check", -- Icon
    Value = vals.FB,
    Callback = function(state)
        vals.FB = state
        SaveSetting()
    end,
})

Visual:Toggle({
    Title = "มุมกล้องซูมได้",
    Desc = "ปิดใช้งานโหมด First Person",
    Icon = "check", -- Icon
    Value = vals.NC,
    Callback = function(state)
        vals.NC = state
        SaveSetting()
	rs(2)
	plr.CameraMode = vals.NC and Enum.CameraMode.Classic or Enum.CameraMode.LockFirstPerson
	if state then
	local noti = WindUI:Notify({
    Title = "โปรมุมกล้อง",
    Content = "ตอนนี้คุณซูมออกได้แล้ว",
    Duration = 3,
})
	end
    end,
})

Visual:Section({ 
    Title = "🌐หัวข้อ: โปรมอง",
    TextXAlignment = "Left",
    TextSize = 17, -- Default Size
})

local activated = false


for i,v in vals.ESP do
	Visual:Toggle({Title = i:gsub("ESP", " ESP"), Icon = "check", Value = v, Callback = function(state)
		espLib.ESPValues[i] = state
		SaveSetting()
	end})
end




local Weapon = Window:Tab({Title = "อาวุธ", Icon = "target"})


Weapon:Section({ 
    Title = "🔫หัวข้อ: Kill Aura",
    TextXAlignment = "Left",
    TextSize = 17, -- Default Size
})

Weapon:Toggle({
    Title = "Gun Aura",
    Desc = "ยิงมอนที่อยู่ในระยะอัตโนมัติ (ยิ่งปืนเยอะยิ่งโหด)",
    Icon = "check", -- Icon
    Value = vals.GunAura,
    Callback = function(state)
        vals.GunAura = state
        SaveSetting()
    end,
})



Weapon:Toggle({
    Title = "Melee Aura",
    Desc = "ใช้อาวุธระยะประชิด อัตโนมัติเมื่อมอนเข้าใกล้ระยะอันตราย",
    Icon = "check", -- Icon
    Value = vals.MeleeAura,
    Callback = function(state)
        vals.MeleeAura = state
        SaveSetting()
    end,
})

Weapon:Section({ 
    Title = "⚙️หัวข้อ: ตั้งค่า",
    TextXAlignment = "Left",
    TextSize = 17, -- Default Size
})

Weapon:Slider({
    Title = "ระยะปืน",
    Step = 1,
    Value = {
        Min = 10,
        Max = 2501,
        Default = vals.GunRadius,
    },
    Callback = function(value)
vals.GunRadius = value >= 2751 and 228_1488 or value >= 2501 and 2500 or value
SaveSetting()
end
})


local t = {"Distance", "Angle", "Random"}

Weapon:Dropdown({
    Title = "ล็อคเป้าหมายโดย",
    Desc = "เรียงลำดับการล็อคเป้าของ Gun Aura/ล็อคเป้า",
    Value = vals.Mode,
    Multi = false,
    AllowNone = true,
    Values = t,
    Callback = function(Tab)
        vals.Mode = t[Tab]
        SaveSetting()
    end
})



Weapon:Toggle({
    Title = "รีโหลดอัตโนมัติ",
    Desc = "รีโหลดกระสุนอัตโนมัติเมื่อกระสุนลด",
    Icon = "check", -- Icon
    Value = vals.AutoReload,
    Callback = function(state)
        vals.AutoReload = state
        SaveSetting()
    end,
})


if hmm and gncm then
  
  Weapon:Toggle({
    Title = "ล็อคเป้า",
    Desc = "โปรล็อคเป้า มอน ยิงยังไงก็โดน",
    Icon = "check", -- Icon
    Value = vals.Aimbot,
    Callback = function(state)
        vals.Aimbot = state
        SaveSetting()
    end,
})
Weapon:Toggle({
    Title = "ประหยัดกระสุน",
    Desc = "ป้องกันการยิงปืนลั่นตอนไม่มีมอนในระยะ",
    Icon = "check", -- Icon
    Value = vals.SaveBullets,
    Callback = function(state)
        vals.SaveBullets = state
        SaveSetting()
    end,
})
end

espFunc(workspace:WaitForChild("Train", 9e9), {HighlightEnabled = false, Color = Color3.fromRGB(55, 65, 65), Text = "Train", ESPName = "Train ESP"})

local startTime = tick()

cons[#cons+1] = game:GetService("RunService").RenderStepped:Connect(function()
	if workspace.Train.TrainControls:FindFirstChild("TimeDial") then
		local currentTime = tick() - startTime
		local hours = math.floor(currentTime / 3600)
		local minutes = math.floor((currentTime % 3600) / 60)
		local seconds = math.floor(currentTime % 60)
		local milliseconds = math.floor((currentTime % 1) * 1000)

		ShowTime:SetTitle("เวลา: " .. workspace.Train.TrainControls.TimeDial.SurfaceGui.TextLabel.Text)
		ShowDistance:SetTitle("ระยะทาง: " .. workspace.Train.TrainControls.DistanceDial.SurfaceGui.TextLabel.Text)
		ShowSpeed:SetTitle("ความเร็ว: " .. (math.round((workspace.Train.TrainControls.Spedometer.SurfaceGui.ImageLabel.Gauge.Rotation - 120) / 163 * 65 * 10) / 10) .. " s/s")
		ShowFuel:SetTitle("เชื้อเพลิง: " .. (math.round((workspace.Train.TrainControls.Fuel.SurfaceGui.ImageLabel.Gauge.Rotation - 120) / 300 * 1000) / 10) .. "%")
		ShowTimePlay:SetTitle(string.format("เวลาเซิฟเวอร์: %02d : %02d : %02d : %03d", hours, minutes, seconds, milliseconds))
	end
end)

Window:SelectTab(1) -- Number of Tab
else -- Default English
  local Window = WindUI:CreateWindow({
    Title = "VortexHub", -- UI Title
    Icon = "rbxassetid://71315952129083", -- Url or rbxassetid or lucide
    Author = "Dead Rails - Game", -- Author & Creator
    Folder = "VortexHub", -- Folder name for saving data (And key)
    Size = UDim2.fromOffset(380, 260), -- UI Size
    Transparent = true,-- UI Transparency
    Theme = "Dark", -- UI Theme
    SideBarWidth = 170, -- UI Sidebar Width (number)
    HasOutline = true, -- Adds Outlines to the window
})

Window:EditOpenButton({
    Title = "VortexHub", -- Title
    Icon = "rbxassetid://71315952129083", -- Icon
    CornerRadius = UDim.new(0,5), -- Radius
    StrokeThickness = 1, -- Stroke Thickness
    Color = ColorSequence.new( -- Gradient
        Color3.fromHex("FF0F7B"), 
        Color3.fromHex("F89B29")
    ),
    Position = UDim2.new(0.5,0,0.5,0), -- Position
    Enabled = true,   -- true or false
    Draggable = true, -- true or false
})





local General = Window:Tab({Title = "General", Icon = "globe"})

General:Section({ 
    Title = "👤Topic: Character",
    TextXAlignment = "Left",
    TextSize = 17, -- Default Size
})

General:Toggle({
    Title = "No Clip",
    Desc = "Walk through objects",
    Icon = "check", -- Icon
    Value = vals.Noclip,
    Callback = function(state)
        vals.Noclip = state
        SaveSetting()
        toggleNoclip(state)
    end,
})

General:Section({ 
    Title = "💰Topic: Interact",
    TextXAlignment = "Left",
    TextSize = 17, -- Default Size
})

General:Toggle({
    Title = "Auto Money Bag",
    Desc = "Automatically Pickup money bags",
    Icon = "check", -- Icon
    Value = vals.AutoCollectBags,
    Callback = function(state)
        vals.AutoCollectBags = state
        SaveSetting()
    end,
})

General:Toggle({
    Title = "Auto Grab Tools",
    Desc = "Automatically Pickup tools",
    Icon = "check", -- Icon
    Value = vals.AutoPickTools,
    Callback = function(state)
        vals.AutoPickTools = state
        SaveSetting()
    end,
})

General:Toggle({
    Title = "Auto Grab Armors",
    Desc = "Automatically Pickup armors",
    Icon = "check", -- Icon
    Value = vals.AutoPickArmor,
    Callback = function(state)
        vals.AutoPickArmor = state
        SaveSetting()
    end,
})

General:Toggle({
    Title = "Auto Grab Bonds",
    Desc = "Automatically Pickup Bonds",
    Icon = "check", -- Icon
    Value = vals.AutoPickBonds,
    Callback = function(state)
        vals.AutoPickBonds = state
        SaveSetting()
    end,
})

General:Toggle({
    Title = "Auto Grab Others",
    Desc = "Automatically Pickup ammo and others",
    Icon = "check", -- Icon
    Value = vals.AutoPickOther,
    Callback = function(state)
        vals.AutoPickOther = state
        SaveSetting()
    end,
})

General:Section({ 
    Title = "🎮Topic: Game Modify",
    TextXAlignment = "Left",
    TextSize = 17, -- Default Size
})

General:Toggle({
    Title = "Instant Interact",
    Desc = "Interact thing instantly with no delays",
    Icon = "check", -- Icon
    Value = vals.InstantInteract,
    Callback = function(state)
        vals.InstantInteract = state
        SaveSetting()
    end,
})

General:Slider({
    Title = "Prompt activation distance multiplier",
    Step = 0.01,
    Value = {
        Min = 1,
        Max = 2,
        Default = vals.ExtraPrompt,
    },
    Callback = function(value)
        vals.ExtraPrompt = value
        SaveSetting()
	for i,v in oprompts do
		if i and i.Parent and v then
			i.MaxActivationDistance = v * value
		end
	end
    end
})


General:Button({
    Title = "Bypass To The End",
    Desc = "Should turn on Kill Aura first!!\nwait 10 minute before turn crank",
    Callback = function()
        BypassEnd()
    end,
})

General:Button({
    Title = "Teleport to train",
    Desc = "May not work if too far away from train",
    Callback = function()
        GoToTrainTP()
    end,
})


if void then
  General:Toggle({
    Title = "No Void",
    Desc = "(fix death when falling under map)",
    Icon = "check", -- Icon
    Value = vals.NoVoid,
    Callback = function(state)
        vals.NoVoid = state
        SaveSetting()
    end,
})
end


General:Section({ 
    Title = "♥️Topic: Healing",
    TextXAlignment = "Left",
    TextSize = 17, -- Default Size
})


General:Slider({
    Title = "Auto use Bandage when has HP:",
    Step = 0.5,
    Value = {
        Min = 0,
        Max = 99.5,
        Default = vals.BandageUse,
    },
    Callback = function(value)
        vals.BandageUse = value
        SaveSetting()
    end
})


General:Slider({
    Title = "Auto use Snake Oil when has HP:",
    Step = 0.5,
    Value = {
        Min = 0,
        Max = 100,
        Default = vals.OilUse,
    },
    Callback = function(value)
        vals.OilUse = value
        SaveSetting()
    end
})

General:Slider({
    Title = "Auto use Snake Oil Cooldown:",
    Step = 0.1,
    Value = {
        Min = 0,
        Max = 10,
        Default = vals.OilUseCooldown,
    },
    Callback = function(value)
        vals.OilUseCooldown = value
        SaveSetting()
    end
})



local Visual = Window:Tab({Title = "Visual", Icon = "scan-eye"})


Visual:Section({ 
    Title = "📃Topic: Show Info",
    TextXAlignment = "Left",
    TextSize = 17, -- Default Size
})

local ShowDistance = Visual:Paragraph({
    Title = "Distance: N/A",
    Image = "train-front", -- lucide or URL or rbxassetid://
    ImageSize = 20,
})

local ShowTime = Visual:Paragraph({
    Title = "Time: N/A",
    Image = "alarm-clock", -- lucide or URL or rbxassetid://
    ImageSize = 20,
})

local ShowSpeed = Visual:Paragraph({
    Title = "Speed: N/A",
    Image = "clock-arrow-up", -- lucide or URL or rbxassetid://
    ImageSize = 20,
})


local ShowFuel = Visual:Paragraph({
    Title = "Fuel: N/A",
    Image = "flame", -- lucide or URL or rbxassetid://
    ImageSize = 20,
})

local ShowTimePlay = Visual:Paragraph({
    Title = "Server Time: N/A",
    Image = "clock-10", -- lucide or URL or rbxassetid://
    ImageSize = 20,
})


Visual:Section({ 
    Title = "👁️Topic: Visual",
    TextXAlignment = "Left",
    TextSize = 17, -- Default Size
})


Visual:Toggle({
    Title = "Full Bright",
    Desc = "just a bull fright",
    Icon = "check", -- Icon
    Value = vals.FB,
    Callback = function(state)
        vals.FB = state
        SaveSetting()
    end,
})

Visual:Toggle({
    Title = "Normal Camera",
    Desc = "disable first person camera",
    Icon = "check", -- Icon
    Value = vals.NC,
    Callback = function(state)
        vals.NC = state
        SaveSetting()
	rs(2)
	plr.CameraMode = vals.NC and Enum.CameraMode.Classic or Enum.CameraMode.LockFirstPerson
	if state then
	local noti = WindUI:Notify({
    Title = "Normal Camera",
    Content = "You can now Zoom Out",
    Duration = 5,
})
	end
    end,
})

Visual:Section({ 
    Title = "🌐Topic: ESP",
    TextXAlignment = "Left",
    TextSize = 17, -- Default Size
})

local activated = false


for i,v in vals.ESP do
	Visual:Toggle({Title = i:gsub("ESP", " ESP"), Icon = "check", Value = v, Callback = function(state)
		espLib.ESPValues[i] = state
		SaveSetting()
	end})
end




local Weapon = Window:Tab({Title = "Weapon", Icon = "target"})


Weapon:Section({ 
    Title = "🔫Topic: Kill Aura",
    TextXAlignment = "Left",
    TextSize = 17, -- Default Size
})

Weapon:Toggle({
    Title = "Gun Aura",
    Desc = "auto shoot nearby enemy (not very stable)",
    Icon = "check", -- Icon
    Value = vals.GunAura,
    Callback = function(state)
        vals.GunAura = state
        SaveSetting()
    end,
})



Weapon:Toggle({
    Title = "Melee Aura",
    Desc = "Auto use melee item when enemy near",
    Icon = "check", -- Icon
    Value = vals.MeleeAura,
    Callback = function(state)
        vals.MeleeAura = state
        SaveSetting()
    end,
})

Weapon:Section({ 
    Title = "⚙️Topic: Settings",
    TextXAlignment = "Left",
    TextSize = 17, -- Default Size
})

Weapon:Slider({
    Title = "Gun Radius",
    Step = 1,
    Value = {
        Min = 10,
        Max = 2501,
        Default = vals.GunRadius,
    },
    Callback = function(value)
vals.GunRadius = value >= 2751 and 228_1488 or value >= 2501 and 2500 or value
SaveSetting()
end
})


local t = {"Distance", "Angle", "Random"}

Weapon:Dropdown({
    Title = "Target by",
    Desc = "targeting enemy by",
    Value = vals.Mode,
    Multi = false,
    AllowNone = true,
    Values = t,
    Callback = function(Tab)
        vals.Mode = t[Tab]
        SaveSetting()
    end
})



Weapon:Toggle({
    Title = "Auto Reload",
    Desc = "automatically reload ammo instantly",
    Icon = "check", -- Icon
    Value = vals.AutoReload,
    Callback = function(state)
        vals.AutoReload = state
        SaveSetting()
    end,
})


if hmm and gncm then
  
  Weapon:Toggle({
    Title = "Aimbot",
    Desc = "no matter where you aimming, bullets will hit enemy for sure",
    Icon = "check", -- Icon
    Value = vals.Aimbot,
    Callback = function(state)
        vals.Aimbot = state
        SaveSetting()
    end,
})
Weapon:Toggle({
    Title = "Save Bullet",
    Desc = "not wasting bullet",
    Icon = "check", -- Icon
    Value = vals.SaveBullets,
    Callback = function(state)
        vals.SaveBullets = state
        SaveSetting()
    end,
})
end

espFunc(workspace:WaitForChild("Train", 9e9), {HighlightEnabled = false, Color = Color3.fromRGB(55, 65, 65), Text = "Train", ESPName = "Train ESP"})

local startTime = tick()

cons[#cons+1] = game:GetService("RunService").RenderStepped:Connect(function()
	if workspace.Train.TrainControls:FindFirstChild("TimeDial") then
		local currentTime = tick() - startTime
		local hours = math.floor(currentTime / 3600)
		local minutes = math.floor((currentTime % 3600) / 60)
		local seconds = math.floor(currentTime % 60)
		local milliseconds = math.floor((currentTime % 1) * 1000)

		ShowTime:SetTitle("Time: " .. workspace.Train.TrainControls.TimeDial.SurfaceGui.TextLabel.Text)
		ShowDistance:SetTitle("Traveled: " .. workspace.Train.TrainControls.DistanceDial.SurfaceGui.TextLabel.Text)
		ShowSpeed:SetTitle("Speed: " .. (math.round((workspace.Train.TrainControls.Spedometer.SurfaceGui.ImageLabel.Gauge.Rotation - 120) / 163 * 65 * 10) / 10) .. " s/s")
		ShowFuel:SetTitle("Fuel: " .. (math.round((workspace.Train.TrainControls.Fuel.SurfaceGui.ImageLabel.Gauge.Rotation - 120) / 300 * 1000) / 10) .. "%")
		ShowTimePlay:SetTitle(string.format("Server Time: %02d : %02d : %02d : %03d", hours, minutes, seconds, milliseconds))
	end
	end)
end