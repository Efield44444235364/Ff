local url

if game.PlaceId == 3851622790 or game.PlaceId == 4620170611 then
    url = "https://raw.githubusercontent.com/Efield44444235364/Ff/refs/heads/main/Breakin1%20Command.lua"
elseif game.PlaceId == 13864661000 or game.PlaceId == 13864667823 then
    url = "https://raw.githubusercontent.com/Efield44444235364/Ff/refs/heads/main/Command%20Breakin%202.lua"
end

if url then
    loadstring(game:HttpGet(url))()
else
    warn("PlaceId ไม่ตรงกับที่กำหนด")
end
