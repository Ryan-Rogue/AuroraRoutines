--local Tinkr, Aurora, project = ...

local Aurora = Aurora

Aurora.Rotation.BurstToggle = Aurora:AddGlobalToggle({
    label = "Defensives",              -- Display name (max 11 characters)
    var = "ryan_defensives_toggle",       -- Unique identifier for saving state
    icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_1", -- Icon texture or spell ID
    tooltip = "Toggle Defensives mode", -- Tooltip text
    onClick = function(value)    -- Optional callback when clicked
        print("Defensive mode:", value)
    end
})

Aurora.Rotation.Raid2 = Aurora:AddGlobalToggle({
    label = "Defensives",              -- Display name (max 11 characters)
    var = "ryan_defensives_toggle2",       -- Unique identifier for saving state
    icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_2", -- Icon texture or spell ID
    tooltip = "Toggle Defensives mode", -- Tooltip text
    onClick = function(value)    -- Optional callback when clicked
        print("Defensive mode:", value)
    end
})


local gui = Aurora.GuiBuilder:New()

gui:Category("My Category")
gui:Tab("General")
gui:Header({ text = "Settings" })



gui:Dropdown({
    text = "Battle Potions",
    key = "battlePotions",
    options = {
        { text = "Never", value = 0 },
        { text = "M+", value = 1 },
        { text = "Raid", value = 2 },
        { text = "M+ and Raid", value = 3 },
        { text = "Always", value = 4 },
    },
    default = 3,
    multi = false,           -- Set to true for multi-select
    --width = 200,            -- Optional
    tooltip = "Where to use Potions\nAlso used with Sated debuff of 5 minutes",
    onChange = function(self, value)
        print("Battle Potion changed:", value)
    end
})







local Draw = Aurora.Draw

Draw:RegisterCallback("unitMarkers", function(canvas, unit)
    if unit.enemy and unit.alive then
        -- Draw red circle for enemies
        local r, g, b, a = Draw:GetColor("Red", 70)
        canvas:SetColor(r, g, b, a)
        canvas:Circle(unit.position.x, unit.position.y, unit.position.z, 1)
    end
end, "units")


Draw:RegisterCallback("playerMelee", function(canvas, unit)
    if unit.unit == player.unit and unit.alive then
        -- Draw red circle for enemies
        local r, g, b, a = Draw:GetColor("Green", 70)
        canvas:SetColor(r, g, b, a)
        canvas:Arc(unit.position.x, unit.position.y, unit.position.z, 5, 170, ObjectRotation('player'))
    end
end, "units")




--Draw:(x, y, z, size, arc, rotation)



