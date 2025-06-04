local Lighting = game:GetService("Lighting")
local Terrain = workspace:FindFirstChildOfClass("Terrain")
local plr = game.Players.LocalPlayer

-- 1. ปรับ Lighting & Terrain ให้เบาลงเล็กน้อย (เงานุ่มลง แสงไม่จัด)
Lighting.ShadowSoftness = 0.5
Lighting.EnvironmentDiffuseScale = 0.4
Lighting.EnvironmentSpecularScale = 0.3
Lighting.Ambient = Color3.fromRGB(120, 120, 120)

pcall(function()
    Terrain.WaterWaveSize = 0.5
    Terrain.WaterWaveSpeed = 8
    Terrain.WaterReflectance = 0.1
    Terrain.WaterTransparency = 0.9
end)

-- 2. ลดเอฟเฟกต์ทั่วไปแบบนิดหน่อย (Particle, Smoke, Fire, Beam, Decal)
for _, v in ipairs(workspace:GetDescendants()) do
    if v:IsA("ParticleEmitter") then
        v.Rate = v.Rate * 0.5
        v.Lifetime = NumberRange.new(v.Lifetime.Min * 0.8, v.Lifetime.Max * 0.8)
    elseif v:IsA("Smoke") or v:IsA("Fire") then
        v.Opacity = v.Opacity * 0.5
    elseif v:IsA("Beam") then
        v.Transparency = NumberSequence.new(0.5)
    elseif v:IsA("Decal") and v.Transparency < 0.3 then
        v.Transparency = 0.3
    end
end

-- 3. ลดผลกระทบจากสกิลของผู้เล่นอื่น (กลางๆ)
for _, v in ipairs(workspace:GetDescendants()) do
    if (v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam")) and not v:IsDescendantOf(plr.Character or {}) then
        if v:IsA("ParticleEmitter") then
            v.Rate = v.Rate * 0.4
            v.Lifetime = NumberRange.new(v.Lifetime.Min * 0.6, v.Lifetime.Max * 0.6)
        elseif v:IsA("Trail") then
            v.Lifetime = v.Lifetime * 0.5
        elseif v:IsA("Beam") then
            v.Transparency = NumberSequence.new(0.7)
        end
    elseif v:IsA("Sound") and not v:IsDescendantOf(plr.Character or {}) then
        v.Volume = v.Volume * 0.3
    elseif v:IsA("Explosion") then
        v.BlastPressure = 0
        v.BlastRadius = v.BlastRadius * 0.5
    end
end


warn("boost fps load!")
