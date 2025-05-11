local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
end)

local Window = Rayfield:CreateWindow({
    Name = "VortexHub - BloxFruit(Beta)",
    LoadingTitle = "กำลังโหลด UI...",
    LoadingSubtitle = "By VortexHub",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

local AutoFarmTab = Window:CreateTab("ออโต้ฟาร์ม", 4483362458)
local AutoFarmSection = AutoFarmTab:CreateSection("ตั้งค่าออโต้ฟาร์ม")



AutoFarm = false
AutoAttack = false

local EquipToggle = AutoFarmTab:CreateToggle({
    Name = "ออโต้ถือหมัด",
    CurrentValue = false,
    Flag = "AutoEquipFightingStyle",
    Callback = function(Value)
        ToggleOn = Value

        if ToggleOn then
            task.spawn(function()
                while ToggleOn do
                    local styles = {
                        "Combat", "Black Leg", "Electro", "FishmanKarate", "DragonClaw",
                        "Superhuman", "Death Step", "Electric Claw", "Sharkman Karate",
                        "Dragon Talon", "Godhuman", "Sanguine Art"
                    }

                    local player = game.Players.LocalPlayer
                    local char = player.Character
                    local backpack = player:FindFirstChild("Backpack")

                    local isEquipped = false
                    for _, style in ipairs(styles) do
                        if char:FindFirstChild(style) then
                            isEquipped = true
                            break
                        end
                    end

                    if not isEquipped then
                        for _, style in ipairs(styles) do
                            local tool = backpack:FindFirstChild(style)
                            if tool and tool:FindFirstChild("EquipEvent") then
                                tool.Parent = char
                                task.wait(0.1)
                                tool.EquipEvent:FireServer(false)
                                break
                            end
                        end
                    end

                    task.wait(1)
                end
            end)
        end
    end,
})

local EquipSwordToggle = AutoFarmTab:CreateToggle({
    Name = "ออโต้ถือดาบ",
    CurrentValue = false,
    Flag = "AutoEquipSword",
    Callback = function(Value)
        ToggleOn = Value

        if ToggleOn then
            task.spawn(function()
                while ToggleOn do
                    local swords = {
                        "Katana", "Cutlass", "Iron Mace", "Pipe", "Triple Katana", "Dual Katana",
                        "Shark Saw", "Soul Cane", "Dragon Trident", "Gravity Cane", "Jitte",
                        "Longsword", "Trident", "Twin Hooks", "Bisento", "Pole", "Warden Sword",
                        "Saddi", "Shisui", "Wando", "Rengoku", "Saber", "Spikey Trident",
                        "Tushita", "Yama", "Hallow Scythe", "Cursed Dual Katana", "Buddy Sword",
                        "Canvander", "Midnight Blade", "Dark Blade", "True Triple Katana",
                        "Holy Crown", "Hell Sword", "Twin Slashers", "DragonScale Trident",
                        "Ruyi Staff", "Jade Dragon Slicer"
                    }

                    local player = game.Players.LocalPlayer
                    local char = player.Character
                    local backpack = player:FindFirstChild("Backpack")

                    if char and backpack then
                        local humanoid = char:FindFirstChildOfClass("Humanoid")
                        for _, tool in ipairs(backpack:GetChildren()) do
                            if table.find(swords, tool.Name) then
                                humanoid:EquipTool(tool)
                                break
                            end
                        end
                    end

                    task.wait(1)
                end
            end)
        end
    end
})

local BringMobs = false

AutoFarmTab:CreateToggle({
    Name = "ดึงมอน",
    CurrentValue = false,
    Flag = "BringMobs",
    Callback = function(Value)
        BringMobs = Value

        if BringMobs then
            task.spawn(function()
                local LocalPlayer = game.Players.LocalPlayer
                local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                local rootPart = character:WaitForChild("HumanoidRootPart")
                local pullRange = 500

                while BringMobs do
                    for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                        local hrp = enemy:FindFirstChild("HumanoidRootPart")
                        local humanoid = enemy:FindFirstChild("Humanoid")

                        if hrp and humanoid and (hrp.Position - rootPart.Position).Magnitude <= pullRange then
                            hrp.CFrame = rootPart.CFrame * CFrame.new(-10, 0, 0)
                            humanoid.WalkSpeed = 0
                        end
                    end

                    if sethiddenproperty then
                        sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
                    end

                    task.wait(0.1)
                end
            end)
        end
    end
})

local bringConnection

AutoFarmTab:CreateToggle({
    Name = "ล็อคมอน(แนะนำให้เปิด)",
    CurrentValue = false,
    Flag = "ToggleAnchorMobs",
    Callback = function(Value)
        if Value then
            if sethiddenproperty then
                sethiddenproperty(game.Players.LocalPlayer, "SimulationRadius", math.huge)
            end

            bringConnection = workspace.Enemies.ChildAdded:Connect(function(mob)
                task.wait(0.1)
                if mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") then
                    mob.Humanoid.WalkSpeed = 0
                    mob.Humanoid.JumpPower = 0
                    mob.HumanoidRootPart.Anchored = true
                end
            end)

            for _, mob in pairs(workspace.Enemies:GetChildren()) do
                if mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") then
                    mob.Humanoid.WalkSpeed = 0
                    mob.Humanoid.JumpPower = 0
                    mob.HumanoidRootPart.Anchored = true
                end
            end
        else
            if bringConnection then
                bringConnection:Disconnect()
                bringConnection = nil
            end

            for _, mob in pairs(workspace.Enemies:GetChildren()) do
                if mob:FindFirstChild("HumanoidRootPart") then
                    mob.HumanoidRootPart.Anchored = false
                end
            end
        end
    end,
})

AutoFarmTab:CreateToggle({
    Name = "ออโต้ฟาร์มเลเวล",
    CurrentValue = false,
    Flag = "AutoFarm",
    Callback = function(value)
        AutoFarm = value
        AutoAttack = value
        if value then
            StartAutoFarm()
            StartAutoAttack()
            local args = {
                [1] = "Buso"
            }
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args))
        else
            AutoFarm = false
            AutoAttack = false
        end
    end
})

AutoFarmTab:CreateToggle({
    Name = "ออโต้ฟาร์มรอบตัว",
    CurrentValue = false,
    Flag = "AutoFarmAll",
    Callback = function(Value)
        AutoFarmAll = Value
        AutoAttack = Value
        if Value then
            local args = {
                [1] = "Buso"
            }
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args))
            StartAutoAttack()
            spawn(function()
                while AutoFarmAll and task.wait() do
                    pcall(function()
                        local targetEnemy = nil
                        for _, v in pairs(workspace.Enemies:GetChildren()) do
                            if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
                                targetEnemy = v
                                break
                            end
                        end
                        if targetEnemy then
                            local floatPos = targetEnemy.HumanoidRootPart.CFrame * CFrame.new(0, 20, 0)
                            local travelTime = Tween(floatPos)
                            task.wait(travelTime + 0.1)
                            while AutoFarmAll and targetEnemy and targetEnemy.Parent and targetEnemy:FindFirstChild("Humanoid") and targetEnemy.Humanoid.Health > 0 do
                                task.wait()
                                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = floatPos
                            end
                        end
                    end)
                end
            end)
        else
            AutoFarmAll = false
            AutoAttack = false
        end
    end
})

function StartAutoFarm()
    local LocalPlayer = game:GetService("Players").LocalPlayer

    local function GetQuest(A, B)
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", A or "BanditQuest1", B or 1)
    end

    local function DataQuest()
        local Lvl = LocalPlayer.Data.Level
            if Lvl.Value >= 1500 and Lvl.Value <= 1524 then 
            Enemy = "Pirate Millionaire" 
            QuestName = "PiratePortQuest" 
            QuestNumber = 1 
            QuestPos = CFrame.new(-290.074677, 42.9034653, 5581.58984, 0.965929627, -0, -0.258804798, 0, 1, -0, 0.258804798, 0,0.965929627)  
            EnemyPos = CFrame.new(-245.9963836669922, 47.30615234375, 5584.1005859375)
            elseif Lvl.Value >= 1525 and Lvl.Value <= 1574 then
            Enemy = "Pistol Billionaire"
            QuestName = "PiratePortQuest"
            QuestNumber = 2
            QuestPos = CFrame.new(-290.074677, 42.9034653, 5581.58984, 0.965929627, -0, -0.258804798, 0, 1, -0, 0.258804798, 0, 0.965929627)
            EnemyPos = CFrame.new(-187.3301544189453, 86.23987579345703, 6013.513671875)
            elseif Lvl.Value >= 1575 and Lvl.Value <= 1599 then
            Enemy = "Dragon Crew Warrior"
            QuestName = "AmazonQuest"
            QuestNumber = 1
            QuestPos = CFrame.new(5832.83594, 51.6806107, -1101.51563, 0.898790359, -0, -0.438378751, 0, 1, -0, 0.438378751, 0, 0.898790359)
            EnemyPos = CFrame.new(6141.140625, 51.35136413574219, -1340.738525390625)
            elseif Lvl.Value >= 1600 and Lvl.Value <= 1624 then
            Enemy = "Dragon Crew Archer"
            QuestName = "AmazonQuest"
            QuestNumber = 2
            QuestPos = CFrame.new(5833.1147460938, 51.60498046875, -1103.0693359375)
            EnemyPos = CFrame.new(6616.41748046875, 441.7670593261719, 446.0469970703125)
            elseif Lvl.Value >= 1625 and Lvl.Value <= 1649 then
            Enemy = "Female Islander"
            QuestName = "AmazonQuest2"
            QuestNumber = 1
            QuestPos = CFrame.new(5446.8793945313, 601.62945556641, 749.45672607422)
            EnemyPos = CFrame.new(4685.25830078125, 735.8078002929688, 815.3425903320312)
            elseif Lvl.Value >= 1650 and Lvl.Value <= 1699 then
            Enemy = "Giant Islander"
            QuestName = "AmazonQuest2"
            QuestNumber = 2
            QuestPos = CFrame.new(5446.8793945313, 601.62945556641, 749.45672607422)
            EnemyPos = CFrame.new(4729.09423828125, 590.436767578125, -36.97627639770508)
            elseif Lvl.Value >= 1700 and Lvl.Value <= 1724 then
            Enemy = "Marine Commodore"
            QuestName = "MarineTreeIsland"
            QuestNumber = 1
            QuestPos = CFrame.new(2180.54126, 27.8156815, -6741.5498, -0.965929747, 0, 0.258804798, 0, 1, 0, -0.258804798, 0, -0.965929747)
            EnemyPos = CFrame.new(2286.0078125, 73.13391876220703, -7159.80908203125)
            elseif Lvl.Value >= 1725 and Lvl.Value <= 1774 then
            Enemy = "Marine Rear Admiral"
            QuestName = "MarineTreeIsland"
            QuestNumber = 2
            QuestPos = CFrame.new(2179.98828125, 28.731239318848, -6740.0551757813)
            EnemyPos = CFrame.new(3656.773681640625, 160.52406311035156, -7001.5986328125)
            elseif Lvl.Value >= 1775 and Lvl.Value <= 1799 then
            Enemy = "Fishman Raider"
            QuestName = "DeepForestIsland3"
            QuestNumber = 1
            QuestPos = CFrame.new(-10581.6563, 330.872955, -8761.18652, -0.882952213, 0, 0.469463557, 0, 1, 0, -0.469463557, 0, -0.882952213)
            EnemyPos = CFrame.new(-10407.5263671875, 331.76263427734375, -8368.5166015625)
            elseif Lvl.Value >= 1800 and Lvl.Value <= 1824 then
            Enemy = "Fishman Captain"
            QuestName = "DeepForestIsland3"
            QuestNumber = 2
            QuestPos = CFrame.new(-10581.6563, 330.872955, -8761.18652, -0.882952213, 0, 0.469463557, 0, 1, 0, -0.469463557, 0, -0.882952213)
            EnemyPos = CFrame.new(-10994.701171875, 352.38140869140625, -9002.1103515625)
            elseif Lvl.Value >= 1825 and Lvl.Value <= 1874 then
            Enemy = "Forest Pirate"
            QuestName = "DeepForestIsland"
            QuestNumber = 1
            QuestPos = CFrame.new(-13234.04, 331.488495, -7625.40137, 0.707134247, -0, -0.707079291, 0, 1, -0, 0.707079291, 0, 0.707134247)
            EnemyPos = CFrame.new(-13274.478515625, 332.3781433105469, -7769.58056640625)
            elseif Lvl.Value >= 1875 and Lvl.Value <= 1899 then
            Enemy = "Mythological Pirate"
            QuestName = "DeepForestIsland"
            QuestNumber = 2
            QuestPos = CFrame.new(-13234.04, 331.488495, -7625.40137, 0.707134247, -0, -0.707079291, 0, 1, -0, 0.707079291, 0, 0.707134247)
            EnemyPos = CFrame.new(-13680.607421875, 501.08154296875, -6991.189453125)
            elseif Lvl.Value >= 1900 and Lvl.Value <= 1924 then
            Enemy = "Jungle Pirate"
            QuestName = "DeepForestIsland2"
            QuestNumber = 1
            QuestPos = CFrame.new(-12680.3818, 389.971039, -9902.01953, -0.0871315002, 0, 0.996196866, 0, 1, 0, -0.996196866, 0, -0.0871315002)
            EnemyPos = CFrame.new(-12256.16015625, 331.73828125, -10485.8369140625)
            elseif Lvl.Value >= 1925 and Lvl.Value <= 1974 then
            Enemy = "Musketeer Pirate"
            QuestName = "DeepForestIsland2"
            QuestNumber = 2
            QuestPos = CFrame.new(-12680.3818, 389.971039, -9902.01953, -0.0871315002, 0, 0.996196866, 0, 1, 0, -0.996196866, 0, -0.0871315002)
            EnemyPos = CFrame.new(-13457.904296875, 391.545654296875, -9859.177734375)
            elseif Lvl.Value >= 1975 and Lvl.Value <= 1999 then
            Enemy = "Reborn Skeleton"
            QuestName = "HauntedQuest1"
            QuestNumber = 1
            QuestPos = CFrame.new(-9479.2168, 141.215088, 5566.09277, 0, 0, 1, 0, 1, -0, -1, 0, 0)
            EnemyPos = CFrame.new(-8763.7236328125, 165.72299194335938, 6159.86181640625)
            elseif Lvl.Value >= 2000 and Lvl.Value <= 2024 then
            Enemy = "Living Zombie"
            QuestName = "HauntedQuest1"
            QuestNumber = 2
            QuestPos = CFrame.new(-9479.2168, 141.215088, 5566.09277, 0, 0, 1, 0, 1, -0, -1, 0, 0)
            EnemyPos = CFrame.new(-10144.1318359375, 138.62667846679688, 5838.0888671875)
            elseif Lvl.Value >= 2025 and Lvl.Value <= 2049 then
            Enemy = "DeMonsteric Soul"
            QuestName = "HauntedQuest2"
            QuestNumber = 1
            QuestPos = CFrame.new(-9516.99316, 172.017181, 6078.46533, 0, 0, -1, 0, 1, 0, 1, 0, 0)
            EnemyPos = CFrame.new(-9505.8720703125, 172.10482788085938, 6158.9931640625)
            elseif Lvl.Value >= 2050 and Lvl.Value <= 2074 then
            Enemy = "Posessed Mummy"
            QuestName = "HauntedQuest2"
            QuestNumber = 2
            QuestPos = CFrame.new(-9516.99316, 172.017181, 6078.46533, 0, 0, -1, 0, 1, 0, 1, 0, 0)
            EnemyPos = CFrame.new(-9582.0224609375, 6.251527309417725, 6205.478515625)
            elseif Lvl.Value >= 2075 and Lvl.Value <= 2099 then
            Enemy = "Peanut Scout"
            QuestName = "NutsIslandQuest"
            QuestNumber = 1
            QuestPos = CFrame.new(-2104.3908691406, 38.104167938232, -10194.21875, 0, 0, -1, 0, 1, 0, 1, 0, 0)
            EnemyPos = CFrame.new(-2143.241943359375, 47.72198486328125, -10029.9951171875)
            elseif Lvl.Value >= 2100 and Lvl.Value <= 2124 then
            Enemy = "Peanut President"
            QuestName = "NutsIslandQuest"
            QuestNumber = 2
            QuestPos = CFrame.new(-2104.3908691406, 38.104167938232, -10194.21875, 0, 0, -1, 0, 1, 0, 1, 0, 0)
            EnemyPos = CFrame.new(-1859.35400390625, 38.10316848754883, -10422.4296875)
            elseif Lvl.Value >= 2125 and Lvl.Value <= 2149 then
            Enemy = "Ice Cream Chef"
            QuestName = "IceCreamIslandQuest"
            QuestNumber = 1
            QuestPos = CFrame.new(-820.64825439453, 65.819526672363, -10965.795898438, 0, 0, -1, 0, 1, 0, 1, 0, 0)
            EnemyPos = CFrame.new(-872.24658203125, 65.81957244873047, -10919.95703125)
            elseif Lvl.Value >= 2150 and Lvl.Value <= 2199 then
            Enemy = "Ice Cream Commander"
            QuestName = "IceCreamIslandQuest"
            QuestNumber = 2
            QuestPos = CFrame.new(-820.64825439453, 65.819526672363, -10965.795898438, 0, 0, -1, 0, 1, 0, 1, 0, 0)
            EnemyPos = CFrame.new(-558.06103515625, 112.04895782470703, -11290.7744140625)
            elseif Lvl.Value >= 2200 and Lvl.Value <= 2224 then
            Enemy = "Cookie Crafter"
            QuestName = "CakeQuest1"
            QuestNumber = 1
            QuestPos = CFrame.new(-2021.32007, 37.7982254, -12028.7295, 0.957576931, -8.80302053e-08, 0.288177818, 6.9301187e-08, 1, 7.51931211e-08, -0.288177818, -5.2032135e-08, 0.957576931)
            EnemyPos = CFrame.new(-2374.13671875, 37.79826354980469, -12125.30859375)
            elseif Lvl.Value >= 2225 and Lvl.Value <= 2249 then
            Enemy = "Cake Guard"
            QuestName = "CakeQuest1"
            QuestNumber = 2
            QuestPos = CFrame.new(-2021.32007, 37.7982254, -12028.7295, 0.957576931, -8.80302053e-08, 0.288177818, 6.9301187e-08, 1, 7.51931211e-08, -0.288177818, -5.2032135e-08, 0.957576931)
            EnemyPos = CFrame.new(-1598.3070068359375, 43.773197174072266, -12244.5810546875)
            elseif Lvl.Value >= 2250 and Lvl.Value <= 2274 then
            Enemy = "Baking Staff"
            QuestName = "CakeQuest2"
            QuestNumber = 1
            QuestPos = CFrame.new(-1927.91602, 37.7981339, -12842.5391, -0.96804446, 4.22142143e-08, 0.250778586, 4.74911062e-08, 1, 1.49904711e-08, -0.250778586, 2.64211941e-08, -0.96804446)
            EnemyPos = CFrame.new(-1887.8099365234375, 77.6185073852539, -12998.3505859375)
            elseif Lvl.Value >= 2275 and Lvl.Value <= 2299 then
            Enemy = "Head Baker"
            QuestName = "CakeQuest2"
            QuestNumber = 2
            QuestPos = CFrame.new(-1927.91602, 37.7981339, -12842.5391, -0.96804446, 4.22142143e-08, 0.250778586, 4.74911062e-08, 1, 1.49904711e-08, -0.250778586, 2.64211941e-08, -0.96804446)
            EnemyPos = CFrame.new(-2216.188232421875, 82.884521484375, -12869.2939453125)
            elseif Lvl.Value >= 2300 and Lvl.Value <= 2324 then
            Enemy = "Cocoa Warrior"
            QuestName = "ChocQuest1"
            QuestNumber = 2
            QuestPos = CFrame.new(233.22836303710938, 29.876001358032227, -12201.2333984375)
            EnemyPos = CFrame.new(-21.55328369140625, 80.57499694824219, -12352.3876953125)
            elseif Lvl.Value >= 2325 and Lvl.Value <= 2349 then
            Enemy = "Chocolate Bar Battler"
            QuestName = "ChocQuest1"
            QuestNumber = 2
            QuestPos = CFrame.new(233.22836303710938, 29.876001358032227, -12201.2333984375)
            EnemyPos = CFrame.new(582.590576171875, 77.18809509277344, -12463.162109375)
            elseif Lvl.Value >= 2350 and Lvl.Value <= 2374 then
            Enemy = "Sweet Thief"
            QuestName = "ChocQuest2"
            QuestNumber = 1
            QuestPos = CFrame.new(150.5066375732422, 30.693693161010742, -12774.5029296875)
            EnemyPos = CFrame.new(165.1884765625, 76.05885314941406, -12600.8369140625)
            elseif Lvl.Value >= 2375 and Lvl.Value <= 2399 then
            Enemy = "Candy Rebel"
            QuestName = "ChocQuest2"
            QuestNumber = 2
            QuestPos = CFrame.new(150.5066375732422, 30.693693161010742, -12774.5029296875)
            EnemyPos = CFrame.new(134.86563110351562, 77.2476806640625, -12876.5478515625)
            elseif Lvl.Value >= 2400 and Lvl.Value <= 2424 then
            Enemy = "Candy Pirate"
            QuestName = "CandyQuest1"
            QuestNumber = 1
            QuestPos = CFrame.new(-1150.0400390625, 20.378934860229492, -14446.3349609375)
            EnemyPos = CFrame.new(-1310.5003662109375, 26.016523361206055, -14562.404296875)
            elseif Lvl.Value >= 2425 and Lvl.Value <= 2449 then
            Enemy = "Snow DeMonster"
            QuestName = "CandyQuest1"
            QuestNumber = 2
            QuestPos = CFrame.new(-1150.0400390625, 20.378934860229492, -14446.3349609375)
            EnemyPos = CFrame.new(-880.2006225585938, 71.24776458740234, -14538.609375)
            elseif Lvl.Value >= 2450 and Lvl.Value <= 2474 then
            Enemy = "Isle Outlaw"
            QuestName = "TikiQuest1"
            QuestNumber = 1
            QuestPos = CFrame.new(-16547.748046875, 61.13533401489258, -173.41360473632812)
            EnemyPos = CFrame.new(-16442.814453125, 116.13899993896484, -264.4637756347656)
            elseif Lvl.Value >= 2475 and Lvl.Value <= 2499 then
            Enemy = "Island Boy"
            QuestName = "TikiQuest1"
            QuestNumber = 2
            QuestPos = CFrame.new(-16547.748046875, 61.13533401489258, -173.41360473632812)
            EnemyPos = CFrame.new(-16901.26171875, 84.06756591796875, -192.88906860351562)
            elseif Lvl.Value >= 2500 and Lvl.Value <= 2524 then
            Enemy = "Sun-kissed Warrior"
            QuestName = "TikiQuest2"
            QuestNumber = 1
            QuestPos = CFrame.new(-16539.078125, 55.68632888793945, 1051.5738525390625)
            EnemyPos = CFrame.new(-16051.9697265625, 54.797149658203125, 1084.67578125)
            elseif Lvl.Value >= 2525 and Lvl.Value <= 2549 then
            Enemy = "Isle Champion"
            QuestName = "TikiQuest2"
            QuestNumber = 2
            QuestPos = CFrame.new(-16539.078125, 55.68632888793945, 1051.5738525390625)
            EnemyPos = CFrame.new(-16619.37109375, 129.9848175048828, 1071.235595703125)
            elseif Lvl.Value >= 2550 and Lvl.Value <= 2574 then
            Enemy = "Serpent Hunters"
            QuestName = "TikiQuest3"
            QuestNumber = 1
            QuestPos = CFrame.new(-16664.025390625, 105.22010040283203, 1578.4385986328125)
            EnemyPos = CFrame.new(-16589.48828125, 106.99691009521484, 1397.4598388671875)
            elseif Lvl.Value >= 2575 and Lvl.Value <= 555555 then
            Enemy = "Skull Slayer"
            QuestName = "TikiQuest3"
            QuestNumber = 2
            QuestPos = CFrame.new(-16664.025390625, 105.22010040283203, 1578.4385986328125)
            EnemyPos = CFrame.new(-16684.49609375, 71.21708679199219, 1672.046142578125)
        end
    end

    local function ClearQuest()
        if not string.find(LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text, tostring(Enemy)) then
            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("AbandonQuest")
        end
    end

    spawn(function()
        while AutoFarm and wait() do
            pcall(function()
                DataQuest()
                ClearQuest()
                if not LocalPlayer.PlayerGui.Main.Quest.Visible then
    Tween(QuestPos)
    wait(3)
    GetQuest(QuestName, QuestNumber)
    wait(1) -- รอรับเควสให้เสร็จ
    Tween(EnemyPos) -- บินไปจุดมอนทันที
                else
                    local targetEnemy = nil
                    for _, v in pairs(workspace.Enemies:GetChildren()) do
                        if v.Name == tostring(Enemy) and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                            targetEnemy = v
                            break
                        end
                    end
                    if targetEnemy then
    local floatPos = targetEnemy.HumanoidRootPart.CFrame * CFrame.new(0, 20, 0)
    local travelTime = Tween(floatPos)
    task.wait(travelTime + 0.1)

    while targetEnemy and targetEnemy.Parent and targetEnemy:FindFirstChild("Humanoid") and targetEnemy.Humanoid.Health > 0 and AutoFarm do
        task.wait()
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = floatPos
        end
                    end
                end
            end)
        end
    end)
    
end

function StartAutoAttack()
    spawn(function()
        while AutoAttack do
            task.wait(0.01)
            pcall(function()
                local regAtk = game:GetService("ReplicatedStorage").Modules.Net:FindFirstChild("RE/RegisterAttack")
                local regHit = game:GetService("ReplicatedStorage").Modules.Net:FindFirstChild("RE/RegisterHit")

                for _, v in next, workspace.Enemies:GetChildren() do
                    if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
                        regAtk:FireServer(0)

                        local args = {
                            [1] = v:FindFirstChild("RightHand"),
                            [2] = {}
                        }

                        for _, e in next, workspace.Enemies:GetChildren() do
                            if e:FindFirstChild("Humanoid") and e.Humanoid.Health > 0 then
                                table.insert(args[2], {
                                    [1] = e,
                                    [2] = e:FindFirstChild("HumanoidRootPart") or e:FindFirstChildOfClass("BasePart")
                                })
                            end
                        end

                        regHit:FireServer(unpack(args))
                        break
                    end
                end
            end)
        end
    end)
end


function Tween(CFrame)
    Distance = (CFrame.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
    if Distance < 250 then
        Speed = 600
    elseif Distance < 500 then
        Speed = 500
    elseif Distance < 1000 then
        Speed = 400
    elseif Distance >= 1000 then
        Speed = 250
    end
    tween =
        game:GetService("TweenService"):Create(
        game.Players.LocalPlayer.Character.HumanoidRootPart,
        TweenInfo.new(Distance / Speed, Enum.EasingStyle.Linear),
        {CFrame = CFrame}
    ):Play()

    return Distance / Speed
end

local Tab = Window:CreateTab("ออโต้อัพสเตตัส")
local Section = Tab:CreateSection("ออโต้อัพสเตตัส")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

local runMelee = false
local runDefense = false
local runSword = false
local runGun = false
local runFruit = false

Tab:CreateToggle({
    Name = "อัพหมัด",
    CurrentValue = false,
    Flag = "ToggleMelee",
    Callback = function(Value)
        runMelee = Value
    end,
})

Tab:CreateToggle({
    Name = "อัพป้องกัน",
    CurrentValue = false,
    Flag = "ToggleDefense",
    Callback = function(Value)
        runDefense = Value
    end,
})

Tab:CreateToggle({
    Name = "อัพดาบ",
    CurrentValue = false,
    Flag = "ToggleSword",
    Callback = function(Value)
        runSword = Value
    end,
})

Tab:CreateToggle({
    Name = "อัพปืน",
    CurrentValue = false,
    Flag = "ToggleGun",
    Callback = function(Value)
        runGun = Value
    end,
})

Tab:CreateToggle({
    Name = "อัพผล",
    CurrentValue = false,
    Flag = "ToggleFruit",
    Callback = function(Value)
        runFruit = Value
    end,
})

-- วนลูปเพิ่มแต้ม
spawn(function()
    while true do
        if runMelee then
            remote:InvokeServer("AddPoint", "Melee", 1)
        end
        if runDefense then
            remote:InvokeServer("AddPoint", "Defense", 1)
        end
        if runSword then
            remote:InvokeServer("AddPoint", "Sword", 1)
        end
        if runGun then
            remote:InvokeServer("AddPoint", "Gun", 1)
        end
        if runFruit then
            remote:InvokeServer("AddPoint", "Demon Fruit", 1)
        end
        wait(0.1)
    end
end)

local Tab = Window:CreateTab("ฟามกระดูก")
local Section = Tab:CreateSection("ฟามกระดูก")

local NoQuestFarm = false

Tab:CreateToggle({
    Name = "ออโต้ฟาร์มกระดูก",
    CurrentValue = false,
    Flag = "AutoFarm",
    Callback = function(value)
        NoQuestFarm = value
        AutoAttack = value

        if value then
            local args = {
                [1] = "Buso"
            }
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args))

            StartAutoAttack()
            StartNoQuestFarm()
        end
    end
})

local isRunning = false

Tab:CreateToggle({
    Name = "Auto Buy Bones",
    CurrentValue = false,
    Flag = "AutoBones",
    Callback = function(Value)
        isRunning = Value
    end,
})

task.spawn(function()
    while true do
        if isRunning then
            local args = {
                [1] = "Bones",
                [2] = "Buy",
                [3] = 1,
                [4] = 1
            }

            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args))
        end
        task.wait(1)
    end
end)

function Tween(targetCFrame)
    local Character = game.Players.LocalPlayer.Character
    local HRP = Character and Character:FindFirstChild("HumanoidRootPart")
    if not HRP then return 0 end

    local Distance = (targetCFrame.Position - HRP.Position).Magnitude
    local Speed = 250
    if Distance < 250 then Speed = 600
    elseif Distance < 500 then Speed = 500
    elseif Distance < 1000 then Speed = 400 end

    local TweenService = game:GetService("TweenService")
    local tweenInfo = TweenInfo.new(Distance / Speed, Enum.EasingStyle.Linear)
    local goal = {CFrame = targetCFrame}
    local tween = TweenService:Create(HRP, tweenInfo, goal)
    tween:Play()
    return Distance / Speed
end

function StartNoQuestFarm()
    local LocalPlayer = game:GetService("Players").LocalPlayer
    local EnemyFarmPos = CFrame.new(-9444.9228515625, 141.3020782470703, 5680.91357421875)
    local wentToFarmPos = false

    spawn(function()
        while NoQuestFarm and task.wait() do
            pcall(function()
                if not wentToFarmPos then
                    local travelTime = Tween(EnemyFarmPos)
                    task.wait(travelTime + 0.1)
                    wentToFarmPos = true
                end

                local closestDistance = math.huge
                local targetEnemy = nil
                local myPos = LocalPlayer.Character.HumanoidRootPart.Position

                for _, v in pairs(workspace.Enemies:GetChildren()) do
                    if v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                        local dist = (v.HumanoidRootPart.Position - myPos).Magnitude
                        if dist < closestDistance then
                            closestDistance = dist
                            targetEnemy = v
                        end
                    end
                end

                if targetEnemy then
                    local floatPos = targetEnemy.HumanoidRootPart.CFrame * CFrame.new(0, 20, 0)
                    local flyTime = Tween(floatPos)
                    task.wait(flyTime + 0.1)

                    while targetEnemy and targetEnemy.Parent and targetEnemy:FindFirstChild("Humanoid") and targetEnemy.Humanoid.Health > 0 and NoQuestFarm do
                        task.wait()
                        LocalPlayer.Character.HumanoidRootPart.CFrame = floatPos
                    end
                end
            end)
        end
    end)
end

local isReaperFarming = false

Tab:CreateToggle({
    Name = "ออโต้ตีSoul Reaper",
    CurrentValue = false,
    Flag = "AutoReaper",
    Callback = function(Value)
        isReaperFarming = Value
        AutoAttack = Value

        if Value then
            local args = {
                [1] = "Buso"
            }
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args))

            StartAutoAttack()
        end
    end,
})

task.spawn(function()
    local ReaperPos = CFrame.new(-9448.8974609375, 315.8752746582031, 6731.61474609375)
    local LocalPlayer = game.Players.LocalPlayer
    local wentToReaperPos = false

    while true do
        if isReaperFarming then
            pcall(function()
                if not wentToReaperPos then
                    local travelTime = Tween(ReaperPos)
                    task.wait(travelTime + 0.1)
                    wentToReaperPos = true
                end

                local targetEnemy = workspace.Enemies:FindFirstChild("Soul Reaper")
                if targetEnemy and targetEnemy:FindFirstChild("HumanoidRootPart") and targetEnemy:FindFirstChild("Humanoid") and targetEnemy.Humanoid.Health > 0 then
                    local floatPos = targetEnemy.HumanoidRootPart.CFrame * CFrame.new(0, 20, 0)
                    local flyTime = Tween(floatPos)
                    task.wait(flyTime + 0.1)

                    while targetEnemy and targetEnemy.Parent and targetEnemy:FindFirstChild("Humanoid") and targetEnemy.Humanoid.Health > 0 and isReaperFarming do
                        task.wait()
                        LocalPlayer.Character.HumanoidRootPart.CFrame = floatPos
                    end
                end
            end)
        else
            wentToReaperPos = false
        end
        task.wait(1)
    end
end)

local Tab = Window:CreateTab("ซื้อของต่างๆ")
local Section = Tab:CreateSection("ซื้อของต่างๆ")
local Button = Tab:CreateButton({
   Name = "ซื้อBlackLeg",
   Callback = function()
   local args = {
    [1] = "BuyBlackLeg"
}

game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args))
   end,
})

local Button = Tab:CreateButton({
   Name = "ซื้อหมัดElectro",
   Callback = function()
   local args = {
    [1] = "BuyElectro"
}

game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args))

   end,
})

local Button = Tab:CreateButton({
   Name = "ซื้อFishmanKarate",
   Callback = function()
   local args = {
    [1] = "BuyFishmanKarate"
}

game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args))

   end,
})

local Button = Tab:CreateButton({
   Name = "ซื้อหมัดDragonClaw",
   Callback = function()
   local args = {
    [1] = "BlackbeardReward",
    [2] = "DragonClaw",
    [3] = "2"
}

game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args))
   end,
})

local Button = Tab:CreateButton({
   Name = "ซื้อหมัดSuperhuman",
   Callback = function()
   local args = {
    [1] = "BuySuperhuman"
}

game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args))

   end,
})

local Button = Tab:CreateButton({
   Name = "ซื้อDeathStep",
   Callback = function()
   local args = {
    [1] = "BuyDeathStep"
}

game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args))

   end,
})

local Button = Tab:CreateButton({
   Name = "ซื้อหมัดElectricClaw",
   Callback = function()
   local args = {
    [1] = "BuyElectricClaw"
}

game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args))

   end,
})

local Button = Tab:CreateButton({
   Name = "ซื้อหมัดSharkmanKarate",
   Callback = function()
       local args = {
           [1] = "BuySharkmanKarate"
       }

       game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args))
   end,
})

local Button = Tab:CreateButton({
   Name = "ซื้อหมัดDragonTalon",
   Callback = function()
   local args = {
    [1] = "BuyDragonTalon"
}

game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args))

   end,
})

local Button = Tab:CreateButton({
   Name = "ซื้อหมัดGodhuman",
   Callback = function()
       local args = {
           [1] = "BuyGodhuman"
       }

       game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args))
   end,
})

local Tab = Window:CreateTab("ต่างๆ")
local Section = Tab:CreateSection("ต่างๆ")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local enabled = false

local function setLocalShotsLeft(dualFlintlock)
    if enabled and dualFlintlock and dualFlintlock:IsA("Instance") then
        dualFlintlock:SetAttribute("LocalShotsLeft", math.huge)
    end
end

local function onCharacterAdded(character)
    if not enabled then return end

    local dualFlintlock = character:FindFirstChild("Dual Flintlock")
    if dualFlintlock then
        setLocalShotsLeft(dualFlintlock)
    end

    character.ChildAdded:Connect(function(child)
        if enabled and child.Name == "Dual Flintlock" then
            setLocalShotsLeft(child)
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(function(character)
    if enabled then
        onCharacterAdded(character)
    end
end)

if LocalPlayer.Character and enabled then
    onCharacterAdded(LocalPlayer.Character)
end

local Toggle = Tab:CreateToggle({
    Name = "ปืนยิงเร็ว",
    CurrentValue = false,
    Flag = "Toggle1",
    Callback = function(Value)
        enabled = Value
        if enabled and LocalPlayer.Character then
            onCharacterAdded(LocalPlayer.Character)
        end
    end,
})

local FruitsESPEnabled = false
local FruitsESPConnections = {}
 
local function clearFruitsESP()
	for _, v in pairs(FruitsESPConnections) do
		if v.Connection then v.Connection:Disconnect() end
		if v.Billboard and v.Billboard.Parent then
			v.Billboard:Destroy()
		end
	end
	FruitsESPConnections = {}
end
 
local function createFruitESP(fruitModel)
	if not fruitModel:FindFirstChildWhichIsA("BasePart") then return end
	if fruitModel:FindFirstChild("FruitESP") then return end
 
	local part = fruitModel:FindFirstChildWhichIsA("BasePart")
 
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "FruitESP"
	billboard.Size = UDim2.new(0, 80, 0, 20)
	billboard.Adornee = part
	billboard.AlwaysOnTop = true
	billboard.LightInfluence = 0
	billboard.StudsOffset = Vector3.new(0, 2.5, 0)
	billboard.Parent = fruitModel
 
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(255, 170, 0)
	label.TextStrokeTransparency = 0.5
	label.Font = Enum.Font.GothamSemibold
	label.TextScaled = true
	label.Text = fruitModel.Name
	label.Parent = billboard
 
	table.insert(FruitsESPConnections, {Model = fruitModel, Part = part, Label = label, Billboard = billboard})
end
 
local function updateFruitESP()
	-- สร้าง ESP เฉพาะอันที่ยังไม่มี
	local existing = {}
	for _, v in pairs(FruitsESPConnections) do
		existing[v.Model] = true
	end

	for _, obj in pairs(workspace:GetChildren()) do
		if obj:IsA("Model") and obj.Name:lower():find("fruit") and not existing[obj] then
			createFruitESP(obj)
		end
	end
end

local updaterConnection = nil
local distanceUpdater = nil
 
local Toggle = Tab:CreateToggle({
	Name = "ตำแหน่งของผลไม้",
	CurrentValue = false,
	Flag = "FruitESP",
	Callback = function(Value)
		FruitsESPEnabled = Value
		if Value then
			updateFruitESP()

			updaterConnection = game:GetService("RunService").RenderStepped:Connect(function()
				updateFruitESP()
			end)

			distanceUpdater = game:GetService("RunService").RenderStepped:Connect(function()
				local plr = game.Players.LocalPlayer
				if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
					for _, v in pairs(FruitsESPConnections) do
						local dist = (plr.Character.HumanoidRootPart.Position - v.Part.Position).Magnitude
						v.Label.Text = string.format("%s\n[%.0f Studs]", v.Model.Name, dist)
					end
				end
			end)
		else
			if updaterConnection then updaterConnection:Disconnect() updaterConnection = nil end
			if distanceUpdater then distanceUpdater:Disconnect() distanceUpdater = nil end
			clearFruitsESP()
		end
	end,
})
local ESPEnabled = false
local ESPParts = {}

local function createMiniESP(part, islandName)
    if part:FindFirstChild("IslandESP") then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "IslandESP"
    billboard.Size = UDim2.new(0, 100, 0, 30)
    billboard.Adornee = part
    billboard.AlwaysOnTop = true
    billboard.LightInfluence = 0
    billboard.StudsOffset = Vector3.new(0, 5, 0)
    billboard.Parent = part

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(0, 255, 0)
    label.TextStrokeTransparency = 0.7
    label.Font = Enum.Font.Code
    label.TextScaled = true
    label.Text = islandName
    label.Parent = billboard

    local rsConn = game:GetService("RunService").RenderStepped:Connect(function()
        local plr = game.Players.LocalPlayer
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (plr.Character.HumanoidRootPart.Position - part.Position).Magnitude
            label.Text = string.format("%s [%.0f]", islandName, dist)
        end
    end)

    table.insert(ESPParts, {Part = part, Connection = rsConn})
end

local function enableESP()
    local mapFolder = workspace:FindFirstChild("Map")
    if not mapFolder then return end

    for _, island in pairs(mapFolder:GetChildren()) do
        if island:IsA("Model") and island:FindFirstChildWhichIsA("BasePart") then
            local basePart = island:FindFirstChildWhichIsA("BasePart")

            local dummy = Instance.new("Part", workspace)
            dummy.Anchored = true
            dummy.CanCollide = false
            dummy.Transparency = 1
            dummy.Size = Vector3.new(1, 1, 1)
            dummy.Position = basePart.Position

            createMiniESP(dummy, island.Name)
        end
    end
end

local function disableESP()
    for _, v in pairs(ESPParts) do
        if v.Connection then v.Connection:Disconnect() end
        if v.Part and v.Part:FindFirstChild("IslandESP") then
            v.Part:Destroy()
        end
    end
    ESPParts = {}
end

local Toggle = Tab:CreateToggle({
   Name = "ตำแหน่งของเกาะ",
   CurrentValue = false,
   Flag = "IslandESP",
   Callback = function(Value)
       ESPEnabled = Value
       if Value then
           enableESP()
       else
           disableESP()
       end
   end,
})

local Button = Tab:CreateButton({
   Name = "สุ่มผลไม้ปีศาจ",
   Callback = function()
   local args = {
    [1] = "Cousin",
    [2] = "Buy"
}

game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args))
   end,
})

local Toggle = Tab:CreateToggle({
    Name = "Auto Chest Farm",
    CurrentValue = false,
    Flag = "AutoChestFarm",
    Callback = function(Value)
        _G.AutoChestFarm = Value
        if _G.AutoChestFarm then
            task.spawn(function()

                function Tween(CF)
                    local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if not hrp or not CF then return 0 end
                    local Distance = (CF.Position - hrp.Position).Magnitude
                    local Speed = 250
                    if Distance < 250 then Speed = 600
                    elseif Distance < 500 then Speed = 500
                    elseif Distance < 1000 then Speed = 400 end

                    local success, err = pcall(function()
                        game:GetService("TweenService"):Create(
                            hrp,
                            TweenInfo.new(Distance / Speed, Enum.EasingStyle.Linear),
                            {CFrame = CF}
                        ):Play()
                    end)

                    return Distance / Speed
                end

                local function GetNearestChest()
                    local closest, shortest = nil, math.huge
                    for _, chest in ipairs(workspace:WaitForChild("ChestModels"):GetChildren()) do
                        local part = chest:IsA("Model") and chest:FindFirstChildWhichIsA("BasePart") or chest
                        if part and part:IsA("BasePart") and part:IsDescendantOf(workspace) then
                            local dist = (part.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                            if dist < shortest then
                                closest = part
                                shortest = dist
                            end
                        end
                    end
                    return closest
                end

                while _G.AutoChestFarm do
                    local chest = GetNearestChest()
                    if chest then
                        local time = Tween(chest.CFrame + Vector3.new(0, 5, 0))
                        task.wait(time + 0.5)
                    else
                        -- ถ้าไม่มี chest ใกล้ ๆ ลองบินไปเกาะอื่น
                        local map = workspace:FindFirstChild("Map")
                        if map then
                            for _, island in ipairs(map:GetChildren()) do
                                if not _G.AutoChestFarm then break end
                                if island:IsA("BasePart") then
                                    local time = Tween(island.CFrame + Vector3.new(0, 150, 0))
                                    task.wait(time + 1.5)
                                end
                            end
                        end
                    end
                    task.wait(0)
                end
            end)
        end
    end,
})

local Button = Tab:CreateButton({
   Name = "รีจอย",
   Callback = function()
game:GetService("TeleportService"):Teleport(game.PlaceId, game:GetService("Players").LocalPlayer)

   end,
})