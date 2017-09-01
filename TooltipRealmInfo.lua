
TooltipRealmInfoDB = {};
local addon, ns = ...;

-- very nice addon from Phanx :) Thanks...
local LRI = LibStub("LibRealmInfo");

local frame, media, myRealm = CreateFrame("frame"), "Interface\\AddOns\\"..addon.."\\media\\", GetRealmName();
local _FRIENDS_LIST_REALM, _LFG_LIST_TOOLTIP_LEADER = FRIENDS_LIST_REALM.."|r(.+)", gsub(LFG_LIST_TOOLTIP_LEADER,"%%s","(.+)");
local id, name, api_name, rules, locale, battlegroup, region, timezone, connections, latin_name, latin_api_name, iconstr, iconfile = 1,2,3,4,5,6,7,8,9,10,11,12,13;
local DST,locked, Code2UTC = 0,false,{EST=-5,CST=-6,MST=-7,PST=-8,AEST=10};
local dbDefaults = {battlegroup=false,timezone=false,type=true,language=true,connectedrealms=true,loadedmessage=true,countryflag="languageline",finder_counryflag=true};
local L = setmetatable({["type"]=TYPE,["language"]=LANGUAGE},{__index=function(t,k) local v=tostring(k);rawset(t,k,v);return v;end});
local tooltipLines = { {"language",locale,"Realm language"}, {"type",rules,"Realm type"}, {"timezone",timezone,"Realm timezone"}, {"battlegroup",battlegroup,"Realm battlegroup"}, {"connectedrealms",connections,"Connected realms"} };
local replaceRealmNames,region = { -- <api> = <LibRealmInfo compatible>
	["AeriePeak"] = "Aerie Peak",
	["AltarofStorms"] = "Altar of Storms",
	["AlteracMountains"] = "Alterac Mountains",
	["AmanThul"] = "Aman'Thul",
	["Anubarak"] = "Anub'arak",
	["Area52"] = "Area 52",
	["ArgentDawn"] = "Argent Dawn",
	["BlackDragonflight"] = "Black Dragonflight",
	["BlackwaterRaiders"] = "Blackwater Raiders",
	["BlackwingLair"] = "Blackwing Lair",
	["BladesEdge"] = "Blade's Edge",
	["BleedingHollow"] = "Bleeding Hollow",
	["BloodFurnace"] = "Blood Furnace",
	["BoreanTundra"] = "Borean Tundra",
	["BurningBlade"] = "Burning Blade",
	["BurningLegion"] = "Burning Legion",
	["CenarionCircle"] = "Cenarion Circle",
	["Chogall"] = "Cho'gall",
	["DarkIron"] = "Dark Iron",
	["DathRemar"] = "Dath'Remar",
	["DemonSoul"] = "Demon Soul",
	["DrakTharon"] = "Drak'Tharon",
	["Drakthul"] = "Drak'thul",
	["EarthenRing"] = "Earthen Ring",
	["EchoIsles"] = "Echo Isles",
	["EldreThalas"] = "Eldre'Thalas",
	["EmeraldDream"] = "Emerald Dream",
	["GrizzlyHills"] = "Grizzly Hills",
	["Guldan"] = "Gul'dan",
	["JubeiThos"] = "Jubei'Thos",
	["Kaelthas"] = "Kael'thas",
	["KelThuzad"] = "Kel'Thuzad",
	["KhazModan"] = "Khaz Modan",
	["Khazgoroth"] = "Khaz'goroth",
	["Kiljaeden"] = "Kil'jaeden",
	["KirinTor"] = "Kirin Tor",
	["KulTiras"] = "Kul Tiras",
	["LaughingSkull"] = "Laughing Skull",
	["LightningsBlade"] = "Lightning's Blade",
	["MalGanis"] = "Mal'Ganis",
	["MokNathal"] = "Mok'Nathal",
	["MoonGuard"] = "Moon Guard",
	["Mugthol"] = "Mug'thol",
	["Nerzhul"] = "Ner'zhul",
	["QuelThalas"] = "Quel'Thalas",
	["Queldorei"] = "Quel'dorei",
	["ScarletCrusade"] = "Scarlet Crusade",
	["Senjin"] = "Sen'jin",
	["ShadowCouncil"] = "Shadow Council",
	["ShatteredHalls"] = "Shattered Halls",
	["ShatteredHand"] = "Shattered Hand",
	["Shuhalo"] = "Shu'halo",
	["SilverHand"] = "Silver Hand",
	["SistersofElune"] = "Sisters of Elune",
	["SteamwheedleCartel"] = "Steamwheedle Cartel",
	["TheForgottenCoast"] = "The Forgotten Coast",
	["TheScryers"] = "The Scryers",
	["TheUnderbog"] = "The Underbog",
	["TheVentureCo"] = "The Venture Co",
	["ThoriumBrotherhood"] = "Thorium Brotherhood",
	["TolBarad"] = "Tol Barad",
	["TwistingNether"] = "Twisting Nether",
	["Veknilash"] = "Vek'nilash",
	["WyrmrestAccord"] = "Wyrmrest Accord",
	["Zuljin"] = "Zul'jin",
	["AeriePeak"] = "Aerie Peak",
	["AggraPortuguês"] = "Aggra (Português)",
	["AhnQiraj"] = "Ahn'Qiraj",
	["AlAkir"] = "Al'Akir",
	["AmanThul"] = "Aman'Thul",
	["Anubarak"] = "Anub'arak",
	["Area52"] = "Area 52",
	["ArgentDawn"] = "Argent Dawn",
	["Ясеневыйлес"] = "Ясеневый лес",
	["ЧерныйШрам"] = "Черный Шрам",
	["BladesEdge"] = "Blade's Edge",
	["Пиратскаябухта"] = "Пиратская бухта",
	["Борейскаятундра"] = "Борейская тундра",
	["BronzeDragonflight"] = "Bronze Dragonflight",
	["BurningBlade"] = "Burning Blade",
	["BurningLegion"] = "Burning Legion",
	["BurningSteppes"] = "Burning Steppes",
	["CThun"] = "C'Thun",
	["ChamberofAspects"] = "Chamber of Aspects",
	["Chantséternels"] = "Chants éternels",
	["Chogall"] = "Cho'gall",
	["ColinasPardas"] = "Colinas Pardas",
	["ConfrérieduThorium"] = "Confrérie du Thorium",
	["ConseildesOmbres"] = "Conseil des Ombres",
	["CultedelaRivenoire"] = "Culte de la Rive noire",
	["DarkmoonFaire"] = "Darkmoon Faire",
	["DasKonsortium"] = "Das Konsortium",
	["DasSyndikat"] = "Das Syndikat",
	["СтражСмерти"] = "Страж Смерти",
	["ТкачСмерти"] = "Ткач Смерти",
	["DefiasBrotherhood"] = "Defias Brotherhood",
	["DerMithrilorden"] = "Der Mithrilorden",
	["DerRatvonDalaran"] = "Der Rat von Dalaran",
	["DerabyssischeRat"] = "Der abyssische Rat",
	["DieAldor"] = "Die Aldor",
	["DieArguswacht"] = "Die Arguswacht",
	["DieNachtwache"] = "Die Nachtwache",
	["DieSilberneHand"] = "Die Silberne Hand",
	["DieTodeskrallen"] = "Die Todeskrallen",
	["DieewigeWacht"] = "Die ewige Wacht",
	["Drakthul"] = "Drak'thul",
	["DrekThar"] = "Drek'Thar",
	["DunModr"] = "Dun Modr",
	["DunMorogh"] = "Dun Morogh",
	["EarthenRing"] = "Earthen Ring",
	["EldreThalas"] = "Eldre'Thalas",
	["EmeraldDream"] = "Emerald Dream",
	["ВечнаяПесня"] = "Вечная Песня",
	["FestungderStürme"] = "Festung der Stürme",
	["GrimBatol"] = "Grim Batol",
	["Guldan"] = "Gul'dan",
	["Ревущийфьорд"] = "Ревущий фьорд",
	["Kaelthas"] = "Kael'thas",
	["KelThuzad"] = "Kel'Thuzad",
	["KhazModan"] = "Khaz Modan",
	["Khazgoroth"] = "Khaz'goroth",
	["Kiljaeden"] = "Kil'jaeden",
	["KirinTor"] = "Kirin Tor",
	["Korgall"] = "Kor'gall",
	["Kragjin"] = "Krag'jin",
	["KulTiras"] = "Kul Tiras",
	["KultderVerdammten"] = "Kult der Verdammten",
	["LaCroisadeécarlate"] = "La Croisade écarlate",
	["LaughingSkull"] = "Laughing Skull",
	["LesClairvoyants"] = "Les Clairvoyants",
	["LesSentinelles"] = "Les Sentinelles",
	["Корольлич"] = "Король-лич",
	["LightningsBlade"] = "Lightning's Blade",
	["LosErrantes"] = "Los Errantes",
	["MalGanis"] = "Mal'Ganis",
	["MarécagedeZangar"] = "Marécage de Zangar",
	["Mugthol"] = "Mug'thol",
	["Nerzhul"] = "Ner'zhul",
	["Nerathor"] = "Nera'thor",
	["PozzodellEternità"] = "Pozzo dell'Eternità",
	["QuelThalas"] = "Quel'Thalas",
	["ScarshieldLegion"] = "Scarshield Legion",
	["Senjin"] = "Sen'jin",
	["ShatteredHalls"] = "Shattered Halls",
	["ShatteredHand"] = "Shattered Hand",
	["Shendralar"] = "Shen'dralar",
	["СвежевательДуш"] = "Свежеватель Душ",
	["SteamwheedleCartel"] = "Steamwheedle Cartel",
	["TarrenMill"] = "Tarren Mill",
	["Templenoir"] = "Temple noir",
	["TheMaelstrom"] = "The Maelstrom",
	["TheShatar"] = "The Sha'tar",
	["TheVentureCo"] = "The Venture Co",
	["ThrokFeroth"] = "Throk'Feroth",
	["TwilightsHammer"] = "Twilight's Hammer",
	["TwistingNether"] = "Twisting Nether",
	["UnGoro"] = "Un'Goro",
	["Veklor"] = "Vek'lor",
	["Veknilash"] = "Vek'nilash",
	["Voljin"] = "Vol'jin",
	["ZirkeldesCenarius"] = "Zirkel des Cenarius",
	["Zuljin"] = "Zul'jin"
};

-- L["timezone"]
-- L["battlegroup"]

-- Hi. This addon needs your help for localization. :)
-- https://wow.curseforge.com/projects/tooltiprealminfo/localization

if LOCALE_deDE then
	--@localization(locale="deDE", format="lua_additive_table", handle-subnamespaces="none", handle-unlocalized="ignore")@
elseif LOCALE_esES then
	--@localization(locale="esES", format="lua_additive_table", handle-subnamespaces="none", handle-unlocalized="ignore")@
elseif LOCALE_esMX then
	--@localization(locale="esMX", format="lua_additive_table", handle-subnamespaces="none", handle-unlocalized="ignore")@
elseif LOCALE_frFR then
	--@localization(locale="frFR", format="lua_additive_table", handle-subnamespaces="none", handle-unlocalized="ignore")@
elseif LOCALE_itIT then
	--@localization(locale="itIT", format="lua_additive_table", handle-subnamespaces="none", handle-unlocalized="ignore")@
elseif LOCALE_koKR then
	--@localization(locale="koKR", format="lua_additive_table", handle-subnamespaces="none", handle-unlocalized="ignore")@
elseif LOCALE_ptBR then
	--@localization(locale="ptBR", format="lua_additive_table", handle-subnamespaces="none", handle-unlocalized="ignore")@
elseif LOCALE_ruRU then
	--@localization(locale="ruRU", format="lua_additive_table", handle-subnamespaces="none", handle-unlocalized="ignore")@
elseif LOCALE_zhCN then
	--@localization(locale="zhCN", format="lua_additive_table", handle-subnamespaces="none", handle-unlocalized="ignore")@
elseif LOCALE_zhTW then
	--@localization(locale="zhTW", format="lua_additive_table", handle-subnamespaces="none", handle-unlocalized="ignore")@
end

L["connectedrealms"] = L["Connected realms"];

ns.print=function(...)
	local colors,t,c = {"0099ff","00ff00","ff6060","44ffff","ffff00","ff8800","ff44ff","ffffff"},{},1;
	for i,v in ipairs({...}) do
		v = tostring(v);
		if i==1 and v~="" then
			tinsert(t,"|cff0099ff"..addon.."|r:"); c=2;
		end
		if not v:match("||c") then
			v,c = "|cff"..colors[c]..v.."|r", c<#colors and c+1 or 1;
		end
		tinsert(t,v);
	end
	print(unpack(t));
end

function ns.debug(...)
	if GetAddOnMetadata(addon,"Version")=="@".."project-version".."@" then
		ns.print("debug",...);
	end
end

local function GetRealmInfo(realm)
	if not realm or (type(realm)=="string" and realm:len()==0) then
		realm = myRealm;
	end
	if replaceRealmNames[realm] then
		realm = replaceRealmNames[realm];
	end

	if not LRI:GetCurrentRegion() then
		region = ({"US","KR","EU","TW","CN"})[GetCurrentRegion()]; -- i'm not sure but sometimes LibRealmInfo aren't able to detect region
	end

	local id, name, api_name, rules, locale, battlegroup, region, timezone, connections, latin_name, latin_api_name = LRI:GetRealmInfo(realm,region);

	if not id then
		return;
	end

	-- add icon
	local iconfile = media..locale;
	local iconstr = "|T"..iconfile..":0:2|t";

	-- replace ptPT because LFG_LIST_LANGUAGE_PTPT is missing...
	if locale == "ptPT" then
		locale = "ptBR";
	end

	-- modify rules
	if rules == "RP" then
		rules = "RP PvE";
	elseif rules == "RPPVP" then
		rules = "RP PvP";
	else
		rules = gsub(rules,"V","v");
	end

	-- modify timezones
	if not timezone then
		if region=="EU" then
			if locale=="enGB" or locale=="ptPT" then
				timezone = 0 + DST;
			elseif locale=="ruRU" then
				timezone = 3;
			else
				timezone = 1 + DST;
			end
		else
			timezone = ((region=="CN" or region=="TW") and 8 or 9);
		end
	else
		timezone = Code2UTC[timezone] + DST;
	end

	if not timezone then
		timezone = "Unknown";
	else
		timezone = "UTC" .. (timezone<0 and "-" or "+") .. timezone;
	end

	return id, name, api_name, rules, locale, battlegroup, region, timezone, connections, latin_name, latin_api_name;
end

local function AddLines(tt,realm,_title)
	if not _title then
		_title = "%s: ";
	end

	if realm[iconstr] and TooltipRealmInfoDB.countryflag=="charactername" then
		local ttName = tt:GetName();
		if ttName then
			_G[ttName.."TextLeft1"]:SetText(_G[ttName.."TextLeft1"]:GetText().." "..realm[iconstr]);
		end
	end

	for i,v in ipairs(tooltipLines)do
		if TooltipRealmInfoDB[v[1]] then
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
				if realm[v[2]] and #realm[v[2]]>0 then
					for i=1,#realm[v[2]] do
						local _, realm_name = LRI:GetRealmInfoByID(realm[v[2]][i],region);
						if realm_name == myRealm then
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
						v = "|cff"..color..v.."|r";
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
						tt:AddLine(table.concat(flat,", "),1,1,1,1);
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
					tt:AddDoubleLine(title,"|cffffffff"..text.."|r");
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

GameTooltip:HookScript("OnTooltipSetUnit",function(self,...)
	local name, unit, guid, realm = self:GetUnit();
	if not unit then
		local mf = GetMouseFocus();
		if mf and mf.unit then
			unit = mf.unit;
		end
	end
	if unit and UnitIsPlayer(unit) then
		guid = UnitGUID(unit);
		if tostring(guid):match("^Player%-") then
			local _, _, _, _, _, _, _realm = GetPlayerInfoByGUID(guid);
			realm = {GetRealmInfo(_realm)};
		end

		if realm and #realm>0 then
			AddLines(self,realm);
		end
	end
end);

hooksecurefunc(GameTooltip,"SetText",function(self,name)
	if locked then return end
	local owner, owner_name = self:GetOwner();
	if owner then
		owner_name = owner:GetName();
		if not owner_name then
			owner_name = owner:GetDebugName();
		end
	end
	-- GroupFinder > ApplicantViewer > Tooltip
	if owner_name and owner_name:find("^LFGListApplicationViewerScrollFrameButton") then
		local charName, realmName = strsplit("-",name);
		local realm = {GetRealmInfo(realm)};
		if realm and #realm>0 then
			AddLines(self,realm);
		end
	end
end);

hooksecurefunc(GameTooltip,"AddLine",function(self,line_str)
	if locked then return end
	local owner, owner_name = self:GetOwner();
	if owner then
		owner_name = owner:GetName();
		if not owner_name then
			owner_name = owner:GetDebugName();
		end
	end
	-- GroupFinder > SearchResult > Tooltip
	if owner_name and owner_name:find("^LFGListSearchPanelScrollFrameButton") then
		local leaderName = line_str:match(_LFG_LIST_TOOLTIP_LEADER);
		if leaderName then
			local charName, realmName = strsplit("-",leaderName);
			local realm = {GetRealmInfo(realm)};
			if realm and #realm>0 then
				AddLines(self,realm);
			end
		end
	end
end);

-- Friend list tooltip
hooksecurefunc("FriendsFrameTooltip_SetLine",function(line, anchor, text, yOffset)
	if locked then return end
	if yOffset == -4 and text:find(_FRIENDS_LIST_REALM) then
		local realmName = text:match(_FRIENDS_LIST_REALM);
		if realmName then
			local realm = {GetRealmInfo(realm)};
			if realm and #realm>0 then
				FriendsTooltip.height = FriendsTooltip.height - line:GetHeight(); -- remove prev. added line height
				locked=true;
				FriendsFrameTooltip_SetLine(line, anchor, AddLines(text,realm,NORMAL_FONT_COLOR_CODE.."%s:|r "), yOffset);
				locked=false;
			end
		end
	end
end);

-- Groupfinder applicants
hooksecurefunc("LFGListApplicationViewer_UpdateApplicantMember", function(member, id, index)
	if not TooltipRealmInfoDB.finder_counryflag then return end
	local name,_,_,_,_,_,_,_,_,_,relationship = C_LFGList.GetApplicantMemberInfo(id, index);
	local charName, realmName = strsplit("-",name);
	if realmName then
		local realm = {GetRealmInfo(realm)};
		if realm and #realm>0 then
			member.Name:SetText(realm[iconstr]..member.Name:GetText());
		end
	end
end);

local options = {
	type = "group",
	name = addon,
	args = {
		tooltip = {
			type = "group", order = 1,
			name = L["Tooltip"],
			inline = true,
			args = {
				battlegroup = {
					type = "toggle", order = 1,
					name = L["Realm battlegroup"],
					get = function() return TooltipRealmInfoDB.battlegroup; end,
					set = function(_,v) TooltipRealmInfoDB.battlegroup = v; end
				},
				timezone = {
					type = "toggle", order = 2,
					name = L["Realm timezone"],
					get = function() return TooltipRealmInfoDB.timezone; end,
					set = function(_,v) TooltipRealmInfoDB.timezone = v; end
				},
				type = {
					type = "toggle", order = 3,
					name = L["Realm type"],
					get = function() return TooltipRealmInfoDB.type; end,
					set = function(_,v) TooltipRealmInfoDB.type = v; end
				},
				language = {
					type = "toggle", order = 4,
					name = L["Realm language"],
					get = function() return TooltipRealmInfoDB.language; end,
					set = function(_,v) TooltipRealmInfoDB.language = v; end
				},
				connectedrealms = {
					type = "toggle", order = 5,
					name = L["Connected realms"],
					get = function() return TooltipRealmInfoDB.connectedrealms; end,
					set = function(_,v) TooltipRealmInfoDB.connectedrealms = v; end
				},
				countryflag = {
					type = "select", order = 6, width = "double",
					name = L["Country flag"],
					desc = L["Display the country flag without text on the left side in tooltip"],
					values = {
						languageline = L["Behind language in line 'Realm language'"],
						charactername = L["Behind the character name"].." ("..L["Currently doesn't work with TipTac"]..")",
						ownline = L["In own tooltip line on the left site"],
						none = ADDON_DISABLED
					},
					get = function() return TooltipRealmInfoDB.countryflag; end,
					set = function(_,v) TooltipRealmInfoDB.countryflag = v; end
				}
			}
		},
		groupfinder = {
			type = "group", order = 2,
			name = LFGLIST_NAME,
			inline = true,
			args = {
				countryflag = {
					type = "toggle",
					name = L["Country flag"],
					desc = L["Prepend country flag on character name"],
					get = function() return TooltipRealmInfoDB.finder_counryflag; end,
					set = function(_,v) TooltipRealmInfoDB.finder_counryflag = v; end
				}
			}
		}
	}
};

local function RegisterOptionPanel()
	LibStub("AceConfig-3.0"):RegisterOptionsTable(addon, options);
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addon);
end

frame:SetScript("OnEvent",function(self,event,name)
	if event=="ADDON_LOADED" and addon==name then
		if TooltipRealmInfoDB==nil then
			TooltipRealmInfoDB = {};
		end
		for k,v in pairs(dbDefaults)do
			if TooltipRealmInfoDB[k]==nil then
				TooltipRealmInfoDB[k]=v;
			end
		end
		if TooltipRealmInfoDB.rules~=nil then
			TooltipRealmInfoDB.type = TooltipRealmInfoDB.rules;
			TooltipRealmInfoDB.rules = nil;
		end
		if TooltipRealmInfoDB.locale~=nil then
			TooltipRealmInfoDB.language = TooltipRealmInfoDB.locale;
			TooltipRealmInfoDB.locale = nil;
		end
		RegisterOptionPanel();
		if TooltipRealmInfoDB.loadedmessage then
			ns.print(L["AddOn loaded..."],"","\n",L["For options use /ttri or /tooltiprealminfo"]);
		end
	elseif event=="PLAYER_LOGIN" then
		local t = date("*t");
		DST = t.isdst and 1 or 0;
	end
end);
frame:RegisterEvent("ADDON_LOADED");
frame:RegisterEvent("PLAYER_LOGIN");

SlashCmdList["TOOLTIPREALMINFO"] = function(cmd)
	local _print = function(key)
		ns.print( (TooltipRealmInfoDB[key] and L["Tooltip line '%s' is now shown"] or L["Tooltip line '%s' is now hidden"]):format(L[key]) )
	end
	local cmd, arg = strsplit(" ", cmd, 2);
	cmd = cmd:lower();

	if cmd=="battlegroup" or cmd=="timezone" or cmd=="type" or cmd=="language" or cmd=="connectedrealms" then
		TooltipRealmInfoDB[cmd] = not TooltipRealmInfoDB[cmd];
		_print(cmd);
	elseif cmd=="loadedmessage" then
		TooltipRealmInfoDB.loadedmessage = not TooltipRealmInfoDB.loadedmessage;
		ns.print(L["'AddOn loaded...' message:"],TooltipRealmInfoDB.loadedmessage and VIDEO_OPTIONS_ENABLED or VIDEO_OPTIONS_DISABLED);
	elseif cmd=="id" then
		ns.print(LRI:GetRealmInfoByID(tonumber(arg)))
	elseif cmd=="config" then
		InterfaceOptionsFrame_OpenToCategory(addon);
		InterfaceOptionsFrame_OpenToCategory(addon);
	else
		ns.print(L["Chat command list for /ttri or /tooltiprealminfo"]);
		for i,v in ipairs({"battlegroup","timezone","language","type","connectedrealms"})do
			ns.print("", v, "|cffffff00-", (TooltipRealmInfoDB[v] and L["Hide %s in tooltip"] or L["Show %s in tooltip"]):format(L[v]));
		end
		ns.print("","loadedmessage","|cffffff00-",L["Toggle 'AddOn loaded...' message"]);
		ns.print("","config","|cffffff00-",L["Open option panel"]);
	end
end

SLASH_TOOLTIPREALMINFO1 = "/tooltiprealminfo";
SLASH_TOOLTIPREALMINFO2 = "/ttri";

