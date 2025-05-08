print("jsj")
-- เช็กว่าเกมโหลดเสร็จหรือยัง
if game:IsLoaded() then
    print("game has been loaded")
else
    game.Loaded:Wait()
    print("game is loading, please wait")
end

-- FPS Unlock
local fps = "120"
local SetFps = loadstring(game:HttpGet("https://raw.githubusercontent.com/Efield44444235364/Ff/refs/heads/main/Fpaload2(none).lua"))()

--fps boost
_G.Settings = {
    Players = {
        ["Ignore Me"] = true, -- Ignore your Character
        ["Ignore Others"] = true -- Ignore other Characters
    },
    Meshes = {
        Destroy = false, -- Destroy Meshes
        LowDetail = false -- Low detail meshes (NOT SURE IT DOES ANYTHING)
    },
    Images = {
        Invisible = false, -- Invisible Images
        LowDetail = false, -- Low detail images (NOT SURE IT DOES ANYTHING)
        Destroy = false, -- Destroy Images
    },
    ["No Particles"] = false, -- Disables all ParticleEmitter, Trail, Smoke, Fire and Sparkles
    ["No Camera Effects"] = true, -- Disables all PostEffect's (Camera/Lighting Effects)
    ["No Explosions"] = true, -- Makes Explosion's invisible
    ["No Clothes"] = true, -- Removes Clothing from the game
    ["Low Water Graphics"] = true, -- Removes Water Quality
    ["No Shadows"] = true, -- Remove Shadows
    ["Low Rendering"] = true, -- Lower Rendering
    ["Low Quality Parts"] = false -- Lower quality parts
}
loadstring(game:HttpGet("https://raw.githubusercontent.com/Dragonkung/Dragonkung/main/FPSBooster.lua"))()


local executor = identifyexecutor and identifyexecutor() or "Unknown Executor"

pcall(function()
    game.StarterGui:SetCore("SendNotification", {
        Title = executor .. " Executer Script",
        Text = "FPS boost enabled",
        Duration = 4
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

-- ฟังก์ชันแจ้งเตือน
local function sendNotification(title, text)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = text,
        Icon = ""
    })
end

-- รายชื่อแมพที่อนุญาตให้รัน
local GameP = game.PlaceId
local allowedPlaceIds = {
    [13379349730] = true,
    [14012874501] = true,
    [15824912319] = true,
    [15220308770] = true,
    [14638336319] = true,
    [13904207646] = true,
    [17688739434] = true,
    [16732694052] = true
}

-- แมพพิเศษ (ถ้ามี)
local specialPlaceId = 14916516914

-- เงื่อนไขรัน
if GameP == specialPlaceId then
    print("special script!!!!!!")
    sendNotification("Lobby", "just play some games....")

elseif allowedPlaceIds[GameP] then
    print("script has been executed")
    sendNotification("Script ID [" .. GameP .. "]", "Loading Script.")
    
    -- โหลดสคริปต์หลัก
    loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/705e7fe7aa288f0fe86900cedb1119b1.lua"))()

else
    print("Not allowed PlaceId [" .. GameP .. "]")
end
