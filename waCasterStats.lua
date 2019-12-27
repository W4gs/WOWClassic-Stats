function()
    if not (WeakAuras.SpellStatsNextUpdate) then
        WeakAuras.SpellStatsNextUpdate = time() + 2;
        WeakAuras.SpellStatsPreviousResult = "Waiting for Update!";
    end
    
    -- Thanks to Forbin for showing me globals for updates per 5 seconds
    if (time() > WeakAuras.SpellStatsNextUpdate) then
        WeakAuras.SpellStatsNextUpdate = time() + 2;
    else
        return WeakAuras.SpellStatsPreviousResult;
    end
    
    local playerClass, _, classID = UnitClass("player");
    local _, powerTypeString = UnitPowerType("player");
    
    local tblSpellCritConversion = {
        1,
        1,
        1,
        1,
        59.2,
        1,
        59.5,
        59.5,
        60.6,
        1,
        60,
    }
    
    local tblSpellHitPvE = {
        0,
        4,
        5,
        16,
        27,
        38,
    }
    
    local tblWeaponSkillTypes = { };
    tblWeaponSkillTypes["Daggers"] = 1;
    tblWeaponSkillTypes["Fist Weapons"] = 1;
    tblWeaponSkillTypes["One-Handed Axes"] = 1;
    tblWeaponSkillTypes["One-Handed Swords"] = 1;
    tblWeaponSkillTypes["One-Handed Maces"] = 1;
    tblWeaponSkillTypes["Polearms"] = 2;
    tblWeaponSkillTypes["Staves"] = 2;
    tblWeaponSkillTypes["Two-Handed Axes"] = 2;
    tblWeaponSkillTypes["Two-Handed Swords"] = 2;
    tblWeaponSkillTypes["Two-Handed Maces"] = 2;
    
    local tblTextOut = { };
    local tblPlayerStats = { };
    tblPlayerStats["ID"] = classID;
    tblPlayerStats["Class"] = playerClass;
    tblPlayerStats["Level"] = UnitLevel("player");
    tblPlayerStats["Resource"] = powerTypeString;
    tblPlayerStats["Stamina"] = UnitStat("player", 3);
    tblPlayerStats["WeaponSkill"] = (tblPlayerStats["Level"] * 5);
    tblPlayerStats["MainHandType"] = select(7, GetItemInfo(GetInventoryItemLink("player", 16)));
    
    if not (tblPlayerStats["Resource"] == "MANA") then
        if (tblWeaponSkillTypes[tblPlayerStats["MainHandType"]] == 2) then
            -- Using a 2-hander!
            tblPlayerStats["DualWielding"] = false;
            tblPlayerStats["MHWeaponSkill"] = (tblPlayerStats["Level"] * 5);
        else
            -- Using a 1-hander!
            tblPlayerStats["DualWielding"] = true;
            tblPlayerStats["MHWeaponSkill"] = (tblPlayerStats["Level"] * 5);
            tblPlayerStats["OHWeaponSkill"] = (tblPlayerStats["Level"] * 5);
            
            -- Rogue Weapon Expertise Calculations
            if (tblPlayerStats["Class"] == "Rogue") then
                if ((select(5, GetTalentInfo(2, 17))) > 0) then
                    -- Check for Sword, Fist or Daggers
                    if (tblPlayerStats["MainHandType"] == "One-Handed Swords") or (tblPlayerStats["MainHandType"] == "Fist Weapons") or (tblPlayerStats["MainHandType"] == "Daggers") then
                        -- Weapon Expertise 5/10 Static
                        tblPlayerStats["MHWeaponSkill"] = tblPlayerStats["MHWeaponSkill"] + (select(5, GetTalentInfo(2, 17)) * 5);
                    end
                end
                
                if ((select(5, GetTalentInfo(2, 13))) > 0) then
                    -- Check for Mace Specilization and a Mace Equipped
                    if (tblPlayerStats["MainHandType"] == "One-Handed Maces") then
                        -- Mace Specilization 1/2/3/4/5 Static
                        tblPlayerStats["MHWeaponSkill"] = tblPlayerStats["MHWeaponSkill"] + (select(5, GetTalentInfo(2, 13)));
                    end
                end
            end
        end
    end
    
    -- RAGE
    if (tblPlayerStats["Resource"] == "RAGE") then
        tblPlayerStats["Strength"] = UnitStat("player", 1);
        tblPlayerStats["MeleeHit"] = 99 + GetHitModifier();
        tblPlayerStats["MeleeCrit"] = GetCritChance();
    end
    
    -- ENERGY
    if (tblPlayerStats["Resource"] == "ENERGY") then
        tblPlayerStats["Agility"] = UnitStat("player", 2);
        tblPlayerStats["MeleeHit"] = 99 + GetHitModifier();
        tblPlayerStats["MeleeCrit"] = GetCritChance();
    end
    
    -- MANA
    if (tblPlayerStats["Resource"] == "MANA") then
        if (tblPlayerStats["Class"] == "Hunter") then
            tblPlayerStats["Agility"] = UnitStat("player", 2);
            tblPlayerStats["MeleeHit"] = GetHitModifier();
        else
            tblPlayerStats["Intellect"] = UnitStat("player", 4);
            tblPlayerStats["Spirit"] = UnitStat("player", 5);
            -- Hit
            tblPlayerStats["FireHit"] = 99 + GetSpellHitModifier();
            tblPlayerStats["NatureHit"] = 99 + GetSpellHitModifier();
            tblPlayerStats["FrostHit"] = 99 + GetSpellHitModifier();
            tblPlayerStats["ShadowHit"] = 99 + GetSpellHitModifier();
            tblPlayerStats["ArcaneHit"] = 99 + GetSpellHitModifier();
            -- HitColors
            tblPlayerStats["FireHitColor"] = "";
            tblPlayerStats["NatureHitColor"] = "";
            tblPlayerStats["FrostHitColor"] = "";
            tblPlayerStats["ShadowHitColor"] = "";
            tblPlayerStats["ArcaneHitColor"] = "";
            -- Crit
            tblPlayerStats["FireCrit"] = GetSpellCritChance(3);
            tblPlayerStats["NatureCrit"] = GetSpellCritChance(4);
            tblPlayerStats["FrostCrit"] = GetSpellCritChance(5);
            tblPlayerStats["ShadowCrit"] = GetSpellCritChance(6);
            tblPlayerStats["ArcaneCrit"] = GetSpellCritChance(7);
        end
    end
    
    local tblClassRegen = { }
    tblClassRegen[1] = {0, 0};        -- 1 Warrior
    tblClassRegen[2] = {15, 5};        -- 2 Paladin
    tblClassRegen[3] = {15, 5};        -- 3 Hunter
    tblClassRegen[4] = {0, 0};        -- 4 Rogue
    tblClassRegen[5] = {13,4};        -- 5 Priest
    tblClassRegen[6] = {0, 0};        -- 6 ??
    tblClassRegen[7] = {15, 5};        -- 7 Shaman
    tblClassRegen[8] = {13, 4};        -- 8 Mage
    tblClassRegen[9] = {8, 4};        -- 9 Warlock
    tblClassRegen[10] = {0, 0};        -- 10 ??
    tblClassRegen[11] = {0, 0};        -- 11 Druid
    
    local tblColors = { }
    tblColors["Red"] = "|cFFFF0000";
    tblColors["Yellow"] = "|cFFFFFF00";
    tblColors["Green"] = "|cFF00FF00";
    tblColors["Blue"] = "|cFF00D1FF";
    tblColors["Purple"] = "|cFFC942FD";
    tblColors["Shadow"] = "|cFFaa00ff";
    
    local tblSpellResist = { } 
    tblSpellResist["Holy"] = tblColors["Yellow"] .. select(2, UnitResistance("player", 1)) .. "|r";
    tblSpellResist["Fire"] = tblColors["Red"] .. select(2, UnitResistance("player", 2)) .. "|r";
    tblSpellResist["Nature"] = tblColors["Green"] .. select(2, UnitResistance("player", 3)) .. "|r";
    tblSpellResist["Frost"] = tblColors["Blue"] .. select(2, UnitResistance("player", 4)) .. "|r";
    tblSpellResist["Shadow"] = tblColors["Shadow"] .. select(2, UnitResistance("player", 5)) .. "|r";
    tblSpellResist["Arcane"] = tblColors["Purple"] .. select(2, UnitResistance("player", 6)) .. "|r";
    
    local tblSpellPlusDmg = { }
    tblSpellPlusDmg["Holy"] = GetSpellBonusDamage(2);
    tblSpellPlusDmg["Fire"] = GetSpellBonusDamage(3);
    tblSpellPlusDmg["Nature"] = GetSpellBonusDamage(4);
    tblSpellPlusDmg["Frost"] = GetSpellBonusDamage(5);
    tblSpellPlusDmg["Shadow"] = GetSpellBonusDamage(6);
    tblSpellPlusDmg["Arcane"] = GetSpellBonusDamage(7);
    
    local TargetLevel = UnitLevel("target");
    local LevelDifference = TargetLevel - tblPlayerStats["Level"];
    local LevelDifferenceColor = "";
    local HitRequired = 0;
    
    if (tblPlayerStats["Resource"] == "MANA") then
        tblPlayerStats["Casting"] = 0;
        tblPlayerStats["Modifiers"] = 0;
        tblPlayerStats["NotCasting"] = (tblClassRegen[classID][1] + (UnitStat("player", 5) / tblClassRegen[classID][2]));
        
        for i=1,40 do
            local buffName = select(1, UnitBuff("player",i))
            
            -- Mage: Mage Armor (Flat 30%)
            if (buffName == "Mage Armor") then
                tblPlayerStats["Modifiers"] = tblPlayerStats["Modifiers"] + .30;
            end
        end
        
        -- Go into the individual talents
        if (tblPlayerStats["Class"] == "Mage") then
            -- Arcane Meditation 5/10/15%
            tblPlayerStats["Modifiers"] = tblPlayerStats["Modifiers"] + ((select(5, GetTalentInfo(1, 12)) * 5) / 100);
        end
        
        tblPlayerStats["Casting"] = tblPlayerStats["NotCasting"] * tblPlayerStats["Modifiers"];
    end
    
    -- Level Code
    if (TargetLevel == 0) then
        LevelDifference = 0
    end
    
    -- Boss mobs are seen as -1, This changes them to be your level+3
    if (TargetLevel < 0) then
        TargetLevel = tblPlayerStats["Level"] + 3;
        LevelDifference = TargetLevel - tblPlayerStats["Level"];
    end
    
    -- ********************************************************************
    --    NEED TO FIGURE OUT A WAY TO GET THE WEAPON SKILL OF THE PLAYER
    -- ********************************************************************
    -- Not Dual-Wielding: 99 - (tblMeleeHitSingle[LevelDifference] + ((TargetLevel * 5) - [PlayerLevel *5]) * 0.1)
    -- Dual-Wielding: 99 - (tblMeleeHitDual[LevelDifference] + ((TargetLevel * 5) - [PlayerLevel *5]) * 0.1)
    -- <= 2 levels
    --(5 + ((TargetLevel * 5) - (tblPlayerStats["MHWeaponSkill"]) * 0.1))
    -- > 2 levels
    --(7 + ((TargetLevel * 5) - (tblPlayerStats["MHWeaponSkill"]) * 0.1))
    
    if (LevelDifference <= 0) then
        LevelDifferenceColor = tblColors["Green"]
        if (tblPlayerStats["MeleeHit"]) then
            if not (tblPlayerStats["DualWielding"]) then
                HitRequired = (5 + ((TargetLevel * 5) - (tblPlayerStats["MHWeaponSkill"]) * 0.1));
            else
                HitRequired = (24 + ((TargetLevel * 5) - (tblPlayerStats["MHWeaponSkill"]) * 0.1));
            end
        else
            HitRequired = tblSpellHitPvE[1]
        end
    elseif (LevelDifference == 1) then
        LevelDifferenceColor = tblColors["Green"]
        if (tblPlayerStats["MeleeHit"]) then
            if not (tblPlayerStats["DualWielding"]) then
                HitRequired = (5 + ((TargetLevel * 5) - (tblPlayerStats["MHWeaponSkill"]) * 0.1));
            else
                HitRequired = (24 + ((TargetLevel * 5) - (tblPlayerStats["MHWeaponSkill"]) * 0.1));
            end
        else
            HitRequired = tblSpellHitPvE[LevelDifference+1]
        end
    elseif (LevelDifference == 2) then
        LevelDifferenceColor = tblColors["Yellow"]
        if (tblPlayerStats["MeleeHit"]) then
            if not (tblPlayerStats["DualWielding"]) then
                HitRequired = (5 + ((TargetLevel * 5) - (tblPlayerStats["MHWeaponSkill"]) * 0.1));
            else
                HitRequired = (24 + ((TargetLevel * 5) - (tblPlayerStats["MHWeaponSkill"]) * 0.1));
            end
        else
            HitRequired = tblSpellHitPvE[LevelDifference+1]
        end
    elseif (LevelDifference == 3) then
        LevelDifferenceColor = tblColors["Yellow"]
        if (tblPlayerStats["MeleeHit"]) then
            if not (tblPlayerStats["DualWielding"]) then
                HitRequired = (7 + ((TargetLevel * 5) - (tblPlayerStats["MHWeaponSkill"]) * 0.1));
            else
                HitRequired = (26 + ((TargetLevel * 5) - (tblPlayerStats["MHWeaponSkill"]) * 0.1));
            end
        else
            HitRequired = tblSpellHitPvE[LevelDifference+1]
        end
    elseif (LevelDifference == 4) then
        LevelDifferenceColor = tblColors["Red"]
        if (tblPlayerStats["MeleeHit"]) then
            if not (tblPlayerStats["DualWielding"]) then
                HitRequired = (7 + ((TargetLevel * 5) - (tblPlayerStats["MHWeaponSkill"]) * 0.1));
            else
                HitRequired = (26 + ((TargetLevel * 5) - (tblPlayerStats["MHWeaponSkill"]) * 0.1));
            end
        else
            HitRequired = tblSpellHitPvE[LevelDifference+1]
        end
    elseif (LevelDifference >= 5) then
        LevelDifferenceColor = tblColors["Red"]
        if (tblPlayerStats["MeleeHit"]) then
            if not (tblPlayerStats["DualWielding"]) then
                HitRequired = (7 + ((TargetLevel * 5) - (tblPlayerStats["MHWeaponSkill"]) * 0.1));
            else
                HitRequired = (26 + ((TargetLevel * 5) - (tblPlayerStats["MHWeaponSkill"]) * 0.1));
            end
        else
            HitRequired = tblSpellHitPvE[6]
        end
    end
    
    -- Debuff Tracking Code
    local Debuffs=0
    local colorDebuff = tblColors["Green"];
    local dCOS = tblColors["Red"];
    local dCOE = tblColors["Red"];
    local dCOR = tblColors["Red"];
    local dWC = tblColors["Red"];
    local dSW = tblColors["Red"];
    
    for i=1,40 do 
        local D = UnitDebuff("target",i); 
        if D then 
            Debuffs = Debuffs + 1
            if (D == "Curse of the Elements") then
                dCOE = tblColors["Green"];
            end
            if (D == "Curse of Shadow") then
                dCOS = tblColors["Green"];
            end
            if (D == "Winter's Chill") then
                dWC = tblColors["Green"];
            end
            if (D == "Curse of Recklessness") then
                dCOR = tblColors["Green"];
            end
            if (D == "Shadow Weaving") then
                dSW = tblColors["Green"];
            end
        end 
    end
    
    if (Debuffs < 25) then
        colorDebuff = tblColors["Green"]
    elseif (Debuffs >= 25 and Debuffs <= 35) then
        colorDebuff = tblColors["Yellow"]
    elseif (Debuffs > 35) then
        colorDebuff = tblColors["Red"]
    end
    
    local RetVal = "";
    
    tblTextOut[1] = "My Level: " .. tblPlayerStats["Level"];
    tblTextOut[2] = "Target Level: " .. TargetLevel;
    tblTextOut[3] = "Difference: " .. LevelDifferenceColor .. LevelDifference .. "|r";
    tblTextOut[5] = "Debuffs: " .. colorDebuff .. Debuffs .. "|r/40";
    
    if (tblPlayerStats["Resource"] == "RAGE") or (tblPlayerStats["Resource"] == "ENERGY") or (tblPlayerStats["Class"] == "Hunter") then
        tblTextOut[6] = dCOR .. " CoR|r ";
    elseif (tblPlayerStats["Resource"] == "MANA") then
        if (GetManaRegen() < 1) then
            tblTextOut[4] = "MPT: " .. tblColors["Red"] .. format("%.0f", tblPlayerStats["NotCasting"]) .. " (NC)|r " .. tblColors["Green"] .. format("%.0f", tblPlayerStats["Casting"]) .. " (C)|r";
        else
            tblTextOut[4] = "MPT: " .. tblColors["Green"] .. format("%.0f", tblPlayerStats["NotCasting"]) .. " (NC)|r " .. tblColors["Red"] .. format("%.0f", tblPlayerStats["Casting"]) .. " (C)|r";
        end
        
        if not (tblPlayerStats["Class"] == "Hunter") then
            tblTextOut[6] = dCOE .. " CoE|r " .. dCOS .. "CoS|r " .. dWC .. "WC|r " .. dSW .. "SW|r ";
        end
    end
    tblTextOut[7] = "Your Resistances:\n " .. tblSpellResist["Fire"] .. " " .. tblSpellResist["Nature"] .. " " .. tblSpellResist["Frost"] .. " " .. tblSpellResist["Shadow"] .. " " .. tblSpellResist["Arcane"];
    
    if (tblPlayerStats["Resource"] == "MANA") then
        if not (tblPlayerStats["Class"] == "Hunter") then
            tblPlayerStats["FireCrit"] = GetSpellCritChance(3);
            tblPlayerStats["NatureCrit"] = GetSpellCritChance(4);
            tblPlayerStats["FrostCrit"] = GetSpellCritChance(5);
            tblPlayerStats["ShadowCrit"] = GetSpellCritChance(6);
            tblPlayerStats["ArcaneCrit"] = GetSpellCritChance(7);
        end
    end
    
    -- Mage: Arcane, Fire, Frost
    if (tblPlayerStats["Class"] == "Mage") then
        tblPlayerStats["FireHit"] = tblPlayerStats["FireHit"] - HitRequired;
        tblPlayerStats["FrostHit"] = tblPlayerStats["FrostHit"] - HitRequired;
        tblPlayerStats["ArcaneHit"] = tblPlayerStats["ArcaneHit"] - HitRequired;
        
        -- Crit Modifiers for Class
        -- Arcane Instability 1/2/3% crit
        if (select(5, GetTalentInfo(1, 15)) > 0) then
            tblPlayerStats["FireCrit"] = tblPlayerStats["FireCrit"] + select(5, GetTalentInfo(1, 15));
            tblPlayerStats["FrostCrit"] = tblPlayerStats["FrostCrit"] + select(5, GetTalentInfo(1, 15)) ;
            tblPlayerStats["ArcaneCrit"] = tblPlayerStats["ArcaneCrit"] + select(5, GetTalentInfo(1, 15)) ;
        end
        
        -- Critical Mass 2/4/6% crit
        if (select(5, GetTalentInfo(2, 13)) > 0) then
            tblPlayerStats["FireCrit"] = tblPlayerStats["FireCrit"] + (select(5, GetTalentInfo(2, 13)) * 2);
        end
        
        -- Hit Modifiers for Class
        -- Elemental Precision 2/4/6% hit
        if ((select(5, GetTalentInfo(3, 3))) > 0) then
            tblPlayerStats["FireHit"] = (tblPlayerStats["FireHit"] + (select(5, GetTalentInfo(3, 3)) * 2));
            tblPlayerStats["FrostHit"] = (tblPlayerStats["FrostHit"] + (select(5, GetTalentInfo(3, 3)) * 2));
        end
        
        -- Arcane Focus 2/4/6/8/10% Hit
        if ((select(5, GetTalentInfo(1, 2))) > 0) then
            tblPlayerStats["ArcaneHit"] = tblPlayerStats["ArcaneHit"] + (select(5, GetTalentInfo(3, 3)) * 2);
        end
        
        if (tblPlayerStats["FrostHit"] >= 99) then 
            tblPlayerStats["FrostHit"] = 99;
            tblPlayerStats["FrostHitColor"] = tblColors["Green"];
        elseif (tblPlayerStats["FrostHit"] < 99 and tblPlayerStats["FrostHit"] > 80) then
            tblPlayerStats["FrostHitColor"] = tblColors["Yellow"];
        elseif (tblPlayerStats["FrostHit"] <= 80) then
            tblPlayerStats["FrostHitColor"] = tblColors["Red"];
        end
        
        if (tblPlayerStats["FireHit"] >= 99) then 
            tblPlayerStats["FireHit"] = 99;
            tblPlayerStats["FireHitColor"] = tblColors["Green"];
        elseif (tblPlayerStats["FireHit"] < 99 and tblPlayerStats["FireHit"] > 80) then
            tblPlayerStats["FireHitColor"] = tblColors["Yellow"];
        elseif (tblPlayerStats["FireHit"] <= 80) then
            tblPlayerStats["FireHitColor"] = tblColors["Red"];
        end
        
        if (tblPlayerStats["ArcaneHit"] >= 99) then
            tblPlayerStats["ArcaneHit"] = 99
            tblPlayerStats["ArcaneHitColor"] = tblColors["Green"]
        elseif (tblPlayerStats["ArcaneHit"] < 99 and tblPlayerStats["ArcaneHit"] > 80) then
            tblPlayerStats["ArcaneHitColor"] = tblColors["Yellow"]
        elseif (tblPlayerStats["ArcaneHit"] <= 80) then
            tblPlayerStats["ArcaneHitColor"] = tblColors["Red"]
        end
        
        tblTextOut[9] = "Crit Chances:\n " .. tblColors["Purple"] .. format("%.2f", tblPlayerStats["ArcaneCrit"]) .. "|r% " .. tblColors["Red"] .. format("%.2f", tblPlayerStats["FireCrit"]) .. "|r% " .. tblColors["Blue"] .. format("%.2f", tblPlayerStats["FrostCrit"]) .. "|r% ";
        tblTextOut[10] = "+Spell Damage:\n " .. tblColors["Purple"] .. tblSpellPlusDmg["Arcane"] .. "|r " .. tblColors["Red"] .. tblSpellPlusDmg["Fire"] .. "|r " .. tblColors["Blue"] .. tblSpellPlusDmg["Frost"] .. "|r";
        tblTextOut[11] = "Hit Chances:\n " .. tblColors["Purple"] .. "Arcane: " .. tblPlayerStats["ArcaneHitColor"]  .. tblPlayerStats["ArcaneHit"] .. "|r% ";
        tblTextOut[12] = tblColors["Red"] .. " Fire: " .. tblPlayerStats["FireHitColor"]  .. tblPlayerStats["FireHit"] .. "|r% ";
        tblTextOut[13] = tblColors["Blue"] .. " Frost: " .. tblPlayerStats["FrostHitColor"]  .. tblPlayerStats["FrostHit"] .. "|r% ";
        
        -- Warlock: Fire, Shadow
    elseif (tblPlayerStats["Class"] == "Warlock") then
        tblPlayerStats["FireHit"] = tblPlayerStats["FireHit"] - HitRequired;
        tblPlayerStats["ShadowHit"] = tblPlayerStats["ShadowHit"] - HitRequired;
        
        -- Suppression 2/4/6/8/10% Hit
        if ((select(5, GetTalentInfo(1, 1))) > 0) then
            tblPlayerStats["ShadowHit"] = (tblPlayerStats["ShadowHit"] + (select(5, GetTalentInfo(1, 1)) * 2));
        end
        
        -- Devastation 1/2/3/4/5% Crit
        if ((select(5, GetTalentInfo(3, 7))) > 0) then
            tblPlayerStats["ShadowCrit"] = tblPlayerStats["ShadowCrit"] + (select(5, GetTalentInfo(3, 7)));
            tblPlayerStats["FireCrit"] = tblPlayerStats["FireCrit"] + (select(5, GetTalentInfo(3, 7)));
        end
        
        if (tblPlayerStats["FireHit"] >= 99) then 
            tblPlayerStats["FireHit"] = 99;
            tblPlayerStats["FireHitColor"] = tblColors["Green"];
        elseif (tblPlayerStats["FireHit"] < 99 and tblPlayerStats["FireHit"] > 80) then
            tblPlayerStats["FireHitColor"] = tblColors["Yellow"];
        elseif (tblPlayerStats["FireHit"] <= 80) then
            tblPlayerStats["FireHitColor"] = tblColors["Red"];
        end
        
        if (tblPlayerStats["ShadowHit"] >= 99) then 
            tblPlayerStats["ShadowHit"] = 99;
            tblPlayerStats["ShadowHitColor"] = tblColors["Green"];
        elseif (tblPlayerStats["ShadowHit"] < 99 and tblPlayerStats["ShadowHit"] > 80) then
            tblPlayerStats["ShadowHitColor"] = tblColors["Yellow"];
        elseif (tblPlayerStats["ShadowHit"] <= 80) then
            tblPlayerStats["ShadowHitColor"] = tblColors["Red"];
        end
        
        tblTextOut[8] = "Crit Chances:\n" .. tblColors["Red"] .. format("%.2f", tblPlayerStats["FireCrit"]) .. "|r% " .. tblColors["Shadow"] .. format("%.2f", tblPlayerStats["ShadowCrit"]) .. "|r% ";
        tblTextOut[9] = "+Spell Damage:\n" .. tblColors["Red"] .. tblSpellPlusDmg["Fire"] .. "|r " .. tblColors["Shadow"] .. tblSpellPlusDmg["Shadow"] .. "|r";
        tblTextOut[10] = "Hit Chances:\n" .. tblColors["Red"] .. "Fire: " .. tblPlayerStats["FireHitColor"]  .. tblPlayerStats["FireHit"] .. "|r% ";
        tblTextOut[11] = tblColors["Shadow"] .. "Shadow: " .. tblPlayerStats["ShadowHitColor"]  .. tblPlayerStats["ShadowHit"] .. "|r% ";
    elseif (tblPlayerStats["Class"] == "Priest") then
        -- Determine What Kind of Priest We Are!
        -- Check for Shadowform if yes show spell damage, if no show healing
        
        -- Check for Shadowform Buff, show damage
        -- else show healing
        
    elseif (tblPlayerStats["Class"] == "Rogue") then
        tblPlayerStats["MeleeHit"] = tblPlayerStats["MeleeHit"] - HitRequired;
        
        -- Precision 1/2/3/4/5% Hit
        if ((select(5, GetTalentInfo(2, 6))) > 0) then
            tblPlayerStats["MeleeHit"] = (tblPlayerStats["MeleeHit"] + select(5, GetTalentInfo(2, 6)));
        end
        
        if (tblPlayerStats["MeleeHit"] >= 99) then 
            tblPlayerStats["MeleeHit"] = 99;
            tblPlayerStats["MeleeHitColor"] = tblColors["Green"];
        elseif (tblPlayerStats["MeleeHit"] < 99 and tblPlayerStats["MeleeHit"] > 80) then
            tblPlayerStats["MeleeHitColor"] = tblColors["Yellow"];
        elseif (tblPlayerStats["MeleeHit"] <= 80) then
            tblPlayerStats["MeleeHitColor"] = tblColors["Red"];
        end
        
        tblTextOut[8] = "Crit Chance: " .. format("%.2f", tblPlayerStats["MeleeCrit"]);
        tblTextOut[9] = "Hit Chance: " .. tblPlayerStats["MeleeHitColor"] .. tblPlayerStats["MeleeHit"] .. "|r% ";
    elseif (tblPlayerStats["Class"] == "Warrior") then
        tblPlayerStats["MeleeHit"] = tblPlayerStats["MeleeHit"] - HitRequired;
        
        if (tblPlayerStats["MeleeHit"] >= 99) then 
            tblPlayerStats["MeleeHit"] = 99;
            tblPlayerStats["MeleeHitColor"] = tblColors["Green"];
        elseif (tblPlayerStats["MeleeHit"] < 99 and tblPlayerStats["MeleeHit"] > 80) then
            tblPlayerStats["MeleeHitColor"] = tblColors["Yellow"];
        elseif (tblPlayerStats["MeleeHit"] <= 80) then
            tblPlayerStats["MeleeHitColor"] = tblColors["Red"];
        end
        
        tblTextOut[8] = "Crit Chance: " .. format("%.2f", tblPlayerStats["MeleeCrit"]) .. "%";
        tblTextOut[9] = "Hit Chance: " .. tblPlayerStats["MeleeHitColor"] .. tblPlayerStats["MeleeHit"] .. "|r% ";
    else
        SpellStats=format("%sUnsupported Class: %s|r", tblColors["Red"], tblPlayerStats["Class"])
    end
    
    for i=1,20 do
        if (tblTextOut[i]) then
            RetVal = RetVal .. tblTextOut[i] .. "\n";
        end
    end
    
    WeakAuras.SpellStatsPreviousResult = RetVal;
    
    return RetVal;
end
