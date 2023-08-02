
TooltipRealmInfoDB = {};
local addon, ns = ...;
local L = ns.L;
local C = WrapTextInColorCode;

ns.debugMode = "@project-version@"=="@".."project-version".."@";
LibStub("HizurosSharedTools").RegisterPrint(ns,addon,"TTRI");

-- very nice addon from Phanx :) Thanks...
local LRI = LibStub("LibRealmInfo");

local frame, media, blizzOptPanel = CreateFrame("frame"), "Interface\\AddOns\\"..addon.."\\media\\";
local _FRIENDS_LIST_REALM, _LFG_LIST_TOOLTIP_LEADER = FRIENDS_LIST_REALM.."|r(.+)", gsub(LFG_LIST_TOOLTIP_LEADER,"%%s","(.+)");
local _SOCIAL_QUEUE_COMMUNITIES_HEADER_FORMAT = SOCIAL_QUEUE_COMMUNITIES_HEADER_FORMAT:gsub("%(","%%("):gsub("%)","%%)"):gsub("%%s","(.*)");
local id, name, api_name, rules, locale, battlegroup, region, timezone, connections, latin_name, latin_api_name, iconstr, iconfile = 1,2,3,4,5,6,7,8,9,10,11,12,13;
local DST,locked, Code2UTC, regionFix = 0,false,{EST=-5,CST=-6,MST=-7,PST=-8,AEST=10,US=-3,BRT=-3};
local dbDefaults = {
	timezone=false,
	type=true,
	language=true,
	connectedrealms=true,
	loadedmessage=true,
	countryflag="languageline",
	finder_counryflag=true,
	communities_countryflag=true,
	ttGrpFinder=true,
	ttPlayer=true,
	ttFriends=true,
	BG_countryflag = true,
	CHANNEL_countryflag = true,
	INSTANCE_countryflag = true,
	PARTY_countryflag = true,
	RAID_countryflag = true,
	SAY_countryflag = true,
	WHISPER_countryflag = true,
};
local modifierValues = {
	[false] = VIDEO_OPTIONS_DISABLED,
	[true] = VIDEO_OPTIONS_ENABLED,
	A  = ALT_KEY,
	AL = LALT_KEY_TEXT,
	AR = RALT_KEY_TEXT,
	C  = CTRL_KEY,
	CL = LCTRL_KEY_TEXT,
	CR = RCTRL_KEY_TEXT,
	S  = SHIFT_KEY,
	SL = LSHIFT_KEY_TEXT,
	SR = RSHIFT_KEY_TEXT,
}
local isModifier,modifiers = false,{
	A  = {LALT=1,RALT=1},
	AL = {LALT=1},
	AR = {RALT=1},
	C  = {LCTRL=1,RCTRL=1},
	CL = {LCTRL=1},
	CR = {RCTRL=1},
	S  = {LSHIFT=1,RSHIFT=1},
	SL = {LSHIFT=1},
	SR = {RSHIFT=1},
};

local tooltipLines = {
	-- { <name of line in slash command>, <return table index from local GetRealmInfo function>, <name of line in tooltip> }
	-- 1. and 3. value will be localized in the function AddLines() and SlashCmdList["TOOLTIPREALMINFO"]() before output
	{"language",locale,"RlmLang"},
	{"type",rules,"RlmType"},
	{"timezone",timezone,"RlmTZ"},
	{"connectedrealms",connections,"RlmConn"}
};

local myRealm = {GetRealmName(),false};
do
	local pattern = "^"..(myRealm[1]:gsub("(.)","%1*")).."$";
	for i,v in ipairs(GetAutoCompleteRealms()) do
		if v:match(pattern) then
			myRealm[2] = v;
			break;
		end
	end
	if not myRealm[2] then
		myRealm[2] = myRealm[1]:gsub(" ",""):gsub("%-","");
	end
	if not LRI:GetCurrentRegion() then
		regionFix = ({"US","KR","EU","TW","CN"})[GetCurrentRegion()];
	end
end

local replaceRealmNames	 = { -- <api> = <LibRealmInfo compatible>
	["AeriePeak"] = "Aerie Peak", ["AltarofStorms"] = "Altar of Storms", ["AlteracMountains"] = "Alterac Mountains",
	["AmanThul"] = "Aman'Thul", ["Anubarak"] = "Anub'arak", ["Area52"] = "Area 52", ["ArgentDawn"] = "Argent Dawn",
	["BlackDragonflight"] = "Black Dragonflight", ["BlackwaterRaiders"] = "Blackwater Raiders", ["BlackwingLair"] = "Blackwing Lair",
	["BladesEdge"] = "Blade's Edge", ["BleedingHollow"] = "Bleeding Hollow", ["BloodFurnace"] = "Blood Furnace",
	["BoreanTundra"] = "Borean Tundra", ["BurningBlade"] = "Burning Blade", ["BurningLegion"] = "Burning Legion",
	["CenarionCircle"] = "Cenarion Circle", ["Chogall"] = "Cho'gall", ["DarkIron"] = "Dark Iron", ["DathRemar"] = "Dath'Remar",
	["DemonSoul"] = "Demon Soul", ["DrakTharon"] = "Drak'Tharon", ["Drakthul"] = "Drak'thul", ["EarthenRing"] = "Earthen Ring",
	["EchoIsles"] = "Echo Isles", ["EldreThalas"] = "Eldre'Thalas", ["EmeraldDream"] = "Emerald Dream",
	["GrizzlyHills"] = "Grizzly Hills", ["Guldan"] = "Gul'dan", ["JubeiThos"] = "Jubei'Thos", ["Kaelthas"] = "Kael'thas",
	["KelThuzad"] = "Kel'Thuzad", ["KhazModan"] = "Khaz Modan", ["Khazgoroth"] = "Khaz'goroth", ["Kiljaeden"] = "Kil'jaeden",
	["KirinTor"] = "Kirin Tor", ["KulTiras"] = "Kul Tiras", ["LaughingSkull"] = "Laughing Skull",
	["LightningsBlade"] = "Lightning's Blade", ["MalGanis"] = "Mal'Ganis", ["MokNathal"] = "Mok'Nathal", ["MoonGuard"] = "Moon Guard",
	["Mugthol"] = "Mug'thol", ["Nerzhul"] = "Ner'zhul", ["QuelThalas"] = "Quel'Thalas", ["Queldorei"] = "Quel'dorei",
	["ScarletCrusade"] = "Scarlet Crusade", ["Senjin"] = "Sen'jin", ["ShadowCouncil"] = "Shadow Council",
	["ShatteredHalls"] = "Shattered Halls", ["ShatteredHand"] = "Shattered Hand", ["Shuhalo"] = "Shu'halo", ["SilverHand"] = "Silver Hand",
	["SistersofElune"] = "Sisters of Elune", ["SteamwheedleCartel"] = "Steamwheedle Cartel", ["TheForgottenCoast"] = "The Forgotten Coast",
	["TheScryers"] = "The Scryers", ["TheUnderbog"] = "The Underbog", ["TheVentureCo"] = "The Venture Co",
	["ThoriumBrotherhood"] = "Thorium Brotherhood", ["TolBarad"] = "Tol Barad", ["TwistingNether"] = "Twisting Nether",
	["Veknilash"] = "Vek'nilash", ["WyrmrestAccord"] = "Wyrmrest Accord", ["Zuljin"] = "Zul'jin", ["AeriePeak"] = "Aerie Peak",
	["AggraPortuguês"] = "Aggra (Português)", ["AhnQiraj"] = "Ahn'Qiraj", ["AlAkir"] = "Al'Akir", ["AmanThul"] = "Aman'Thul",
	["Anubarak"] = "Anub'arak", ["Area52"] = "Area 52", ["ArgentDawn"] = "Argent Dawn", ["Ясеневыйлес"] = "Ясеневый лес",
	["ЧерныйШрам"] = "Черный Шрам", ["BladesEdge"] = "Blade's Edge", ["Пиратскаябухта"] = "Пиратская бухта",
	["Борейскаятундра"] = "Борейская тундра", ["BronzeDragonflight"] = "Bronze Dragonflight", ["BurningBlade"] = "Burning Blade",
	["BurningLegion"] = "Burning Legion", ["BurningSteppes"] = "Burning Steppes", ["CThun"] = "C'Thun", ["ChamberofAspects"] = "Chamber of Aspects",
	["Chantséternels"] = "Chants éternels", ["Chogall"] = "Cho'gall", ["ColinasPardas"] = "Colinas Pardas",
	["ConfrérieduThorium"] = "Confrérie du Thorium", ["ConseildesOmbres"] = "Conseil des Ombres", ["CultedelaRivenoire"] = "Culte de la Rive noire",
	["DarkmoonFaire"] = "Darkmoon Faire", ["DasKonsortium"] = "Das Konsortium", ["DasSyndikat"] = "Das Syndikat", ["СтражСмерти"] = "Страж Смерти",
	["ТкачСмерти"] = "Ткач Смерти", ["DefiasBrotherhood"] = "Defias Brotherhood", ["DerMithrilorden"] = "Der Mithrilorden",
	["DerRatvonDalaran"] = "Der Rat von Dalaran", ["DerabyssischeRat"] = "Der abyssische Rat", ["DieAldor"] = "Die Aldor",
	["DieArguswacht"] = "Die Arguswacht", ["DieNachtwache"] = "Die Nachtwache", ["DieSilberneHand"] = "Die Silberne Hand",
	["DieTodeskrallen"] = "Die Todeskrallen", ["DieewigeWacht"] = "Die ewige Wacht", ["Drakthul"] = "Drak'thul", ["DrekThar"] = "Drek'Thar",
	["DunModr"] = "Dun Modr", ["DunMorogh"] = "Dun Morogh", ["EarthenRing"] = "Earthen Ring", ["EldreThalas"] = "Eldre'Thalas",
	["EmeraldDream"] = "Emerald Dream", ["ВечнаяПесня"] = "Вечная Песня", ["FestungderStürme"] = "Festung der Stürme", ["GrimBatol"] = "Grim Batol",
	["Guldan"] = "Gul'dan", ["Ревущийфьорд"] = "Ревущий фьорд", ["Kaelthas"] = "Kael'thas", ["KelThuzad"] = "Kel'Thuzad",
	["KhazModan"] = "Khaz Modan", ["Khazgoroth"] = "Khaz'goroth", ["Kiljaeden"] = "Kil'jaeden", ["KirinTor"] = "Kirin Tor", ["Korgall"] = "Kor'gall",
	["Kragjin"] = "Krag'jin", ["KulTiras"] = "Kul Tiras", ["KultderVerdammten"] = "Kult der Verdammten",
	["LaCroisadeécarlate"] = "La Croisade écarlate", ["LaughingSkull"] = "Laughing Skull", ["LesClairvoyants"] = "Les Clairvoyants",
	["LesSentinelles"] = "Les Sentinelles", ["Корольлич"] = "Король-лич", ["LightningsBlade"] = "Lightning's Blade", ["LosErrantes"] = "Los Errantes",
	["MalGanis"] = "Mal'Ganis", ["MarécagedeZangar"] = "Marécage de Zangar", ["Mugthol"] = "Mug'thol", ["Nerzhul"] = "Ner'zhul",
	["Nerathor"] = "Nera'thor", ["PozzodellEternità"] = "Pozzo dell'Eternità", ["QuelThalas"] = "Quel'Thalas", ["ScarshieldLegion"] = "Scarshield Legion",
	["Senjin"] = "Sen'jin", ["ShatteredHalls"] = "Shattered Halls", ["ShatteredHand"] = "Shattered Hand", ["Shendralar"] = "Shen'dralar",
	["СвежевательДуш"] = "Свежеватель Душ", ["SteamwheedleCartel"] = "Steamwheedle Cartel", ["TarrenMill"] = "Tarren Mill",
	["Templenoir"] = "Temple noir", ["TheMaelstrom"] = "The Maelstrom", ["TheShatar"] = "The Sha'tar", ["TheVentureCo"] = "The Venture Co",
	["ThrokFeroth"] = "Throk'Feroth", ["TwilightsHammer"] = "Twilight's Hammer", ["TwistingNether"] = "Twisting Nether", ["UnGoro"] = "Un'Goro",
	["Veklor"] = "Vek'lor", ["Veknilash"] = "Vek'nilash", ["Voljin"] = "Vol'jin", ["ZirkeldesCenarius"] = "Zirkel des Cenarius", ["Zuljin"] = "Zul'jin"
};

local function GetRealmInfo(object)
	if not (type(object)=="string" and object:trim():len()>0) then
		return false;
	end

	local res,name,realm,_ = {};
	if object:find("^Player%-%d+") then -- object is guid
		local realmId = tonumber(object:match("^Player%-(%d+)"));
		if realmId then
			res = {LRI:GetRealmInfoByID(realmId)}; -- realm info by realmId
		end
		if #res==0 then
			local _, _, _, _, _, n, r = GetPlayerInfoByGUID(object);
			if n then
				realm = r:len()>0 and r or myRealm;
			end
		end
	end

	if #res==0 then
		if not realm and object:find("%-") and not object:find("^Player%-") then
			_,realm,_ = strsplit("- ",object,3); -- character name + realm + faction (optional)
		end
		if not realm then
			realm = object;
		end
		for i,v in ipairs({realm, myRealm[2]}) do
			if type(v)=="string" and v:len()>0 then
				res = {LRI:GetRealmInfo(v,regionFix)};
				if #res==0 and replaceRealmNames[v] then
					res = {LRI:GetRealmInfo(replaceRealmNames[v],regionFix)};
				end
				if #res>0 then
					break;
				end
			end
		end
	end

	if #res==0 then
		ns:debug("<GetRealmInfo>","<NoResultFor>",object);
		return;
	end

	-- modify locale
	if res[region]=="EU" then
		if res[locale]=="enUS" then
			res[locale] = "enGB"; -- Great Britain
		elseif res[locale]=="ptBR" then
			res[locale] = "ptPT"
		end
	end

	-- add icon
	if res[region]=="US" and res[timezone]=="AEST" then
		res[iconfile] = media.."enAU"; -- flag of australian
	else
		res[iconfile] = media..res[locale];
	end
	res[iconstr] = "|T"..res[iconfile]..":0:2|t";

	-- modify rules
	local rules_l = res[rules]:lower();
	if rules_l=="rp" or rules_l=="rppvp" then
		res[rules] = "RP PvE";
	elseif rules_l=="pvp" then
		res[rules] = "PvE";
	else
		res[rules] = gsub(res[rules],"V","v");
	end

	-- modify timezones
	if not res[timezone] then
		if res[region]=="EU" then
			if res[locale]=="enGB" or res[locale]=="ptPT" then
				res[timezone] = 0 + DST;
			elseif locale=="ruRU" then
				res[timezone] = 3; -- no DST
			else
				res[timezone] = 1 + DST;
			end
		elseif res[region]=="CN" or res[region]=="TW" then
			res[timezone] = 8;
		else
			res[timezone] = 9;
		end
	else
		res[timezone] = Code2UTC[res[timezone]] + DST;
	end

	if not res[timezone] then
		res[timezone] = "Unknown";
	else
		res[timezone] = "UTC" .. ( (res[timezone]==0 and " ") or (res[timezone]<0 and "-") or "+" ) .. res[timezone];
	end

	return res;
end

local function CheckLineVisibility(key)
	local value = TooltipRealmInfoDB[key];
	if type(value)=="boolean" then
		return value;
	elseif isModifier and modifiers[value] and modifiers[value][isModifier]==1 then
		return true;
	end
	return false;
end

local function AddLines(tt,object,_title,newLineOnFlat)
	if not _title then
		_title = "%s: ";
	end

	local objType,realm,_=type(object);
	if objType=="table" then
		realm = object;
	elseif objType=="string" then
		realm = GetRealmInfo(object);
	end

	if not (type(realm)=="table" and #realm>0) then
		return false;
	end

	if realm[iconstr] and TooltipRealmInfoDB.countryflag=="charactername" then
		local ttName = tt:GetName();
		if ttName then
			_G[ttName.."TextLeft1"]:SetText(_G[ttName.."TextLeft1"]:GetText().." "..realm[iconstr]);
		end
	end

	for i,v in ipairs(tooltipLines)do
		if CheckLineVisibility(v[1]) then
			local title,text = _title:format(L[v[3]]),"";
			if v[1]=="language" then
				local lCode = realm[v[2]]:upper();
				if _G["LFG_LIST_LANGUAGE_"..lCode]~=nil or _G[lCode]~=nil then
					text = text .. (_G["LFG_LIST_LANGUAGE_"..lCode] or _G[lCode]);
					if realm[iconstr] and TooltipRealmInfoDB.countryflag=="languageline" then
						text = text .. realm[iconstr];
					end
				else
					text = text .. realm[v[2]].."?";
				end
			elseif v[1]=="connectedrealms" then
				local names,color = {},"ffffff";
				if realm[v[2]] and #realm[v[2]]>1 then
					for i=1,#realm[v[2]] do
						local _, realm_name = LRI:GetRealmInfoByID(realm[v[2]][i],regionFix);
						if realm_name == myRealm[1] then
							color="00ff00";
						end
						tinsert(names,realm_name);
					end
					text = text .. table.concat(names,",|n");
				end
				if type(tt)~="string" and #names>0 then
					table.sort(names);
					local flat = false;
					if #names>4 then
						flat = {};
					end
					for i,v in pairs(names) do
						v = C(v,"ff"..color);
						if flat then
							if title then
								tt:AddLine(title);
								title = nil;
							end
							tinsert(flat,v);
						else
							tt:AddDoubleLine(title,v);
							title = " ";
						end
					end
					if flat then
						tt:AddLine(table.concat(flat,", ")..(newLineOnFlat and "|n " or ""),1,1,1,1);
					end
					text = "";
				end
			elseif v[2] and realm[v[2]] then
				text = text .. realm[v[2]];
			end
			if text:len()>0 then
				if type(tt)=="string" then
					tt = tt.."|n"..title..text;
				else
					locked=true;
					tt:AddDoubleLine(title,C(text,"ffffffff"));
					locked=false;
				end
			end
		end
	end

	if realm[iconstr] and TooltipRealmInfoDB.countryflag=="ownline" then
		tt:AddLine(realm[iconstr]);
	end

	return tt;
end

-- some gametooltip scripts/funcion hooks
do
	local ttDone = nil;
	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function()
		if ttDone==true or not TooltipRealmInfoDB.ttPlayer then return end
		ttDone = true;
		local self = GameTooltip
		local name, unit, guid, realm = self:GetUnit();
		if not unit then
			local mf = GetMouseFocus();
			if mf and mf.unit then
				unit = mf.unit;
			end
		end
		if unit and UnitIsPlayer(unit) then
			AddLines(self,UnitGUID(unit) or UnitName(unit));
		end
	end);

	GameTooltip:HookScript("OnTooltipCleared", function(self)
		ttDone = nil
	end)
end

local function GetObjOwnerName(self)
	local owner, owner_name = self:GetOwner();
	if owner then
		owner_name = owner:GetName();
		if not owner_name then
			owner_name = owner:GetDebugName();
		end
	end
	return owner,owner_name;
end

hooksecurefunc(GameTooltip,"SetText",function(self,name)
	if locked or (not TooltipRealmInfoDB.ttGrpFinder) then return end
	local owner, owner_name = GetObjOwnerName(self);
	if owner_name then
		if owner_name:find("^LFGListFrame%.ApplicationViewer%.ScrollBox%.ScrollTarget%.[a-z0-9]*%.Member[0-9]*") then
			-- GroupFinder > ApplicantViewer > Tooltip
			local button = owner:GetParent();
			if button and button.applicantID and owner.memberIdx then
				local name, class, localizedClass, level, itemLevel, honorLevel, tank, healer, damage, assignedRole, relationship, dungeonScore, pvpItemLevel = C_LFGList.GetApplicantMemberInfo(button.applicantID, owner.memberIdx);
				AddLines(self,name);
			end
		elseif owner_name:find("^QuickJoinFrame%.ScrollBox%.ScrollTarget") then
			local name = name:match(_SOCIAL_QUEUE_COMMUNITIES_HEADER_FORMAT);
			if name then
				AddLines(self,name);
			end
		end
	end
end);

hooksecurefunc(GameTooltip,"AddLine",function(self,text) -- GameTooltip_AddColoredLine
	if locked or (not TooltipRealmInfoDB.ttGrpFinder) or text==nil then return end
	-- text==nil required for bug in FrameXML/LFGList.lua line 3499. [ tooltip:AddLine(activityName); ] activityName is nil.
	local owner, owner_name = GetObjOwnerName(self);
	if owner_name then
		if owner_name:find("^LFGListFrame%.SearchPanel%.ScrollBox%.ScrollTarget%.[a-z0-9]*") then
			-- GroupFinder > SearchResult > Tooltip
			local leaderName = text:match(_LFG_LIST_TOOLTIP_LEADER);
			if leaderName then
				AddLines(self,leaderName);
			end
		elseif owner_name:find("^CommunitiesFrame%.MemberList%.ScrollBox%.ScrollTarget") then
			-- Communities > MemberList > Tooltip
			if owner.memberInfo and owner.memberInfo.clubType~=0 and text==owner.memberInfo.name then
				-- Community member list tooltips
				AddLines(self,owner.memberInfo.name,nil,true)
			elseif owner.Info and owner.GetApplicantName and text==owner.Info.name then
				-- Community applicant list tooltip
				local _, _, _, _, _, name, realm = GetPlayerInfoByGUID(owner.Info.playerGUID);
				GameTooltip:AddDoubleLine(FRIENDS_LIST_REALM, C((realm and strlen(realm)>0 and realm) or GetRealmName(),"ffffffff"));
				AddLines(self,name,nil,true);
			end
		elseif owner_name:find("^QuickJoinFrame%.ScrollBox%.ScrollTarget") and owner.entry and owner.entry.guid then
			local leader = text:match(LFG_LIST_TOOLTIP_LEADER:gsub("%%s","(.*)"));
			if leader then
				AddLines(self,leader);
			end
		elseif owner_name:find("^BuffFrame%.AuraContainer") then
			-- do not add lines!!!
		end
	end
end);

-- Friend list tooltip
hooksecurefunc("FriendsFrameTooltip_SetLine",function(line, anchor, text, yOffset)
	if locked or (not TooltipRealmInfoDB.ttFriends) then return end
	if yOffset == -4 and text and text:find(_FRIENDS_LIST_REALM) then
		local realmName = text:match(_FRIENDS_LIST_REALM);
		if realmName then
			local realm = GetRealmInfo(realmName);
			if realm and #realm>0 then
				FriendsTooltip.height = FriendsTooltip.height - line:GetHeight(); -- remove prev. added line height
				locked=true;
				FriendsFrameTooltip_SetLine(line, anchor, AddLines(text,realm,NORMAL_FONT_COLOR_CODE.."%s:|r "), yOffset);
				locked=false;
			end
		end
	end
end);

-- Groupfinder applicants (only country flags in scroll frame)
hooksecurefunc("LFGListApplicationViewer_UpdateApplicantMember", function(member, id, index)
	if not TooltipRealmInfoDB.finder_counryflag then return end
	local name,_,_,_,_,_,_,_,_,_,relationship = C_LFGList.GetApplicantMemberInfo(id, index);
	if name then
		local realm = GetRealmInfo(name);
		if realm and #realm>0 then
			member.Name:SetText(realm[iconstr]..member.Name:GetText());
		end
	end
end);

-- ChatCountryFlags
local CCF; CCF = {
	events = {
		CHAT_MSG_BG_SYSTEM_ALLIANCE="BG",CHAT_MSG_BG_SYSTEM_HORDE="BG",CHAT_MSG_BG_SYSTEM_NEUTRAL="BG",
		CHAT_MSG_CHANNEL="CHANNEL",CHAT_MSG_COMMUNITIES_CHANNEL="CHANNEL",
		CHAT_MSG_INSTANCE_CHAT="INSTANCE",CHAT_MSG_INSTANCE_CHAT_LEADER="INSTANCE",
		CHAT_MSG_PARTY_LEADER="PARTY",CHAT_MSG_PARTY="PARTY",
		CHAT_MSG_RAID_LEADER="RAID",CHAT_MSG_RAID="RAID",CHAT_MSG_RAID_WARNING="RAID",
		CHAT_MSG_SAY="SAY",CHAT_MSG_YELL="SAY",
		CHAT_MSG_WHISPER_INFORM="WHISPER",CHAT_MSG_WHISPER="WHISPER",
	},
	Register = function()
		for event in pairs(CCF.events) do
			ChatFrame_AddMessageEventFilter(event,CCF.Filter);
		end
	end,
	Filter = function(self,event,...)
		local args,dbkey,msg,guid,realmInfo = {...},CCF.events[event].."_countryflag",1,12;
		if TooltipRealmInfoDB[dbkey] then
			local added = false;
			-- get realmInfo from player guid
			if args[guid] and args[guid]:find("^Player%-%d+") then
				realmInfo = GetRealmInfo(args[guid]);
			end
			-- add country flag to message
			if realmInfo and realmInfo[iconstr] and TooltipRealmInfoDB[realmInfo[locale].."_countryflag"] then
				args[msg] = realmInfo[iconstr].." "..args[msg];
				added = true;
			end
		end
		return false, unpack(args);
	end,
};

-- Communities members - add country flags
local function CommunitiesFrame_MemberList_ScrollBox_Update(x) -- retail / df
	local clubInfo = CommunitiesFrame:GetSelectedClubInfo();
	if not (TooltipRealmInfoDB.communities_countryflag and clubInfo and clubInfo.clubType==1) then
		return;
	end
	local buttons = CommunitiesFrame.MemberList.ScrollBox:GetFrames();
	if buttons and #buttons>0 then
		for i = 1, #buttons do
			if buttons[i].memberInfo and buttons[i].memberInfo.name then
				local realm = GetRealmInfo(buttons[i].memberInfo.name);
				if realm and #realm>0 then
					buttons[i].NameFrame.Name:SetText(realm[iconstr]..buttons[i].memberInfo.name);
					buttons[i]:UpdatePresence();
					buttons[i]:UpdateNameFrame();
				end
			end
		end
	end
end

local function CommunitiesFrame_MemberList_ListScrollFrame_Update() -- classic ?
	local clubInfo = CommunitiesFrame:GetSelectedClubInfo();
	if not (TooltipRealmInfoDB.communities_countryflag and clubInfo and clubInfo.clubType==1) then
		return;
	end
	local buttons = CommunitiesFrame.MemberList.ListScrollFrame.buttons;
	if buttons and #buttons>0 then
		for i = 1, #buttons do
			if buttons[i].memberInfo and buttons[i].memberInfo.name then
				local realm = GetRealmInfo(buttons[i].memberInfo.name);
				if realm and #realm>0 then
					buttons[i].NameFrame.Name:SetText(realm[iconstr]..buttons[i].memberInfo.name);
					buttons[i]:UpdatePresence();
					buttons[i]:UpdateNameFrame();
				end
			end
		end
	end
end

local function get_set(info,value)
	local key = info[#info];
	if value~=nil then
		TooltipRealmInfoDB[key] = value;
	end
	return TooltipRealmInfoDB[key];
end

local options = {
	type = "group",
	name = addon,
	get = get_set,
	set = get_set,
	args = {
		loadedmessage = {
				type = "toggle", order = 0,
				name = L["AddOnLoaded"], desc = L["AddOnLoadedDesc"].."|n|n|cff44ff44"..L["AddOnLoadedDescAlt"].."|r"
		},
		tooltips = {
			type = "group", order = 1,
			name = C(L["TTDisplay"],"ff0099ff"),
			inline = true,
			args = {
				desc = {
					type = "description", order = 0,
					name = L["TTDisplayDesc"]
				},
				ttGrpFinder = {
					type = "toggle", order = 2,
					name = LFGLIST_NAME, --desc = L["TTDisplayGrpFinderDesc"]
				},
				ttPlayer = {
					type = "toggle", order = 2,
					name = L["TTDisplayPlayer"]
				},
				ttFriends = {
					type = "toggle", order = 2,
					name = L["TTDisplayFriends"]
				}
			}
		},
		tooltipLines = {
			type = "group", order = 2,
			name = C(L["TTLines"],"ff0099ff"),
			inline = true,
			args = {
				desc = {
					type = "description", order = 0,
					name = L["TTLinesDesc"]
				},
				timezone = {
					type = "select", order = 1,
					name = L["RlmTZ"], desc = L["RlmInfoDesc"],
					values = modifierValues
				},
				type = {
					type = "select", order = 2,
					name = L["RlmType"], desc = L["RlmInfoDesc"],
					values = modifierValues
				},
				language = {
					type = "select", order = 3,
					name = L["RlmLang"], desc = L["RlmInfoDesc"],
					values = modifierValues
				},
				connectedrealms = {
					type = "select", order = 4,
					name = L["RlmConn"], desc = L["RlmInfoDesc"],
					values = modifierValues
				},
				countryflag = {
					type = "select", order = 6, width = "full",
					name = L["CtryFlg"],
					desc = L["CtryFlgDesc"],
					values = {
						languageline = L["CtryFlgSelLang"],
						charactername = L["CtryFlgSelName"].." "..L["CtryFlgTipTacInfo"],
						ownline = L["CtryFlgSelOwn"],
						none = ADDON_DISABLED
					}
				}
			}
		},
		country_flags = {
			type = "group", order = 3,
			name = C(L["CtryFlg"],"ff0099ff"),
			inline = true,
			args = {
				finder_counryflag = {
					type = "toggle", order = 1,
					name = LFGLIST_NAME, desc = L["CtryFlgGrpFndrDesc"]
				},
				communities_countryflag = {
					type = "toggle", order = 2,
					name = COMMUNITIES, desc = L["CtryFlgCommDesc"]
				},
				countryflag_header = {
					type = "header", order = 3,
					name = L["CtryFlgChatHeader"],
				},
				countryflag_desc1 = {
					type = "description", order = 4, fontSize = "medium",
					name = C(L["CtryFlgChatDesc1"],"ffff8800")
				},
				BG_countryflag = {
					type = "toggle", order = 10,
					name = BATTLEGROUND, --desc = L["CtryFlgChatDescBG"]
				},
				INSTANCE_countryflag = {
					type = "toggle", order = 10,
					name = INSTANCE, --desc = L["CtryFlgChatDescINSTANCE"]
				},
				PARTY_countryflag = {
					type = "toggle", order = 10,
					name = PARTY, --desc = L["CtryFlgChatDescPARTY"]
				},
				RAID_countryflag = {
					type = "toggle", order = 10,
					name = RAID, --desc = L["CtryFlgChatDescRAID"]
				},
				CHANNEL_countryflag = {
					type = "toggle", order = 10,
					name = CHANNEL, --desc = L["CtryFlgChatDescCHANNEL"]
				},
				SAY_countryflag = {
					type = "toggle", order = 10,
					name = SAY, --desc = L["CtryFlgChatDescSAY"]
				},
				WHISPER_countryflag = {
					type = "toggle", order = 10,
					name = WHISPER, --desc = L["CtryFlgChatDescWHISPER"]
				},
				countryflag_desc2 = {
					type = "description", order = 11, fontSize = "medium",
					name = C(L["CtryFlgChatDesc2"],"ffff8800")
				},

			}
		},
		credits = {
			type = "group", order = 200, inline = true,
			name = L["Credit"],
			args = {}
		},
	}
};

local function RegisterOptionPanel()
	LibStub("AceConfig-3.0"):RegisterOptionsTable(addon, options);
	blizzOptPanel = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addon);
	LibStub("HizurosSharedTools").BlizzOptions_ExpandOnShow(blizzOptPanel);
	LibStub("HizurosSharedTools").AddCredit(addon); -- options.args.credits.args
end

local function RegisterSlashCommand()
	function SlashCmdList.TOOLTIPREALMINFO(cmd)
		local _print = function(key)
			ns:print( L[ TooltipRealmInfoDB[key] and "CmdNowIsShown" or "CmdNowIsHidden"]:format(L[key]) );
		end
		local cmd, arg = strsplit(" ", cmd, 2);
		cmd = cmd:lower();

		if cmd=="timezone" or cmd=="type" or cmd=="language" or cmd=="connectedrealms" then
			TooltipRealmInfoDB[cmd] = not TooltipRealmInfoDB[cmd];
			_print(cmd);
		elseif cmd=="loadedmessage" then
			TooltipRealmInfoDB.loadedmessage = not TooltipRealmInfoDB.loadedmessage;
			ns:print(L["CmdLoadedMsg"],TooltipRealmInfoDB.loadedmessage and VIDEO_OPTIONS_ENABLED or VIDEO_OPTIONS_DISABLED);
		elseif cmd=="config" then
			LibStub("HizurosSharedTools").InterfaceOptionsFrame_OpenToCategory(addon);
		else
			ns:print(L["CmdListInfo"]);
			for i,v in ipairs({"timezone","language","type","connectedrealms"})do
				ns:print("", v, "|cffffff00-", L[TooltipRealmInfoDB[v] and "CmdListOptHide" or "CmdListOptShow"]:format(L[v]));
			end
			ns:print("","loadedmessage","|cffffff00-",L["CmdListLoadedMsg"]);
			ns:print("","config","|cffffff00-",L["CmdListOptions"]);
		end
	end

	SLASH_TOOLTIPREALMINFO1 = L["CmdSlashStringLong"];
	SLASH_TOOLTIPREALMINFO2 = L["CmdSlashStringShort"];
end

frame:SetScript("OnEvent",function(self,event,name,...)
	if event=="ADDON_LOADED" and addon==name then
		if TooltipRealmInfoDB==nil then
			TooltipRealmInfoDB = {};
		end
		local availableLanguages = C_LFGList.GetAvailableLanguageSearchFilter();
		for i=1, #availableLanguages do
			local v = availableLanguages[i];
			if GetCurrentRegion()==3 then
				if v=="enUS" then
					v = "enGB";
					if TooltipRealmInfoDB.enUS~=nil then -- TODO: delete me
						TooltipRealmInfoDB.enGB, TooltipRealmInfoDB.enUS = TooltipRealmInfoDB.enUS;
					end
				elseif v=="ptBR" then
					v = "ptPT";
					if TooltipRealmInfoDB.ptBR~=nil then -- TODO: delete me
						TooltipRealmInfoDB.ptPT, TooltipRealmInfoDB.ptBR = TooltipRealmInfoDB.ptBR;
					end
				end
			end
			local key = v.."_countryflag";
			options.args.country_flags.args[key] = {type="toggle",order=12,name="|T"..media..v..":0:2|t ".._G["LFG_LIST_LANGUAGE_"..availableLanguages[i]:upper()]};
			dbDefaults[key] = true;
		end
		for k,v in pairs(dbDefaults)do
			if TooltipRealmInfoDB[k]==nil then
				TooltipRealmInfoDB[k]=v;
			end
		end
		RegisterOptionPanel();
		RegisterSlashCommand();
		if TooltipRealmInfoDB.loadedmessage or IsShiftKeyDown() then
			ns:print(L["AddOnLoaded"],"","\n",L["CmdOnLoadInfo"]);
		end
	elseif event=="ADDON_LOADED" and "Blizzard_Communities"==name then
		if CommunitiesFrame.MemberList.ScrollBox then
			hooksecurefunc(CommunitiesFrame.MemberList.ScrollBox,"Update",CommunitiesFrame_MemberList_ScrollBox_Update);
		elseif CommunitiesFrame.MemberList.ListScrollFrame then
			hooksecurefunc(CommunitiesFrame.MemberList.ListScrollFrame,"Update",CommunitiesFrame_MemberList_ListScrollFrame_Update);
		end
	elseif event=="PLAYER_LOGIN" then
		local t = date("*t");
		DST = t.isdst and 1 or 0;
		CCF.Register();
	elseif event=="MODIFIER_STATE_CHANGED" then
		local key, down = name,...;
		isModifier = down==1 and key or false;
	end
end);
frame:RegisterEvent("ADDON_LOADED");
frame:RegisterEvent("PLAYER_LOGIN");
frame:RegisterEvent("MODIFIER_STATE_CHANGED");
