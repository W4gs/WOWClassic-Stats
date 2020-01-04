-- Do not remove this comment, it is part of this trigger: ClassicGlobal
function()
    if not (WeakAuras.CCSNextGlobalUpdate) then
        WeakAuras.CCSNextGlobalUpdate = time() + 1;
        WeakAuras.CCSPreviousGlobalResult = "Waiting for Update!";
        return WeakAuras.CCSPreviousGlobalResult;
    end
    
    if (time() > WeakAuras.CCSNextGlobalUpdate) then
        WeakAuras.CCSNextGlobalUpdate = time() + 1;
    else
        return "";
    end
    
    local playerClass, _, classID = UnitClass("player");
    local _, powerTypeString = UnitPowerType("player");
    
    -- Holds various colors used by the scripts
    tblColors = { }
    tblColors["Red"] = "|cFFFF0000";
    tblColors["Yellow"] = "|cFFFFFF00";
    tblColors["Green"] = "|cFF00FF00";
    tblColors["Blue"] = "|cFF00D1FF";
    tblColors["Purple"] = "|cFFC942FD";
    tblColors["Shadow"] = "|cFFaa00ff";
    
    -- Holds player stats information
    tblPlayerStats = { }
    tblPlayerStats["ID"] = classID;
    tblPlayerStats["Class"] = playerClass;
    tblPlayerStats["Level"] = UnitLevel("player");
    tblPlayerStats["Resource"] = powerTypeString;
    tblPlayerStats["Stamina"] = UnitStat("player", 3);
    tblPlayerStats["Intellect"] = UnitStat("player", 4);
    tblPlayerStats["Spirit"] = UnitStat("player", 5);
    
    if (tblPlayerStats["Resource"] == "MANA") then
        -- Spell Damage
        tblPlayerStats["FireDMG"] = GetSpellBonusDamage(3);
        tblPlayerStats["NatureDMG"] = GetSpellBonusDamage(4);
        tblPlayerStats["FrostDMG"] = GetSpellBonusDamage(5);
        tblPlayerStats["ShadowDMG"] = GetSpellBonusDamage(6);
        tblPlayerStats["ArcaneDMG"] = GetSpellBonusDamage(7);
        
        -- Spell Hit
        tblPlayerStats["FireHit"] = 99 + GetSpellHitModifier();
        tblPlayerStats["NatureHit"] = 99 + GetSpellHitModifier();
        tblPlayerStats["FrostHit"] = 99 + GetSpellHitModifier();
        tblPlayerStats["ShadowHit"] = 99 + GetSpellHitModifier();
        tblPlayerStats["ArcaneHit"] = 99 + GetSpellHitModifier();
        
        -- Spell Crit
        tblPlayerStats["FireCrit"] = GetSpellCritChance(3);
        tblPlayerStats["NatureCrit"] = GetSpellCritChance(4);
        tblPlayerStats["FrostCrit"] = GetSpellCritChance(5);
        tblPlayerStats["ShadowCrit"] = GetSpellCritChance(6);
        tblPlayerStats["ArcaneCrit"] = GetSpellCritChance(7);
        
        -- Spell Crit
        tblPlayerStats["FireHitColor"] = "";
        tblPlayerStats["NatureHitColor"] = "";
        tblPlayerStats["FrostHitColor"] = "";
        tblPlayerStats["ShadowHitColor"] = "";
        tblPlayerStats["ArcaneHitColor"] = "";
    end
    
    tblClassRegen = { }
    tblClassRegen[1] = {0, 0};     -- 1 Warrior
    tblClassRegen[2] = {15, 5};    -- 2 Paladin
    tblClassRegen[3] = {15, 5};    -- 3 Hunter
    tblClassRegen[4] = {0, 0};     -- 4 Rogue
    tblClassRegen[5] = {13,4};     -- 5 Priest
    tblClassRegen[6] = {0, 0};     -- 6 ??
    tblClassRegen[7] = {15, 5};    -- 7 Shaman
    tblClassRegen[8] = {13, 4};    -- 8 Mage
    tblClassRegen[9] = {8, 4};     -- 9 Warlock
    tblClassRegen[10] = {0, 0};    -- 10 ??
    tblClassRegen[11] = {0, 0};    -- 11 Druid
    
    tblSpellHitPvE = {
        0,
        4,
        5,
        16,
        27,
        38,
    }
    
    tblSpellIcons = { };
    tblSpellIcons["Fire"] = "|TInterface\\Icons\\spell_fire_flamebolt:18|t";
    tblSpellIcons["Frost"] = "|TInterface\\Icons\\spell_frost_frostbolt02:18|t";
    tblSpellIcons["Arcane"] = "|TInterface\\Icons\\spell_nature_starfall:18|t";
    tblSpellIcons["Shadow"] = "|TInterface\\Icons\\spell_shadow_shadowbolt:18|t";
    
    -- -----------------------------------------------------------
    -- Below this line is for coding, Don't mess with it
    -- -----------------------------------------------------------
    
    if (UnitLevel("target")) then
        tblPlayerStats["TargetLevel"] = UnitLevel("target");
    else
        tblPlayerStats["TargetLevel"] = 0;
    end
    
    tblPlayerStats["LevelDifference"] = tblPlayerStats["TargetLevel"] - tblPlayerStats["Level"];
    
    if (tblPlayerStats["TargetLevel"] == 0) then
        tblPlayerStats["LevelDifference"] = 0;
    end
    
    -- Handler for bosses (Seen as -1 by the game)
    if (tblPlayerStats["TargetLevel"] == -1) then
        tblPlayerStats["TargetLevel"] = tblPlayerStats["Level"] + 3;
        tblPlayerStats["LevelDifference"] = tblPlayerStats["TargetLevel"] - tblPlayerStats["Level"];
    end
end

-- Do not remove this comment, it is part of this trigger: ClassicLevelStats
function()
    if (not aura_env.config["CCHideLevelStats"]) then
        if (tblPlayerStats and tblColors) then
            local RetVal = "";
            local tblTextOut = { };
            
            if (tblPlayerStats["LevelDifference"] <= 0) then
                tblPlayerStats["LevelDifferenceColor"] = tblColors["Green"]
            elseif (tblPlayerStats["LevelDifference"] == 1) then
                tblPlayerStats["LevelDifferenceColor"] = tblColors["Green"]
            elseif (tblPlayerStats["LevelDifference"] == 2) then
                tblPlayerStats["LevelDifferenceColor"] = tblColors["Yellow"]
            elseif (tblPlayerStats["LevelDifference"] == 3) then
                tblPlayerStats["LevelDifferenceColor"] = tblColors["Yellow"]
            elseif (tblPlayerStats["LevelDifference"] == 4) then
                tblPlayerStats["LevelDifferenceColor"] = tblColors["Red"]
            elseif (tblPlayerStats["LevelDifference"] >= 5) then
                tblPlayerStats["LevelDifferenceColor"] = tblColors["Red"]
            end
            
            RetVal = "C (" ..  tblPlayerStats["Level"] .. ") ";
            RetVal = RetVal .. "T (" .. tblPlayerStats["TargetLevel"] .. ") ";
            RetVal = RetVal .. "D (" .. tblPlayerStats["LevelDifferenceColor"] .. tblPlayerStats["LevelDifference"] .. "|r)";
            
            return RetVal;
        end
    end
end

-- Do not remove this comment, it is part of this trigger: ClassicDurability
function()
    if (not aura_env.config["CCHideDurability"]) then
        if (tblPlayerStats and tblColors) then
            if not (WeakAuras.CCSNextDuraUpdate) then
                WeakAuras.CCSNextDuraUpdate = time() + 15;
                WeakAuras.CCSPreviousDuraResult = "Waiting for Update!";
                return WeakAuras.CCSPreviousDuraResult;
            end
            
            if (time() > WeakAuras.CCSNextDuraUpdate) then
                WeakAuras.CCSNextDuraUpdate = time() + 15;
            else
                return WeakAuras.CCSPreviousDuraResult;
            end
            
            local RetVal = "";
            local MaxDura = 0;
            local CurDura = 0;
            
            for i=1,19 do
                local current, maximum = GetInventoryItemDurability(i);
                
                if ((current) and (maximum)) then
                    MaxDura = MaxDura + maximum;
                    CurDura = CurDura + current;
                end
            end
            
            local MyDura = tonumber(format("%.2f", ((CurDura/MaxDura)*100)));
            local DuraColor = "";
            
            if (MyDura == 100) then
                DuraColor = tblColors["Blue"];
            elseif ((MyDura >= 50) and (MyDura <= 99)) then
                DuraColor = tblColors["Green"];
            elseif ((MyDura < 50) and (MyDura > 20)) then
                DuraColor = tblColors["Yellow"];
            elseif (MyDura <= 20) then
                DuraColor = tblColors["Red"];
            end
            
            RetVal = "Durability: " .. DuraColor .. MyDura .. "|r %";
            
            WeakAuras.CCSPreviousDuraResult = RetVal;
            
            return RetVal;
        end
    end
end

-- Do not remove this comment, it is part of this trigger: ClassicRegen
function()
    if (not aura_env.config["CCHideRegen"]) then
        if (tblClassRegen and tblPlayerStats) then
            local RetVal = "";
            
            tblPlayerStats["Casting"] = 0;
            tblPlayerStats["Modifiers"] = 0;
            tblPlayerStats["NotCasting"] = (tblClassRegen[tblPlayerStats["ID"]][1] + (UnitStat("player", 5) / tblClassRegen[tblPlayerStats["ID"]][2]));
            
            for i=1,40 do
                if (UnitBuff("player",i)) then
                    local buffName = select(1, UnitBuff("player",i))
                    
                    -- Mage: Mage Armor (Flat 30%)
                    if (buffName == "Mage Armor") then
                        tblPlayerStats["Modifiers"] = tblPlayerStats["Modifiers"] + .30;
                    end
                end
            end
            
            -- Go into the individual talents
            if (tblPlayerStats["Class"] == "Mage") then
                -- Arcane Meditation 5/10/15%
                tblPlayerStats["Modifiers"] = tblPlayerStats["Modifiers"] + ((select(5, GetTalentInfo(1, 12)) * 5) / 100);
            end
            
            tblPlayerStats["Casting"] = tblPlayerStats["NotCasting"] * tblPlayerStats["Modifiers"];
            
            if (GetManaRegen() < 1) then
                RetVal = "MPT: " .. tblColors["Red"] .. format("%.0f", tblPlayerStats["NotCasting"]) .. " (NC)|r " .. tblColors["Green"] .. format("%.0f", tblPlayerStats["Casting"]) .. " (C)|r";
            else
                RetVal = "MPT: " .. tblColors["Green"] .. format("%.0f", tblPlayerStats["NotCasting"]) .. " (NC)|r " .. tblColors["Red"] .. format("%.0f", tblPlayerStats["Casting"]) .. " (C)|r";
            end
            
            return RetVal;
        end
    end
end

-- Do not remove this comment, it is part of this trigger: ClassicResistances
function ()
    if (not aura_env.config["CCHideResist"]) then
        if (tblColors and tblPlayerStats) then
            if not (WeakAuras.CCSNextResistUpdate) then
                WeakAuras.CCSNextResistUpdate = time() + 5;
                WeakAuras.CCSPreviousResistResult = "Waiting for Update!";
                return WeakAuras.CCSPreviousResistResult;
            end
            
            if (time() > WeakAuras.CCSNextResistUpdate) then
                WeakAuras.CCSNextResistUpdate = time() + 5;
            else
                return WeakAuras.CCSPreviousResistResult;
            end
            
            local RetVal = "";
            
            tblPlayerStats["FireRES"] = tblColors["Red"] .. select(2, UnitResistance("player", 2)) .. "|r";
            tblPlayerStats["NatureRES"] = tblColors["Green"] .. select(2, UnitResistance("player", 3)) .. "|r";
            tblPlayerStats["FrostRES"] = tblColors["Blue"] .. select(2, UnitResistance("player", 4)) .. "|r";
            tblPlayerStats["ShadowRES"] = tblColors["Shadow"] .. select(2, UnitResistance("player", 5)) .. "|r";
            tblPlayerStats["ArcaneRES"] = tblColors["Purple"] .. select(2, UnitResistance("player", 6)) .. "|r";
            
            RetVal = "Your Resistances:\n " .. tblPlayerStats["FireRES"] .. " " .. tblPlayerStats["NatureRES"] .. " " .. tblPlayerStats["FrostRES"] .. " " .. tblPlayerStats["ShadowRES"] .. " " .. tblPlayerStats["ArcaneRES"];
            
            WeakAuras.CCSPreviousResistResult = RetVal;
            
            return RetVal;
        end
    end
end

-- Do not remove this comment, it is part of this trigger: ClassicDebuffs
function()
    if (not aura_env.config["CCHideDebuffs"]) then
        if (tblColors and tblPlayerStats) then
            local RetVal = "";
            local tblTextOut = { };
            
            local Debuffs=0
            local colorDebuff = tblColors["Green"];
            local dCOS = tblColors["Red"];
            local dCOE = tblColors["Red"];
            local dCOR = tblColors["Red"];
            local dWC = tblColors["Red"];
            local dSV = tblColors["Red"];
            local dFF = tblColors["Red"];
            
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
                    if (D == "Shadow Vulnerability") then
                        dSV = tblColors["Green"];
                    end
                    if (D == "Faerie Fire") then
                        dFF = tblColors["Green"];
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
            
            RetVal = "Debuffs: " .. colorDebuff .. Debuffs .. "|r/40\n";
            RetVal = RetVal .. dCOE .. " CoE|r " .. dCOS .. "CoS|r "  .. dCOR .. "CoR|r " .. dWC .. "WC|r " .. dSV .. "SV|r " .. dFF .. "FF|r";
            
            return RetVal;
        end
    end
end

-- Do not remove this comment, it is part of this trigger: ClassicMageStats
function ()
    if not (WeakAuras.CCSNextUpdate) then
        WeakAuras.CCSNextUpdate = time() + 2;
        WeakAuras.CCSPreviousResult = "Waiting for Update!";
        return WeakAuras.CCSPreviousResult;
    end
    
    if (time() > WeakAuras.CCSNextUpdate) then
        WeakAuras.CCSNextUpdate = time() + 2;
    else
        return WeakAuras.CCSPreviousResult;
    end
    
    local HitRequired = 0;
    local RetVal = "";
    local tblTextOut = { };
    
    if (tblPlayerStats["LevelDifference"] <= 0) then
        HitRequired = tblSpellHitPvE[1]
    elseif (tblPlayerStats["LevelDifference"] >= 1 and tblPlayerStats["LevelDifference"] <= 4) then
        HitRequired = tblSpellHitPvE[tblPlayerStats["LevelDifference"] + 1]
    elseif (tblPlayerStats["LevelDifference"] >= 5) then
        HitRequired = tblSpellHitPvE[6]
    end
    
    tblTextOut[1] =  tblColors["Blue"] .. tblPlayerStats["Class"] .. "|r Stats:";
    
    -------------------------------------------------------
    -- Spell Damage Calculations
    tblTextOut[2] = "+Spell Damage:\n\n " .. tblSpellIcons["Arcane"] .. " " .. tblPlayerStats["ArcaneDMG"] .. tblSpellIcons["Fire"] .. " " .. tblPlayerStats["FireDMG"]  .. tblSpellIcons["Frost"] .. " " .. tblPlayerStats["FrostDMG"];
    
    -------------------------------------------------------
    -- Crit Calculations
    
    tblTextOut[3] = "Crit Chances:\n\n " .. tblSpellIcons["Arcane"] .. " " .. format("%.2f", tblPlayerStats["ArcaneCrit"]) .. "% " .. tblSpellIcons["Fire"] .. " " .. format("%.2f", tblPlayerStats["FireCrit"]) .. "% " .. tblSpellIcons["Frost"] .. " " .. format("%.2f", tblPlayerStats["FrostCrit"]) .. "|r% ";    
    -------------------------------------------------------
    -- Hit Calculations 
    tblPlayerStats["FireHit"] = tblPlayerStats["FireHit"] - HitRequired;
    tblPlayerStats["FrostHit"] = tblPlayerStats["FrostHit"] - HitRequired;
    tblPlayerStats["ArcaneHit"] = tblPlayerStats["ArcaneHit"] - HitRequired;
    
    -- From Talents
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
    
    tblTextOut[4] = "Hit Chances:\n\n " .. tblSpellIcons["Arcane"] .. " " .. tblPlayerStats["ArcaneHitColor"]  .. tblPlayerStats["ArcaneHit"] .. "|r% ";
    tblTextOut[4] = tblTextOut[4] .. tblSpellIcons["Fire"] .. " " .. tblPlayerStats["FireHitColor"]  .. tblPlayerStats["FireHit"] .. "|r% ";
    tblTextOut[4] = tblTextOut[4] .. tblSpellIcons["Frost"] .. " " .. tblPlayerStats["FrostHitColor"]  .. tblPlayerStats["FrostHit"] .. "|r% ";
    
    for i=1,20 do
        if (tblTextOut[i]) then
            RetVal = RetVal .. tblTextOut[i] .. "\n";
        end
    end
    
    WeakAuras.CCSPreviousResult  = RetVal;
    
    return RetVal;
end

-- Do not remove this comment, it is part of this trigger: ClassicWarlockStats
function ()
    if not (WeakAuras.CCSNextUpdate) then
        WeakAuras.CCSNextUpdate = time() + 2;
        WeakAuras.CCSPreviousResult = "Waiting for Update!";
        return WeakAuras.CCSPreviousResult;
    end
    
    if (time() > WeakAuras.CCSNextUpdate) then
        WeakAuras.CCSNextUpdate = time() + 2;
    else
        return WeakAuras.CCSPreviousResult;
    end
    
    local HitRequired = 0;
    local RetVal = "";
    local tblTextOut = { };
    
    if (tblPlayerStats["LevelDifference"] <= 0) then
        HitRequired = tblSpellHitPvE[1]
    elseif (tblPlayerStats["LevelDifference"] >= 1 and tblPlayerStats["LevelDifference"] <= 4) then
        HitRequired = tblSpellHitPvE[tblPlayerStats["LevelDifference"] + 1]
    elseif (tblPlayerStats["LevelDifference"] >= 5) then
        HitRequired = tblSpellHitPvE[6]
    end
    
    tblTextOut[1] =  tblColors["Purple"] .. tblPlayerStats["Class"] .. "|r Stats:";
    
    -------------------------------------------------------
    -- Spell Damage Calculations
    tblTextOut[2] = "+Spell Damage:\n\n " .. tblSpellIcons["Fire"] .. " " .. tblPlayerStats["FireDMG"]  .. tblSpellIcons["Shadow"] .. " " .. tblPlayerStats["ShadowDMG"];
    
    -------------------------------------------------------
    -- Crit Calculations
    -- Suppression 2/4/6/8/10% Hit
    -- Devastation 1/2/3/4/5% Crit
    if ((select(5, GetTalentInfo(3, 7))) > 0) then
        tblPlayerStats["ShadowCrit"] = tblPlayerStats["ShadowCrit"] + (select(5, GetTalentInfo(3, 7)));
        tblPlayerStats["FireCrit"] = tblPlayerStats["FireCrit"] + (select(5, GetTalentInfo(3, 7)));
    end
    
    tblTextOut[3] = "Crit Chances:\n\n " .. tblSpellIcons["Fire"] .. " " .. format("%.2f", tblPlayerStats["FireCrit"]) .. "% " .. tblSpellIcons["Shadow"] .. " " .. format("%.2f", tblPlayerStats["ShadowCrit"]) .. "|r% ";
    
    -------------------------------------------------------
    -- Hit Calculations 
    tblPlayerStats["FireHit"] = tblPlayerStats["FireHit"] - HitRequired;
    tblPlayerStats["ShadowHit"] = tblPlayerStats["ShadowHit"] - HitRequired;
    
    if ((select(5, GetTalentInfo(1, 1))) > 0) then
        tblPlayerStats["ShadowHit"] = (tblPlayerStats["ShadowHit"] + (select(5, GetTalentInfo(1, 1)) * 2));
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
    
    tblTextOut[4] = "Hit Chances:\n\n ";
    tblTextOut[4] = tblTextOut[4] .. tblSpellIcons["Fire"] .. " " .. tblPlayerStats["FireHitColor"]  .. tblPlayerStats["FireHit"] .. "|r% ";
    tblTextOut[4] = tblTextOut[4] .. tblSpellIcons["Shadow"] .. " " .. tblPlayerStats["ShadowHitColor"]  .. tblPlayerStats["ShadowHit"] .. "|r% ";
    
    for i=1,20 do
        if (tblTextOut[i]) then
            RetVal = RetVal .. tblTextOut[i] .. "\n";
        end
    end
    
    WeakAuras.CCSPreviousResult  = RetVal;
    
    return RetVal;
end



