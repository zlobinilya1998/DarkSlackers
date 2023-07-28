local OriginalUIErrorsFrame_OnEvent;

local addon_version = "1.0.0"
local me = UnitName('player')
local _,playerClass = UnitClass("player");

local EVENT_CHAT_MSG_SYSTEM = "CHAT_MSG_SYSTEM"
local EVENT_RESURRECT_REQUEST = "RESURRECT_REQUEST"
local EVENT_CHAT_MSG_WHISPER = "CHAT_MSG_WHISPER"
local EVENT_CHAT_RAID_WARNING = "CHAT_MSG_RAID_WARNING"
local EVENT_START_LOOT_ROLL = "START_LOOT_ROLL"
local EVENT_PLAYER_ENTERING_WORLD = "PLAYER_ENTERING_WORLD"
local EVENT_CHAT_MSG_ADDON = "CHAT_MSG_ADDON"
local EVENT_PLAYER_ENTERING_WORLD = "PLAYER_ENTERING_WORLD"
local EVENT_ADDON_LOADED = "ADDON_LOADED"

local classcolors = { DRUID="FF7D0A", HUNTER="ABD473", MAGE="69CCF0", PALADIN="F58CBA", PRIEST="FFFFFF", ROGUE="FFF569", SHAMAN="F58CBA", WARLOCK="9482C9", WARRIOR="C79C6E" }

function DS_OnLoad()
	this:RegisterEvent(EVENT_RESURRECT_REQUEST)
	this:RegisterEvent(EVENT_CHAT_MSG_SYSTEM);
	this:RegisterEvent(EVENT_CHAT_MSG_WHISPER);
	this:RegisterEvent(EVENT_CHAT_RAID_WARNING);
	this:RegisterEvent(EVENT_START_LOOT_ROLL);
	this:RegisterEvent(EVENT_CHAT_MSG_ADDON);
	this:RegisterEvent(EVENT_PLAYER_ENTERING_WORLD);
	this:RegisterEvent(EVENT_ADDON_LOADED);

	SLASH_DS1 = "/ds";
	SlashCmdList["DS"] = DS_Help;

	SLASH_CERLD1 = "/rl";
	SlashCmdList["CERLD"] = ReloadUI;

	SLASH_CERI1 = "/reset";
	SlashCmdList["CERI"] = ResetInstances;

	SLASH_CEAR1 = "/autores";
	SlashCmdList["CEAR"] = DS_AutoRes;

	SLASH_PRIOR1 = "/prior"
	SlashCmdList["PRIOR"] = DS_AutoResPrior;
end


function DS_FindSpell (spellName, caseinsensitive)
	spellName = string.lower(spellName);
	local maxSpells = 500;
	local id = 0;
	local searchName;
	local subName;
	while (id <= maxSpells) do
		id = id + 1;
		searchName, subName = GetSpellName(id,BOOKTYPE_SPELL); 
		if (searchName) then
			if (string.lower(searchName) == string.lower(spellName)) then
				local nextName, nextSubName = GetSpellName(id+1, BOOKTYPE_SPELL);
				if (string.lower(nextName) ~= string.lower(searchName)) then
					break;
				end	
			end
		end	
	end
	if (id == maxSpells) then
		id = nil;
	end
	return id;
end


function DS_Help()
	DEFAULT_CHAT_FRAME:AddMessage("Добро пожаловать в Dark Slackers.",1,1,0);
	DEFAULT_CHAT_FRAME:AddMessage("Список доступных команд:",0,1,0);
	DEFAULT_CHAT_FRAME:AddMessage("/rl - Reload UI.",1,1,1);
	DEFAULT_CHAT_FRAME:AddMessage("/autores - Воскрешение погибших слакеров.",1,1,1);
	DEFAULT_CHAT_FRAME:AddMessage("/prior - Показать список приоритета на воскрешение в порядке убывания.",1,1,1);
	DEFAULT_CHAT_FRAME:AddMessage("/reset - Ресет инстов.",1,1,1);
end


function DS_OnEvent()
    if event == EVENT_ADDON_LOADED and arg1 == 'DarkSlackers' then
        DS_Help();
	elseif event == EVENT_RESURRECT_REQUEST then
		UIErrorsFrame:AddMessage(arg1.." - Resurrection")
		TargetByName(arg1, true)
		local resConditions = GetCorpseRecoveryDelay() == 0 and UnitIsPlayer("target") and UnitIsVisible("target") and not UnitAffectingCombat("target")
		if resConditions then
			AcceptResurrect()
		end
		TargetLastTarget();
    end
end

if playerClass == "PRIEST" then
    resSpell = "Resurrection";
elseif playerClass == "SHAMAN" then
    resSpell = "Ancestral Spirit";
elseif playerClass == "PALADIN" then
    resSpell = "Redemption";
end

function DS_AutoResPrior()
    DEFAULT_CHAT_FRAME:AddMessage("PRIEST - SHAMAN - PALADIN - DRUID - WARLOCK - MAGE - HUNTER - WARRIOR - ROGUE",1,1,0);
end

function DS_AutoRes()
	if playerClass == "PRIEST" or playerClass == "SHAMAN" or playerClass == "PALADIN" then
		if HealComm == nil then
			HealComm = AceLibrary("HealComm-1.0") 
		end
		local classOrder = {"PRIEST", "SHAMAN", "PALADIN", "DRUID", "MAGE", "WARLOCK", "HUNTER", "WARRIOR", "ROGUE"};
		CastSpell(DS_FindSpell(resSpell), BOOKTYPE_SPELL);
		for c=1,table.getn(classOrder) do
			for i = 1,40 do
			Target = 0;
				if GetNumRaidMembers() > 0 then
					Target = 'raid'..i
				elseif GetNumRaidMembers() == 0 then
					if GetNumPartyMembers() > 0 then
						Target = 'party'..i
					elseif GetNumPartyMembers() == 0 then
						Target = 'Player'
					end
				end	

				local _, raidClass = UnitClass(Target);

				if UnitIsDead(Target)
				and CheckInteractDistance(Target,4)
				and not HealComm:UnitisResurrecting(UnitName(Target))
				and raidClass == classOrder[c] 
				then
					SpellTargetUnit(Target);
                    SendChatMessage(UnitName(Target) .. ", хватит лежать, пора послакать", "SAY");
				end
			end
		end
	elseif playerClass == "DRUID" or playerClass == "WARLOCK" or playerClass == "MAGE" or playerClass == "HUNTER" or playerClass == "WARRIOR" or playerClass == "ROGUE" then
		DEFAULT_CHAT_FRAME:AddMessage("Если хочешь иметь способность реса, то пересаживайся играть на паладина",1,1,0);
	end
end
