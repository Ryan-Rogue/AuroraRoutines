--local Tinkr, Aurora, YourNamespace = ...

Ryan = {}  -- Create your namespace table









--Battle Potions
local TemperedPotion1 = Aurora.ItemHandler.NewItem(212263)
local TemperedPotion2 = Aurora.ItemHandler.NewItem(212264)
local TemperedPotion3 = Aurora.ItemHandler.NewItem(212265)
local FleetingTemperedPotion1 = Aurora.ItemHandler.NewItem(212969)
local FleetingTemperedPotion2 = Aurora.ItemHandler.NewItem(212970)
local FleetingTemperedPotion3 = Aurora.ItemHandler.NewItem(212971)




-----------------------------------------
--Battle Potion Function
------------------------------------------
local burstHaste = {  -- this list exisits in Action, but is not updated, Lust Buffs
2825,   -- Bloodlust - Shammy
32182,  -- Heroism - Shammy
80353,  -- Time Warp - Mage
160452, -- Netherwinds- hunter pet
264667, -- Primal Rage - hunter pet
90355,  -- Ancient Hysteria - hunter pet
146555, -- Drums of Rage
178207, -- Drums of Fury
230935, -- Drums of the Mountain
309658, -- Drums of Deathly Ferocity
256740, -- Drums of Maelstrom
390386, -- Fury of the Aspects --Dragons
381301, -- Feral Hide Drums
444257, -- Thunderous Drums
466904, --Harriers Cry, New Hunter Lust
}
local burntOut = { -- debuff after lust
95809,  --Insanity
57724,  --Sated
57723,  --Exhaustion
160455, --Fatigued
390435, --Exhaustion (Evoker)
80354,  --Temporal Displacement
264689, --Fatigued
}




function Ryan.Potions()
    local toggle = GetToggle(2, "BattlePot") or 0
    if toggle == 0 then return false end
    local battlePotion = DetermineUsableObject("player", true, nil, nil, nil, A.FleetingTemperedPotion3, A.FleetingTemperedPotion2, A.FleetingTemperedPotion1, A.TemperedPotion3, A.TemperedPotion2, A.TemperedPotion1)
    if ((toggle == 1 or toggle == 3) and Ryan.IsInARaid()) and BossMods:IsEngage("the one%-armed bandit") then return battlePotion end --Raid or both
    local lustBuff = Player:HasAuraBySpellID(burstHaste)
    if lustBuff == 0 and Player:HasAuraBySpellID(burntOut) < 290 then return false end -- Never lusted
    if lustBuff ~= 0 and lustBuff < 16 then return false end --Lust is too short, you missed it
    if Ryan.IsInARaid() and not Action.BossMods:IsEngage() then return end -- in raid but not a boss -- Lusting trash is common for resets
    if not battlePotion then return end


    if ((toggle == 1 or toggle == 3) and Ryan.IsInARaid()) then return battlePotion end --Raid or both
    if ((toggle == 2 or toggle == 3) and Action.InstanceInfo.KeyStone >= GetToggle(2, "KeyLevel")) then return battlePotion end --keystone or both
    if toggle == 4 then return battlePotion end  --on CD
end






