_G.efield_loader = true

local hasFpsCap = (type(setfpscap) == "function")

if not hasFpsCap then
    warn("Your executor does not support some script")
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Efield44444235364/Ff/refs/heads/main/MoreUNC.lua"))()
end

loadstring(game:HttpGet("https://raw.githubusercontent.com/Efield44444235364/Anti-ban/refs/heads/main/When%20admin%20join%20server.lua"))()

-- โหลดสคริปต์เฉพาะแมพ Grow a Garden เท่านั้น
if game.PlaceId == 126884695634066 then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Efield44444235364/Anti-ban/refs/heads/main/Anti-Kick.lua"))()
    task.wait(5)
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Efield44444235364/Anti-ban/refs/heads/main/GaG%20Notification.lua"))()
else
    -- ถ้าไม่ใช่แมพนั้น ให้โหลด Notification.lua
    warn(" [ ❌ ] Map not supported")
end

if FPSOptimize == true then
    print(" [ ✅ ] FPS has been optimization successfully!!")
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Efield44444235364/Ff/refs/heads/main/BoostFPS.lua"))()
end

while true do
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Efield44444235364/Anti-ban/refs/heads/main/KickOnline.lua"))()
end

print(" Loader loading.")
