local url = (game.PlaceId == 3851622790 and
    "https://raw.githubusercontent.com/Efield44444235364/Ff/refs/heads/main/Breakin1%20Command.lua")
    or (game.PlaceId == 13864661000 and
    "https://raw.githubusercontent.com/Efield44444235364/Ff/refs/heads/main/Command%20Breakin%202.lua")

if url then
    loadstring(game:HttpGet(url))()
else
    warn("PlaceId ไม่ตรงกับที่กำหนด")
end
