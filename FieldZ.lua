local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local commandMap = {
    ["/donut"] = function()
        local A_1 = "PICKUP_ITEM"
        local A_2 = "Donut"
        local Event = game:GetService("ReplicatedStorage").NetworkEvents.RemoteFunction
        Event:InvokeServer(A_1, A_2)
    end,

    ["/bandage"] = function()
        local A_1 = "PICKUP_ITEM"
        local A_2 = "Bandage"
        local Event = game:GetService("ReplicatedStorage").NetworkEvents.RemoteFunction
        Event:InvokeServer(A_1, A_2)
    end,

    ["/medkit"] = function()
        local A_1 = "PICKUP_ITEM"
        local A_2 = "MedKit"
        local Event = game:GetService("ReplicatedStorage").NetworkEvents.RemoteFunction
        Event:InvokeServer(A_1, A_2)
    end,

    ["/opfun"] = function()
        _G.Heal = true
        while _G.Heal do
            wait(0.1)
            local A_1 = "HEAL_PLAYER"
            local A_2 = game:GetService("Players").LocalPlayer
            local A_3 = 999999999
            local Event = game:GetService("ReplicatedStorage").NetworkEvents.RemoteFunction
            Event:InvokeServer(A_1, A_2, A_3)
            wait(0.1)
        end
    end,

    ["/unop"] = function()
        _G.Heal = false
        while _G.Heal do
            wait(0.1)
            local A_1 = "HEAL_PLAYER"
            local A_2 = game:GetService("Players").LocalPlayer
            local A_3 = 999999999
            local Event = game:GetService("ReplicatedStorage").NetworkEvents.RemoteFunction
            Event:InvokeServer(A_1, A_2, A_3)
            wait(0.1)
        end
    end,
}

LocalPlayer.Chatted:Connect(function(msg)
    local command = msg:lower()
    if commandMap[command] then
        commandMap[command]()
    end
end)

print("✅ Loaded Chat Commands!")
