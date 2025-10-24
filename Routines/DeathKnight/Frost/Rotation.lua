
local Aurora = Aurora
local BossMods = Aurora.BossMod
-- Get commonly used units
local target = Aurora.UnitManager:Get("target")
local player = Aurora.UnitManager:Get("player")
local focus = Aurora.UnitManager:Get("focus")
-- Get your spellbook
local spells = Aurora.SpellHandler.Spellbooks.deathknight["2"].Ryan.spells
local auras = Aurora.SpellHandler.Spellbooks.deathknight["2"].Ryan.auras
local talents = Aurora.SpellHandler.Spellbooks.deathknight["2"].Ryan.talents


local variable = {}



spells.AutoAttack:callback(function(spell, logic)
    -- Your spell logic here
    
    if spells.AutoAttack:castable(target) and target.enemy and spells.RuneStrike:inrange(target) then
        print("auto attacking")
        return spell:cast(target)
    end
end)







-- Define your combat rotation
local function enemyRotation()
    local isBurst = Aurora.Rotation.Cooldown:GetValue()
    local inMelee = player.distancetoliteral(target) <= 6
    local tierSet = Aurora.hasequipped({237628, 237626, 237631, 237627, 237629})


    local enemiesAround = player.enemiesaround(5)


    --todo global player.enemiesaround(5) sucks and isnt accurate

    --variable.st_planning
    if enemiesAround == 1
            --and ( not raid_event.adds.exists
            --or not raid_event.adds.in
            --or raid_event.adds.in>15)
        then variable.st_planning = true
        else variable.st_planning = false
    end

    variable.adds_remain = enemiesAround >=2
            and (target.ttd > 5 
                -- or GetToggle(2, "TTDSlider") < 5
                )
    --and ( not raid_event.adds.exists
        --        or not raid_event.pull.exists and raid_event.adds.remains>5
        --        or raid_event.pull.exists and raid_event.adds.in>20)

    variable.sending_cds = (variable.st_planning or variable.adds_remain) and isBurst 

    variable.rune_pooling =
            spells.ReapersMark:isknown()
            and spells.ReapersMark:getcd() < 6
            and player.runes <3
            and variable.sending_cds
            and isBurst 


    variable.rp_pooling =
        spells.BreathOfSindragosa:isknown()
        and spells.BreathOfSindragosa:getcd() < 4 * Aurora.gcd()
        and player.runicpower < 60+(35+5 * Aurora.bin(player.aura(auras.IcyOnslaught))) - (10*player.runes)
        and variable.sending_cds
        and isBurst

    variable.frostscythe_prio = 3 + (1 * Aurora.bin( talents.RidersChampion:isknown() and tierSet >= 4 and not ( talents.CleavingStrikes:isknown() and player.aura(auras.RemorselessWinter))))

    variable.breath_of_sindragosa_check=
        spells.BreathOfSindragosa:isknown()
        and ( spells.BreathOfSindragosa:getcd() > 20
                or ( spells.BreathOfSindragosa:getcd() == 0 and player.runicpower >= (60 - 20 * spells.ReapersMark:rank() )))








    local function Cooldowns()
    
        
        --[[
        --local Potions = Ryan.Potions()
        --if Potions and Potions:cast(target) then return true end --use Potions

        if spells.RemorselessWinter:castable(player)
            and inMelee
            and not talents.FrozenDominion:isknown()
            and (variable.sending_cds and ( enemiesAround >1 or talents.GatheringStorm:isknown())
                or ( Player:HasAuraStacksBySpellID(A.GatheringStorm.ID) == 10 and Player:HasAuraBySpellID(A.RemorselessWinter.ID) < GetGCD() ) 
                and Ryan.fight_remains(unitID) >10  -- TODO why is this backwards
            )
        then return spells.RemorselessWinter:cast(target) end
        --]]
        --[[
        if A.FrostwyrmsFury:IsReady(player)
            and inMelee
            and talents.RidersChampion:isknown()
            and A.ApocalypseNow:GetTalentTraits() ~= 0
            and variable.sending_cds
            and ( A.PillarOfFrost:GetCooldown() < GetGCD() and Unit(unitID):TimeToDie() > GetToggle(2, "TTDSlider") or Ryan.fight_remains(unitID) <20) -- added TTD here
            and A.BreathOfSindragosa:GetTalentTraits() == 0
        then return A.FrostwyrmsFury:cast(target) end
        if spells.FrostwyrmsFury:castable(player)  
            and inMelee
            and talents.RidersChampion:isknown()
            and A.ApocalypseNow:GetTalentTraits() ~= 0
            and variable.sending_cds
            and ( A.PillarOfFrost:GetCooldown() < GetGCD() and Unit(unitID):TimeToDie() > GetToggle(2, "TTDSlider") or Ryan.fight_remains(unitID) <20) --added TTD here
            and A.BreathOfSindragosa:GetTalentTraits() ~= 0
            and runic_power>=60
        then return A.FrostwyrmsFury:cast(target) end
        local pillarTTD = A.BreathOfSindragosa:GetTalentTraits() == 0 and (GetToggle(2, "TTDSlider") - 5)
                        or A.BreathOfSindragosa:GetCooldown() < GetToggle(2, "TTDSlider") and GetToggle(2, "TTDSlider")
                        or (GetToggle(2, "TTDSlider") - 5)

        
        --]]



        if  spells.PillarOfFrost:castable(player)           
            --and IsCooldownWorthy(unitID)
            and isBurst
            and (not spells.BreathOfSindragosa:isknown() and variable.sending_cds and ( not spells.ReapersMark:isknown() or rune>=2)
                and target.ttd > 20 --pillarTTD --added ttd here
                --or Ryan.fight_remains(unitID) <20
            ) 
        then return spells.PillarOfFrost:cast(player) end
        if  spells.PillarOfFrost:castable(player)
            --and IsCooldownWorthy(unitID)
            and isBurst
            and target.ttd > 20 --pillarTTD --added ttd here
            and (spells.BreathOfSindragosa:isknown() and variable.sending_cds
            and ( spells.BreathOfSindragosa:getcd() > 20 or ( spells.BreathOfSindragosa:getcd() == 0 and player.runicpower >= (60-(20* spells.ReapersMark:rank()))))
            and ( not spells.ReapersMark:isknown() or player.runes>=2))
        then return spells.PillarOfFrost:cast(player) end
        if  spells.BreathOfSindragosa:castable(player) 
            and inMelee
            and isBurst
            and not player.aura(spells.BreathOfSindragosa.id)
            and ( player.aura(auras.PillarOfFrost) and target.ttd > 20 --added here
                    --or Ryan.fight_remains(unitID) <20
                )
            and spells.BreathOfSindragosa:cast(player)
        then return true end

        --,target_if=first: Unit(unitID):HasDeBuffs(A.ReapersMarkDebuff.ID, true) == 0
        if spells.ReapersMark:castable(target) 
            --and (not GetToggle(2, "targetFocus") or not Unit("focus"):IsExists() or UnitIsUnit("focus" , unitID) or Action.IsUnitFriendly("focus") ) -- only on focus if set
            and (isBurst or player.aura(auras.PillarOfFrost))
            and (player.aura(auras.PillarOfFrost)
                or spells.PillarOfFrost:getcd() > 5
                --or Ryan.fight_remains(unitID) <20
            )
            and spells.ReapersMark:cast(target)
        then return true end




        --[[
        
        
        if A.FrostwyrmsFury:IsReady(player)
            and inMelee
            and IsCooldownWorthy(unitID)
            and ( A.ApocalypseNow:GetTalentTraits() == 0
            and enemiesAround == 1
            and ( A.PillarOfFrost:GetTalentTraits() ~= 0
            and Player:HasAuraBySpellID(A.PillarOfFrost.ID) ~= 0
            and talents.Obliteration:rank() == 0
                    or A.PillarOfFrost:GetTalentTraits() == 0 )
            --and ( not raid_event.adds.exists or raid_event.adds.in>cooldown.frostwyrms_fury.duration+raid_event.adds.duration)
            and variable.fwf_buffs
        or Ryan.fight_remains(unitID) <3)
        then return A.FrostwyrmsFury:cast(target) end

        if A.FrostwyrmsFury:IsReady(player)
            and inMelee
            and IsCooldownWorthy(unitID)
            and A.ApocalypseNow:GetTalentTraits() == 0
            and enemiesAround >=2
            and ( A.PillarOfFrost:GetTalentTraits() ~= 0
            and Player:HasAuraBySpellID(A.PillarOfFrost.ID) ~= 0
            --or raid_event.adds.exists and raid_event.adds.up and raid_event.adds.in< A.PillarOfFrost:GetCooldown() - raid_event.adds.in-raid_event.adds.duration
                )
            and variable.fwf_buffs
        then return A.FrostwyrmsFury:cast(target) end

        if A.FrostwyrmsFury:IsReady(player)
            and inMelee
            and IsCooldownWorthy(unitID)
            and A.ApocalypseNow:GetTalentTraits() == 0
            and talents.Obliteration:rank() ~= 0
            and ( A.PillarOfFrost:GetTalentTraits() ~= 0
            and Player:HasAuraBySpellID(A.PillarOfFrost.ID) ~= 0
            and not  main_hand_2h
        or Player:HasAuraBySpellID(A.PillarOfFrost.ID) == 0
            and main_hand_2h
            and A.PillarOfFrost:GetCooldown() ~=0
            or A.PillarOfFrost:GetTalentTraits() == 0 )
            and variable.fwf_buffs
            --and ( not raid_event.adds.exists or raid_event.adds.in>cooldown.frostwyrms_fury.duration+raid_event.adds.duration)
        then return A.FrostwyrmsFury:cast(target) end

        --]]

        if isBurst and inMelee and spells.RaiseDead:cast(player) then return true end 
        
        if spells.SoulReaper:castable(target)
            and talents.ReaperOfSouls:isknown()
            and player.aura(auras.ReaperOfSouls)
            and player.auracount(auras.KillingMachine) < 2
        then return spells.SoulReaper:cast(target) end

        if  inMelee
            --and not ERWisFlying
            --and IsCooldownWorthy(unitID)
            and target.ttd > 6 --todo check charges
            and (player.runes < 2 or not player.aura(auras.KillingMachine))
            and player.runicpower < 35 + ( talents.IcyOnslaught:rank() * Aurora.bin(player.aura(auras.IcyOnslaught)) * 5)
            and Aurora.gcdremains() <= 0.500 
            and spells.EmpowerRuneWeapon:cast(target)
        then return true end

        if  inMelee
            --and not ERWisFlying
            --and IsCooldownWorthy(unitID)
            and target.ttd > 6 --todo check charges
            and spells.EmpowerRuneWeapon:timetofull() <= 6
            and player.auracount(auras.KillingMachine) < 1 + (1 * talents.KillingStreak:rank() )
            and Aurora.gcdremains() <= 0.500 
            and spells.EmpowerRuneWeapon:cast(target)
        then return true end


    end

    local function SingleTarget()

        if spells.Obliterate:castable(target) 
            and (player.auracount(auras.KillingMachine) == 2 or ( player.aura(auras.KillingMachine) and player.runes>=3)) 
        then return spells.Obliterate:cast(target) end
        
        if  spells.HowlingBlast:castable(target) 
            and inMelee 
            and player.aura(auras.Rime) 
            and talents.FrostboundWill:isknown()
        then return spells.HowlingBlast:cast(target) end
        
        if  spells.FrostStrike:castable(target) 
            and talents.ShatteringBlade:isknown() 
            and not variable.rp_pooling 
            and target.auracount(auras.Razorice, player) == 5 
            --todo target swapping
        then return spells.FrostStrike:cast(target) end      
        
        if  spells.HowlingBlast:castable(target) 
            and inMelee 
            and player.aura(auras.Rime) 
        then return spells.HowlingBlast:cast(target) end

        if  spells.FrostStrike:castable(target) 
            and not talents.ShatteringBlade:isknown()
            and not variable.rp_pooling 
            and player.runesdeficit < 30
        then return spells.FrostStrike:cast(target) end
        
        if  spells.Obliterate:castable(target) 
            and player.aura(auras.KillingMachine)
            and not variable.rune_pooling 
        then return spells.Obliterate:cast(target) end

        if  spells.FrostStrike:castable(target) 
            and not variable.rp_pooling 
        then return spells.FrostStrike:cast(target) end
       
        if  spells.Obliterate:castable(target) 
            and not variable.rune_pooling 
            and not (talents.Obliteration:isknown() and player.aura(auras.PillarOfFrost))
        then return spells.Obliterate:cast(target) end
             
        if  spells.HowlingBlast:castable(target) 
            and inMelee 
            and not player.aura(auras.KillingMachine) 
            and talents.Obliteration:isknown()
            and player.aura(auras.PillarOfFrost) 
        then return spells.HowlingBlast:cast(target) end
        
        --In combat ranged GCD filler
        if   spells.HowlingBlast:castable(target) 
            and player.combat --added to prevent OOC pulling
            and player.runes >= 5
            and target.healthpercent < 100
            and not inMelee -- don't fuck with other logic in melee
        then return spells.HowlingBlast:cast(target) end
    end

    local function AoE()


            if spells.Frostscythe:castable(player)
                and inMelee
                and ( player.auracount(auras.KillingMachine) == 2
                    or ( player.aura(auras.KillingMachine) and player.runes >= 3))
                and enemiesAround >= variable.frostscythe_prio
            then return spells.Frostscythe:cast(player) end

            --,target_if=max:( A.RidersChampion:GetTalentTraits() ~= 0 and Unit(unitID):HasDeBuffsStacks(A.ChainsOfIceTrollbaneSlow.ID, true) ~= 0) -- This isn't real, the debuff applies to them all and breaks all at the same time, also no stacks
            if spells.Obliterate:castable(target)
                and (player.auracount(auras.KillingMachine) == 2
                or ( player.aura(auras.KillingMachine) and player.runes>= 3))
            then return spells.Obliterate:cast(target) end

            if spells.HowlingBlast:castable(target) 
                and inMelee
                and (player.aura(auras.Rime)
                and talents.FrostboundWill:isknown()
                or not target.aura(auras.FrostFever, player))
            then return spells.HowlingBlast:cast(target) end


            if spells.FrostStrike:castable(target) --this is to swap target early
                --APL
                and player.aura(auras.Frostbane)
            then
                --Target Logic
                if target.auracount(auras.Razorice, player) == 5 
                then return spells.FrostStrike:cast(target) end
            end   
            
                --[[
                --Nameplate Logic
                if inAoE
                    and not Ryan.AutoTargetExclusions(npcID) -- Target is something we swap off
                    then
                    --Nameplate Logic
                    for nameplate in pairs(ActiveUnitPlates) do
                        if
                            ValidAutoTarget(nameplate, A.RuneStrike)
                            --APL checks for nameplates
                            and ( Unit(nameplate):HasDeBuffsStacks(A.Razorice.ID, true) == 5
                                )
                        then
                            if Ryan.RecordSwapback(icon) then return true end
                            return A.AutoTarget:cast(target)
                        end
                    end
                end
                --]]



            if spells.FrostStrike:castable(target) --this is to swap target early
                --APL
                and talents.ShatteringBlade:isknown()
                and enemiesAround < 5
                and not variable.rp_pooling
                and talents.Frostbane:rank() == 0
                and target.auracount(auras.Razorice, player) == 5
            then return spells.FrostStrike:cast(target) end
               
            
            
            --[[
                --Nameplate Logic
                if inAoE
                    and not Ryan.AutoTargetExclusions(npcID) -- Target is something we swap off
                    then
                    --Nameplate Logic
                    for nameplate in pairs(ActiveUnitPlates) do
                        if
                            ValidAutoTarget(nameplate, A.RuneStrike)
                            --APL checks for nameplates
                            and ( Unit(nameplate):HasDeBuffsStacks(A.Razorice.ID, true) == 5
                                )
                        then
                            if Ryan.RecordSwapback(icon) then return true end
                            return A.AutoTarget:cast(target)
                        end
                    end
                end
                --]]








            if spells.Frostscythe:castable(player) 
                and inMelee
                and player.aura(auras.KillingMachine)
                and not variable.rune_pooling
                and enemiesAround >=variable.frostscythe_prio
            then return spells.Frostscythe:cast(player) end

            --,target_if=max:( A.RidersChampion:GetTalentTraits() ~= 0 and Unit(unitID):HasDeBuffsStacks(A.ChainsOfIceTrollbaneSlow.ID, true) ~= 0) -- This isn't real, the debuff applies to them all and breaks all at the same time, also no stacks
            if spells.Obliterate:castable(target)
                and player.aura(auras.KillingMachine)
                and not variable.rune_pooling
            then return spells.Obliterate:cast(target) end

            if spells.HowlingBlast:castable(target) 
                and inMelee 
                and player.aura(auras.Rime)
            then return spells.HowlingBlast:cast(target) end

            if spells.GlacialAdvance:castable(player) 
                and inMelee
                and not variable.rp_pooling
            then return spells.GlacialAdvance:cast(player) end

            if spells.Frostscythe:castable(player) 
                and inMelee --Todo check other shit like los and facing?
                -- APL
                and not variable.rune_pooling
                and not ( talents.Obliteration:rank() ~= 0 and player.aura(auras.PillarOfFrost) )
                and enemiesAround >= variable.frostscythe_prio
            then return spells.Frostscythe:cast(player) end

            --,target_if=max:( A.RidersChampion:GetTalentTraits() ~= 0 and Unit(unitID):HasDeBuffsStacks(A.ChainsOfIceTrollbaneSlow.ID, true) ~= 0) -- This isn't real, the debuff applies to them all and breaks all at the same time, also no stacks
            if spells.Obliterate:castable(target)
                and not variable.rune_pooling
                and not ( talents.Obliteration:rank() ~= 0
                and player.aura(auras.PillarOfFrost) )
            then return spells.Obliterate:cast(target) end

            if spells.HowlingBlast:castable(target) 
                and inMelee 
                and not player.aura(auras.KillingMachine)
                and talents.Obliteration:rank() ~= 0 and player.aura(auras.PillarOfFrost)
            then return spells.HowlingBlast:cast(target) end

            --In combat ranged GCD filler
            if spells.HowlingBlast:castable(target) 
                and player.combat --added to prevent OOC pulling
                and player.runes >= 5
                and target.healthpercent < 100
                and not inMelee -- don't fuck with other logic in melee
            then return spells.HowlingBlast:cast(target) end


            return true


    end

    spells.AutoAttack:execute()
    --if Trinkets() then return true end
    if Cooldowns() then return true end
    --if Racial() then return true end
    if player.enemiesaround(5) >= 3 and AoE() then return true end
    if SingleTarget() then return true end



    return false
end

-- Define out of combat actions
local function Ooc()
    -- Add your out of combat logic here

        local function PreCombatRaidTimers()
            if not Ryan.IsInARaid() then return false end --don't use timers outside raid
            if not Ryan.preCombatChecks() then return false end

            local pullTimerTime = BossMods:getpulltimeremaining()
            local GetPullTimer = math.max(pullTimerTime, Ryan.WoWPullTimer()) - GetTime() + A.GetPing() --amount of time until the current pull timer ends from either boss mods or blizzard

            --Pull timer has just expired! Open with Stealth(), PreCombatApproach() will skip due to being in melee range
            if GetPullTimer <= 0.050 and GetPullTimer >= -0.300 then return false end
            --This is the line that stops the rotation for pull timers
            if GetPullTimer <= -0.300 or GetPullTimer > 0 then return true end --Pull timer has not been sent yet or is in progress
        end

        local function MythicPlusDomeActions()
            if not Ryan.IsInADungeon() then return false end --don't use timers outside of m+
            if not Ryan.preCombatChecks() then return false end --checks to make sure we should wait for timers
            if Player:HasAuraBySpellID(A.ShroudOfConcealment.ID, true) ~= 0 then return false end
            local GetPullTimer = Ryan.DungeonTimer() - GetTime() --amount of time until the current pull timer ends from blizzard in m+ dome, 0 is key start
            if GetPullTimer < -10 then return false end --Nothing happens after the first 10 seconds of M+ dungeon here

        end
        local function MythicPlusBossRP()
            if not Ryan.IsInAInstance() then return false end --We will do this in any raid or dungeon, should be good enough
            local warmupTimer = BossMods:GetTimer("Active")
            if warmupTimer == 0 or warmupTimer == -1 then return false end --No timer, quit

        end

        if PreCombatRaidTimers() then return true end --pre-combat Raid actions based on player sent pull timer
        if MythicPlusPreKey() then return true end --pre-combat M0 actions based on player sent pull timer
        if MythicPlusDomeActions() then return true end --pre-combat M+ actions based on Dome Timer
        if MythicPlusBossRP() then return true end --pre-combat M+ actions based on Big/LittleWigs Active Timers





end









-- Register the rotation
Aurora:RegisterRoutine(function()

    -- Skip if player is dead or eating/drinking
    if player.dead or player.aura("Food") or player.aura("Drink") or player.mounted or player.invehicle then return end
    if player.aura(auras.ShroudOfConcealment) then return false end

    --if spells.GlacialAdvance:castable(player)  then  spells.GlacialAdvance:cast(player)  return end
    --if spells.Frostscythe:castable(player)  then  spells.Frostscythe:cast(player)  return end
    --if true then return end

    -- Run appropriate function based on combat state
    if not player.combat then Ooc() end
    --Ryan.AutoTarget(spells.RuneStrike)
    if target.exists then enemyRotation() end
    




end, "DEATHKNIGHT", 2, "Ryan")