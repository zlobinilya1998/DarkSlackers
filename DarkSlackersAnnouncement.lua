function DS_Announcement_Onload()
	this:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS");
	this:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF");
	this:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE");
end



function DS_Announcement_OnEvent()
	target = UnitName("Target");
	icon1, name1, active1, castable1 = GetShapeshiftFormInfo(1)
	if (event == "CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS") then DS_ON_CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS();
    elseif (event == "CHAT_MSG_SPELL_AURA_GONE_SELF") then DS_ON_CHAT_MSG_SPELL_AURA_GONE_SELF();
    elseif (event == "CHAT_MSG_SPELL_SELF_DAMAGE") then DS_ON_CHAT_MSG_SPELL_SELF_DAMAGE();
	end
end




function DS_Is_In_Raid()
    inInstance, instanceType = IsInInstance()
    return instanceType == 'raid'
end

function DS_Check_For_Debuff(unit,name,app)
    local i=1;
    local state,apps;
    while true do
        state,apps = UnitDebuff(unit,i);
        if not state then return false end
        if string.find(state,name) and ((app == apps) or (app == nil)) then return apps end
        i=i+1;
    end
end

function DS_Announce_Spell(gainWhat)
    if (gainWhat == nil or GetNumRaidMembers() == 0 or not DS_Is_In_Raid()) then return end
end

function DS_Announce_Spell_Gone(goneWhat)
    if (goneWhat == nil or GetNumRaidMembers() == 0 or not DS_Is_In_Raid()) then return end
end

function DS_ON_CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS()
    local _, _, gainWhat = string.find(arg1, "You gain (.*).");
    DS_Announce_Spell(gainWhat);
end

function DS_ON_CHAT_MSG_SPELL_AURA_GONE_SELF()
    local _, _, goneWhat = string.find(arg1, "(.*) fades from you.");
    DS_Announce_Spell_Gone(goneWhat);
end

function DS_ON_CHAT_MSG_SPELL_SELF_DAMAGE()
    hasCS = DS_Check_For_Debuff('target',"Spell_Holy_CrusaderStrike", 5);
    hasFFF = DS_Check_For_Debuff('target',"Spell_Nature_FaerieFire");
    hasSA = DS_Check_For_Debuff('target',"Ability_Warrior_Sunder", 5);
    local actionStatus = "Hit";
    local _, _, spellEffect, creature, dmg = string.find(arg1, "Your (.*) hits (.*) for (.*).");

    if(spellEffect == nil or creature == nil or dmg == nil) then
        _, _, spellEffect, creature, dmg = string.find(arg1, "Your (.*) crits (.*) for (.*).");
        actionStatus = "Crit";
    end

    if(spellEffect == nil or creature == nil or dmg == nil) then
        _, _, spellEffect, creature = string.find(arg1, "Your (.*) was resisted by (.*).");
        dmg = 0;
        actionStatus = "Resist";
    end

    if(spellEffect == nil or creature == nil or dmg == nil) then
        _, _, spellEffect, creature = string.find(arg1, "You perform (.*) on (.*).");
        dmg = 0;
        actionStatus = "Perform";
    end

    if(spellEffect == nil or creature == nil or dmg == nil) then
        _, _, spellEffect, creature = string.find(arg1, "Your (.*) missed (.*).");
        dmg = 0;
        actionStatus = "Miss";
    end

    if(spellEffect == nil or creature == nil or dmg == nil) then
        _, _, spellEffect, creature = string.find(arg1, "Your (.*) was dodged by (.*).");
        dmg = 0;
        actionStatus = "Dodge";
    end

    if(spellEffect == nil or creature == nil or dmg == nil) then
        _, _, spellEffect, creature = string.find(arg1, "Your (.*) is parried by (.*).");
        dmg = 0;
        actionStatus = "Parry";
    end

    if(spellEffect == nil or creature == nil or dmg == nil) then
        actionStatus = "Unknown";
    end

    if(actionStatus == "Resist" and (spellEffect == "Taunt" or spellEffect == "Growl" or spellEffect == "Hand of Reckoning")) then
        SendChatMessage("Resisted Taunt: " .. target, "SAY");
    elseif(actionStatus == "Perform" and (spellEffect == "Taunt" or spellEffect == "Growl" or spellEffect == "Hand of Reckoning")) then
        if UnitClassification("target") == "worldboss" then
            SendChatMessage("Taunted: " .. target, "SAY");
        end
    elseif(actionStatus == "Perform" and spellEffect == "Expose Armor") then
        if UnitClassification("target") == "worldboss" then
            SendChatMessage("Armor Exposed: Warriors Stop Sundering!", "SAY");
        end
    elseif((actionStatus == "Resist" or actionStatus == "Miss" or actionStatus == "Dodge" or actionStatus == "Parry") and spellEffect == "Mocking Blow") then
        SendChatMessage("Resisted Taunt: " .. target, "SAY");
    elseif((actionStatus == "Perform" or actionStatus == "Miss" or actionStatus == "Dodge" or actionStatus == "Parry") and spellEffect == "Mocking Blow") then
        if UnitClassification("target") == "worldboss" then
            SendChatMessage("Taunted: " .. target, "SAY");
        end
    elseif(actionStatus == "Resist" and (spellEffect == "Challenging Roar" or spellEffect == "Challenging Shout")) then
        SendChatMessage("Taunt Resisted!", "SAY");
    elseif(actionStatus == "Resist" and (spellEffect == "Faerie Fire (Feral)" or spellEffect == "Faerie Fire")) then
        if UnitClassification("target") == "worldboss" then
            if not hasFFF then SendChatMessage("Faerie Fire: Resisted", "SAY"); end
        end
    elseif((actionStatus == "Resist" or actionStatus == "Miss" or actionStatus == "Dodge" or actionStatus == "Parry") and spellEffect == "Sunder Armor") then
        if UnitClassification("target") == "worldboss" then
            if not hasSA then SendChatMessage("Sunder Armor: Failed", "SAY"); end
        end
    elseif(actionStatus == "Unknown") then
    end
end
