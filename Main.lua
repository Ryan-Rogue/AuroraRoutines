--local Tinkr, Aurora, YourNamespace = ...
local Aurora = Aurora
Ryan = {}  -- Create your namespace table


local target = Aurora.UnitManager:Get("target")
local player = Aurora.UnitManager:Get("player")
local focus = Aurora.UnitManager:Get("focus")


-- Get your spellbook
--local spells = Aurora.SpellHandler.Spellbooks.deathknight["2"].Ryan.spells
local auras = {
            --General
        ShroudOfConcealment     = 114018,
        HuntersMark             = 257284,

        }
--local talents = Aurora.SpellHandler.Spellbooks.deathknight["2"].Ryan.talents



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



-------------------------------------------------------------------------------
---Boss immune Checks
-------------------------------------------------------------------------------
local bossBuffs = { --this table identifies immunity buffs
--11.0.0 + 11.0.2
440177,
--429569,
--451097,
--432119,
--438706, --removed as it falls off quickly
442611,
--426943,
--442517,
--449815,
448050,
--448843,
450447,
--452918
453859, -- boss of Dawnbreaker casting
442611, --Brew MAster Aldryr
435859, -- Darkness Comes
451003, --/black-blood Zekvir
--448488, --queen
--448505, --queen
--11.1
467117, --overdrive Stix
1213817, --sound clap Rik Reverb
1222948, -- electro-charged shield mk2 electro schoker
--469981, --kill o block barrier, this is target specific logic
1220894, --reinforced plating
465420, --high ground
260189, --/configuration-drill, Motherlode
--11.2
1219457, --/incorporeal
1231726, -- Arcane Barrier (Forgeweaver)
1228284, -- Royal Ward (Nexus King)
1246537, -- Entropic Unity (Dementia)
323741, -- Spirits, Halls of Atonement
347097, -- Hylbrande, Gambit
351086, -- So'leah, Gambit

}

function Ryan.IsImmune(unit)
    return unit.aurafrom(bossBuffs) 
end

-----------------------------------------------------------------------
-- Auto Target Disable List
---------------------------------------------------------------------
local AutoTargetExclusionsList = { --This table is used to identify targets that should not be swapped off for any reason, Auto target disabled if targeted
    --[192955] = true, -- draconic-illusion, AV
    --[190187] = true, -- draconic-image, AV
    --[190381] = true, --rotburst totem, BH
    --[193352] = true, --hextrick-totem
    [214287] = true, -- earth burst totem, Stone Vault
    [220368] = true, --/failed-batch
    [164578] = true, --/stitchfleshs-creation
    [162689] = true, --/surgeon-stitchflesh
    [215407] = true,
    [215826] = true, --bloodworker Arakara
    [214504] = true, --rashanan
    [214443] = true, --crystal shards
    [219045] = true,--/broodtwister-ovinax adds
    [220626] = true,--/broodtwister-ovinax adds
    [219046] = true,--/broodtwister-ovinax adds
    [214506] = true, --/broodtwister-ovinax
    [221863] = true, --/summoned-acolyte
    [218370] = true, --/queen-ansurek
    [129802] = true, --/earthrager, motherlode
    [213751] = true, --/dynamite-mine-cart
    [231176] = true, --/scaffolding
    [231788] = true, --/unstable-crawler-mine
    [233623] = true, --/pyrotechnics
    [210153] = true, --/ol-waxbeard, DFC
    [231939] = true, --/darkfuse-wrenchmonger
    [245173] = true, --/infused-tangle
    --[] = true, --233817/forgeweaver-araz in case i want it later
    [241800] = true, --/manaforged-titan, raid
    [240952] = true, --/evoked-spirit, Eco dome trash totem to kill
    --[180433] = true, --/wandering-pulsar
    [245705] = true, --/voidwarden
    --[] = true, --
    --[] = true, --
    --[] = true, --
    --[] = true, --
    --[] = true, --

}




function Ryan.AutoTargetExclusions(npcID)
    return AutoTargetExclusionsList[npcID]
end


--------------------------------------------------------
---Valid Target Check
--------------------------------------------------------
local IgnoredNameplates = { --This table is used to identify nameplates that should not be swapped to if they are on screen.

    --[216337] = true,--bloodworker Arakara, these are trash in arakara, whatever
    [210810] = true, --Menial Laborer, DFC
    [227747] = true, --Crawler Eggs in Delves
    [229296] = true, --Affix orbs
    [220626] = true, --blood-parasite
    [219045] = true, --colossal spiders
    [215826] = true, --bloodworker Arakara
    [219739] = true, --infested-spawn
    [226103] = true, -- /webbed-victim
    [221986] = true, --blood-horror
    [219746] = true, --/silken-tomb
    [223876] = true, --Impaling Spike ID --court
    [218884] = true, --/shattershell-scarab --court
    [165560] = true, --Gormling Larva
    [224616] = true, --/animated-shadow in dawnbreaker
    [151579] = true, --/shield-generator , MEchagon
    --[31146] = true, -- Target dummy in Org for testing
    [219046] = true,
    [214506] = true, --/broodtwister-ovinax
    [223724] = true, --Backfill Barrel Trinket
    [223674] = true, --/caustic-skitterer Queen little adds in p2 that spawn on bridge
    --[221344] = true, --/gloom-hatchling adds in p3 queen that cause wipe if touch boss
    [221863] = true, --/summoned-acolyte caster adds in middle of room during p3 queen
    [231788] = true, --/unstable-crawler-mine, motherlode
    [235187] = true, --/
    [210148] = true, --/menial-laborer, DFC
    [231935] = true, --/junkyard-hyena
    [237967] = true, --/discharged-giga-bomb
    [158315] = true, --/eye of chaos
    [245173] = true, --/infused-tangle
    [242586] = true, --/arcane-manifestation
    --[] = true, --
    --[] = true, --
    --[] = true, --
    --[] = true, --
    --[] = true, --
    --[] = true, --
    --[] = true, --
    --[] = true, --
    --[] = true, --
    --[] = true, --
    --[] = true, --

}



    -- Priority levels (higher is better)
    local priorities = {
        RAID_MARKER = 5,
        FOCUS = 4,
        PRIO_NPC = 3,
        HUNTERSMARK = 2,
        VALID_TARGET = 1,
        INVALID = 0,
    }

local function RateCandidate(unit, spell)

    local unitPriority = 0
    local npcID = unit.id
    --target overrides, this is to ensure our current target is still valid
    if unit.guid == target.guid then --TODO
        if not unit.exists then return priorities.INVALID end -- We have no target
        if unit.behind(player)  then return priorities.INVALID end -- target is not valid any more
        if not unit.los then return priorities.INVALID end
        if not unit.combat and unit.healthpercent >= 100 then return priorities.INVALID end -- current target is not in combat
        if not spell:inrange(unit) then return priorities.INVALID end
    end

    if Ryan.ValidAutoTarget(unit, spell) or unit.guid == target.guid then
        if Aurora.Config:Read("targeting.raidMarkers") ~= 0 and GetRaidTargetIndex(unit) == Aurora.Config:Read("target.raidMarkers")  then unitPriority = priorities.RAID_MARKER --Check for Raid Marker
        elseif Aurora.Config:Read("targeting.focus") and unit.guid == focus.guid then unitPriority = priorities.FOCUS --Check for Focus Target
        elseif Aurora.Config:Read("targeting.priorityNPCs") and Ryan.AutoTargetingNPCs(unit.id) then unitPriority = priorities.PRIO_NPC -- Check for Highest Priority: Prio NPCs
        elseif Aurora.Config:Read("targeting.huntersMark") and unit.aura(auras.HuntersMark) and unit.healthpercent >= 80 then unitPriority = priorities.HUNTERSMARK --Check for Hunters Mark
        else unitPriority = priorities.VALID_TARGET -- It's a valid generic target
        end
    end
    return unitPriority
end

local function FindBestCandidate(spell)




    local bestCandidate = nil
    local bestCandidatePriority = 0 -- Use a number to rank targets

    local filteredEnemies = Aurora.enemies:filter(function(unit)
    
        --if unit.target.exists and unit.target == player then return false end --TODO verify matches --if UnitIsUnit(target,unitID) then return false end-- unit is already our target --TODO review if needed
        if IgnoredNameplates[unit.id] then return false end
        --if not spell:IsInRange(unitID) then return false end --out of range
        if unit.dead then return false end
        --if Unit(unitID):IsDummy() then return true end --safe to autotarget a dummy (dummys do not report attack or threat) --TODO cant find dummy check in Aurora, this was a table list in Action
        --if Unit(unitID):IsPet() then return false end --TODO find a check for is pet
        if unit.behind(player) then return false end
        if not unit.los then return false end
        if not unit.aggressive then return false end --if not UnitCanAttack(player, unitID) then return false end --can not attack --TODO verify similarities
        if Ryan.IsImmune(unit) then return false end --don't target if immune

        return true
    end)

    filteredEnemies:each(function(unit, i, uptime) 
        local currentPriority = RateCandidate(unit, spell)
        if currentPriority > bestCandidatePriority then
            bestCandidate = unit
            bestCandidatePriority = currentPriority
        end
    end)

    return bestCandidate, bestCandidatePriority
end





function Ryan.AutoTarget(spell)
    --if not GetToggle(2, "RyanAutoTarget") then return false end --if disabled stop
    -- TODO if OOCAutoMouseOverFocus(icon) then return true end -- mouseover set focus checks first (i consider focus as part of auto targeting)
    -- TODO if GetToggle(2, "MOTotem") and Unit(target):IsEnemy() and Unit(target):IsTotem() then return false end
    -- TODO, deconflict with Aurora AutoTargeting if GetToggle(1, "AutoTarget") then Action.SetToggle({1, "AutoTarget"}, false) end
    if not player.combat then return false end

    -- --- Conditions for WHEN to not look for a new target ---
    if Ryan.AutoTargetExclusions(target.id) then return false -- On an exclusion target, never swap off
    elseif target.exists and not target.enemy then return false -- Don't swap off manually targeted friendly units --TODO add friendly NPCs that we target off here. Dromon in Mists etc.
    end

    -- --- Logic for WHAT to target ---
    local bestCandidate, bestPriority = FindBestCandidate(spell) -- get best nameplate and priority
    local currentTargetPriority = RateCandidate(target, spell) --get current targets priority

    if  bestPriority > currentTargetPriority   then -- only auto target if there is a HIGHER priority then current target
        player:settarget(bestCandidate)
    end
end



