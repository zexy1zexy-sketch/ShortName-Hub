-- ShortName Hub theme foundation.
-- Centralizes accent palette generation for the modular GUI rebuild.

local Theme = {}

Theme.Base = {
    Dark = Color3.fromRGB(12, 12, 17),
    Panel = Color3.fromRGB(23, 23, 31),
    Button = Color3.fromRGB(31, 31, 42),
    Border = Color3.fromRGB(54, 48, 70),
    Text = Color3.fromRGB(240, 240, 248),
    Muted = Color3.fromRGB(155, 155, 175),
}

function Theme.Build(accent)
    accent = accent or Color3.fromRGB(145, 75, 255)
    local light = accent:Lerp(Color3.new(1, 1, 1), 0.28)
    local active = Theme.Base.Button:Lerp(accent, 0.62)

    return {
        Accent = accent,
        Light = light,
        Active = active,
        Dark = Theme.Base.Dark:Lerp(accent, 0.14),
        Panel = Theme.Base.Panel:Lerp(accent, 0.19),
        Button = Theme.Base.Button:Lerp(accent, 0.24),
        Border = Theme.Base.Border:Lerp(accent, 0.45),
        Text = Theme.Base.Text,
        Muted = Theme.Base.Muted,
    }
end

function Theme.ApplyGlow(instance, accent, enabled)
    if not instance then return nil end
    local stroke = instance:FindFirstChild("SNHAccentGlow")
    if not enabled then
        if stroke then stroke:Destroy() end
        return nil
    end
    if not stroke then
        stroke = Instance.new("UIStroke")
        stroke.Name = "SNHAccentGlow"
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        stroke.Thickness = 1.5
        stroke.Transparency = 0.48
        stroke.Parent = instance
    end
    stroke.Color = accent or Theme.Build().Accent
    return stroke
end

return Theme
