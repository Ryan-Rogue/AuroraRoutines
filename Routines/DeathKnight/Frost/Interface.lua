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



