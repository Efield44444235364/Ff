--game lode 
if game:IsLoaded() then
    print("game is load")
else
    game.Loaded:Wait()
    print("game not load pls wait")
end

local GameP = tostring(game.PlaceId or "Unknown Place")
local executor = identifyexecutor and identifyexecutor() or "Unknown Executor"

--function
local Player = game:GetService("Players")
local LocalPlayer = Player.LocalPlayer
local Char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Char:WaitForChild("Humanoid")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")

local GameP = game.PlaceId

equipitem = function(v)
if LocalPlayer.Backpack:FindFirstChild(v) then
    local a = LocalPlayer.Backpack:FindFirstChild(v)
        Humanoid:EquipTool(a)
    end
end

spawn(function()
    while wait() do
        if _G.AutoCast then
        Game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-13578.1396, -11050.1885, 126.044495, -0.0206653159, 7.22035054e-08, 0.999786437, -8.62908234e-09, 1, -7.23972846e-08, -0.999786437, -1.01233528e-08, -0.0206653159)
            pcall(function()
                for i,v in pairs(LocalPlayer.Backpack:GetChildren()) do
                    if v:IsA ("Tool") and v.Name:lower():find("rod") then
                    equipitem(v.Name)
                    end
                end
            end)
        end
    end
end)


local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Kawnew Kaiton",
    SubTitle = "Map : Fisch [" .. GameP .. "] | " .. executor,
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Light",
    MinimizeKey = Enum.KeyCode.LeftControl
})


--Fluent provides Lucide Icons https://lucide.dev/icons/ for the tabs, icons are optional
local Tabs = {
    Main = Window:AddTab({ Title = "Auto Farm", Icon = "fish" }),
    a = Window:AddTab({ Title = "Server", Icon = "" }),
    Settings = Window:AddTab({ Title = "Misc/Config", Icon = "settings" })
}

local Options = Fluent.Options

do
    Fluent:Notify({
        Title = "notification",
        Content = "Welcom",
        SubContent = "Drive Word Auto Farm", -- Optional
        Duration = 5 -- Set to nil to make the notification not disappear
    })



    Tabs.Main:AddParagraph({
        Title = "เปิดแล้วรอมันจะเสร็จให้เองง",
        Content = ""
    })



    Tabs.a:AddButton({
        Title = "Rejoin",
        Description = "Rejoin Server!!",
        Callback = function()
            Window:Dialog({
                Title = "Notification",
                Content = "Rejoin??",
                Buttons = {
                    {
                        Title = "Yes",
                        Callback = function()
                            game:GetService("TeleportService"):Teleport(game.PlaceId, game:GetService("Players").LocalPlayer)
                        end
                    },
                    {
                        Title = "No",
                        Callback = function()
                            print("Cancelled the dialog.")
                        end
                    }
                }
            })
        end
    })


local section = Tabs.a:AddSection("// FPS BOOST \\")

    Tabs.a:AddButton({
        Title = "FPS BOOST",
        Description = "Boost FPS 10++",
        Callback = function()
            Window:Dialog({
                Title = "Notification",
                Content = "Turn On?",
                Buttons = {
                    {
                        Title = "ON",
                        Callback = function()
   loadstring(game:HttpGet("https://pastebin.pl/view/raw/b93a0d93"))()
                        end
                    },
                    {
                        Title = "Cancel",
                        Callback = function()
                            print("Cancelled the dialog.")
                        end
                    }
                }
            })
        end
    })

local section = Tabs.Main:AddSection("Auto Farm")

    local Toggle = Tabs.Main:AddToggle("MyToggle", {Title = "AutoCast", Default = false })

    Toggle:OnChanged(function(v)
        print("Toggle changed:", Options.MyToggle.Value)
      wait(1)
        _G.AutoCast = v
     pcall(function()
while _G.AutoCast do wait()
    local Rod = Char:FindFirstChildOfClass("Tool")
                task.wait(.1)
                    Rod.events.cast:FireServer(100,1)
        end
    end)
    end)

    Options.MyToggle:SetValue(false)

    local Toggle = Tabs.Main:AddToggle("MyToggle", {Title = "AutoShake", Default = false })

    Toggle:OnChanged(function(v)
        print("Toggle changed:", Options.MyToggle.Value)
        _G.AutoShake = v
pcall(function()
while _G.AutoShake do wait()
              task.wait(0.01)
                local PlayerGUI = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
                local shakeUI = PlayerGUI:FindFirstChild("shakeui")
                if shakeUI and shakeUI.Enabled then
                    local safezone = shakeUI:FindFirstChild("safezone")
                    if safezone then
                        local button = safezone:FindFirstChild("button")
                        if button and button:IsA("ImageButton") and button.Visible then
                                GuiService.SelectedObject = button
                                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                    end
                end
            end
        end
    end)
       end)

Options.MyToggle:SetValue(false)

local Toggle = Tabs.Main:AddToggle("MyToggle", {Title = "AutoReels ", Default = false })

    Toggle:OnChanged(function(v)
        print("Toggle changed:", Options.MyToggle.value)
        _G.AutoReel = v
pcall(function()
    while _G.AutoReel do wait()
            for i,v in pairs(LocalPlayer.PlayerGui:GetChildren()) do
                if v:IsA "ScreenGui" and v.Name == "reel"then
                    if v:FindFirstChild "bar" then
                        wait(.15)
                            ReplicatedStorage.events.reelfinished:FireServer(100,true)
                    end
                end
            end
        end
    end)
end)
Options.MyToggle:SetValue(false)

    local Keybind = Tabs.Settings:AddKeybind("Keybind", {
        Title = "KeyBind",
        Mode = "Toggle", -- Always, Toggle, Hold
        Default = "LeftControl", -- String as the name of the keybind (MB1, MB2 for mouse buttons)

        -- Occurs when the keybind is clicked, Value is `true`/`false`
        Callback = function(Value)
            print("Keybind clicked!", Value)
        end,

        -- Occurs when the keybind itself is changed, `New` is a KeyCode Enum OR a UserInputType Enum
        ChangedCallback = function(New)
            print("Keybind changed!", New)
        end
    })

    -- OnClick is only fired when you press the keybind and the mode is Toggle
    -- Otherwise, you will have to use Keybind:GetState()
    Keybind:OnClick(function()
        print("Keybind clicked:", Keybind:GetState())
    end)

    Keybind:OnChanged(function()
        print("Keybind changed:", Keybind.Value)
    end)

    task.spawn(function()
        while true do
            wait(1)

            -- example for checking if a keybind is being pressed
            local state = Keybind:GetState()
            if state then
                print("Keybind is being held down")
            end

            if Fluent.Unloaded then break end
        end
    end)

    Keybind:SetValue("MB2", "Toggle") -- Sets keybind to MB2, mode to Hold


    local Input = Tabs.Settings:AddInput("Input", {
        Title = "Input",
        Default = "Default",
        Placeholder = "Placeholder",
        Numeric = false, -- Only allows numbers
        Finished = false, -- Only calls callback when you press enter
        Callback = function(Value)
            print("Input changed:", Value)
        end
    })

    Input:OnChanged(function()
        print("Input updated:", Input.Value)
    end)
end


-- Addons:
-- SaveManager (Allows you to have a configuration system)
-- InterfaceManager (Allows you to have a interface managment system)

-- Hand the library over to our managers
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

-- Ignore keys that are used by ThemeManager.
-- (we dont want configs to save themes, do we?)
SaveManager:IgnoreThemeSettings()

-- You can add indexes of elements the save manager should ignore
SaveManager:SetIgnoreIndexes({})

InterfaceManager:SetFolder("Kawnew Premium Script hub")
SaveManager:SetFolder("Kawnew Premium Script hub/Fisch")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)


Window:SelectTab(1)

Fluent:Notify({
    Title = "K_Now",
    Content = "The script has been loaded.",
    Duration = 8
})

-- You can use the SaveManager:LoadAutoloadConfig() to load a config
-- which has been marked to be one that auto loads!
SaveManager:LoadAutoloadConfig()


print("Anti Afk ")
game:GetService("Players").LocalPlayer.Idled:connect(function()
    warn("Anti afk ran")
    game:GetService("VirtualUser"):CaptureController()
    game:GetService("VirtualUser"):ClickButton2(Vector2.new())
    end)
    getfenv().grav = workspace.Gravity
