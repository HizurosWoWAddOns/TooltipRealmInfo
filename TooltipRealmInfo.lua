
TooltipRealmInfoDB = {};
local addon, ns = ...;
local L = ns.L;
local C = WrapTextInColorCode;

-- very nice addon from Phanx :) Thanks...
local LRI = LibStub("LibRealmInfo");

local frame, media = CreateFrame("frame"), "Interface\\AddOns\\"..addon.."\\media\\";
local _FRIENDS_LIST_REALM, _LFG_LIST_TOOLTIP_LEADER = FRIENDS_LIST_REALM.."|r(.+)", gsub(LFG_LIST_TOOLTIP_LEADER,"%%s","(.+)");
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
	ttFriends=true
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

function ns.print(...)
	local colors,t,c = {"0099ff","00ff00","ff6060","44ffff","ffff00","ff8800","ff44ff","ffffff"},{},1;
	for i,v in ipairs({...}) do
		v = tostring(v);
		if i==1 and v~="" then
			tinsert(t,C(addon,"ff"..colors[1])..":"); c=2;
		end
		if not v:match("||c") then
			v,c = C(v,"ff"..colors[c]), c<#colors and c+1 or 1;
		end
		tinsert(t,v);
	end
	print(unpack(t));
end

local debugMode = "@project-version@"=="@".."project-version".."@";
function ns.debug(...)
	if debugMode then
		ns.print("debug",...);
	end
end

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
				realm = r~="" and r or myRealm;
			end
		end
	end

	if #res==0 then
		if not realm and object:find("%-") and not object:find("^Player%-") then
			_,realm = strsplit("-",object,2); -- character name + realm
		end

		if not realm then
			realm = myRealm[2];
		end

		if not LRI:GetCurrentRegion() then
			regionFix = ({"US","KR","EU","TW","CN"})[GetCurrentRegion()];
		end

		if type(realm)=="string" and realm:len()>0 then
			res = {LRI:GetRealmInfo(realm,regionFix)};

			if #res==0 and replaceRealmNames[realm] then
				res = {LRI:GetRealmInfo(replaceRealmNames[realm],regionFix)};
			end
		end
	end

	if #res==0 then
		return;
	end

	-- replace ptPT because LFG_LIST_LANGUAGE_PTPT is missing...
	if not LFG_LIST_LANGUAGE_PTPT and res[locale]=="ptPT" then
		res[locale] = "ptBR";
	end

	-- modify language codes
	if res[region]=="EU" and res[locale]=="enUS" then
		res[locale]="enGB"
	elseif res[region]=="US" and res[timezone]=="AEST" then
		res[locale]="enAU" -- australian
	end

	-- add icon
	res[iconfile] = media..res[locale];
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
GameTooltip:HookScript("OnTooltipSetUnit",function(self,...)
	if not TooltipRealmInfoDB.ttPlayer then return end
	local name, unit, guid, realm = self:GetUnit();
	if not unit then
		local mf = GetMouseFocus();
		if mf and mf.unit then
			unit = mf.unit;
		end
	end
	if unit and UnitIsPlayer(unit) then
		guid = UnitGUID(unit);
		name = UnitName(unit);
		if guid then
			AddLines(self,guid or name);
		end
	end
end);

hooksecurefunc(GameTooltip,"SetText",function(self,name)
	if locked or (not TooltipRealmInfoDB.ttGrpFinder) then return end
	local owner, owner_name = self:GetOwner();
	if owner then
		owner_name = owner:GetName();
		if not owner_name then
			owner_name = owner:GetDebugName();
		end
	end
	-- GroupFinder > ApplicantViewer > Tooltip
	if owner_name and owner_name:find("^LFGListApplicationViewerScrollFrameButton") then
		AddLines(self,name);
	end
end);

hooksecurefunc(GameTooltip,"AddLine",function(self,text)
	if locked or (not TooltipRealmInfoDB.ttGrpFinder) then return end
	local owner, owner_name = self:GetOwner();
	if owner then
		owner_name = owner:GetName();
		if not owner_name then
			owner_name = owner:GetDebugName();
		end
	end
	if owner_name then
		if owner_name:find("^LFGListSearchPanelScrollFrameButton") then -- GroupFinder > SearchResult > Tooltip
			local leaderName = text:match(_LFG_LIST_TOOLTIP_LEADER);
			if leaderName then
				AddLines(self,leaderName);
			end
		elseif owner_name:find("^CommunitiesFrameScrollChild") and owner.memberInfo then -- Community member list tooltips
			if text==owner.memberInfo.name then
				GameTooltip:ClearAllPoints();
				GameTooltip:SetPoint("RIGHT",owner,"LEFT",0,0);
				AddLines(self,owner.memberInfo.name,nil,true)
			end
		end
	end
end);

-- Friend list tooltip
hooksecurefunc("FriendsFrameTooltip_SetLine",function(line, anchor, text, yOffset)
	if locked or (not TooltipRealmInfoDB.ttFriends) then return end
	if yOffset == -4 and text:find(_FRIENDS_LIST_REALM) then
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

-- Communities members - add country flags
local function CommunitiesMemberList_RefreshListDisplay_Hook(self)
	if not TooltipRealmInfoDB.communities_countryflag then return end
	local scrollFrame = self.ListScrollFrame;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	for i = 1, #buttons do
		if buttons[i].memberInfo and buttons[i].memberInfo.name and buttons[i].memberInfo.clubType==1 then
			local realm = GetRealmInfo(buttons[i].memberInfo.name);
			if realm and #realm>0 then
				buttons[i].NameFrame.Name:SetText(realm[iconstr]..buttons[i].memberInfo.name);
				buttons[i]:UpdatePresence();
				buttons[i]:UpdateNameFrame();
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
					type = "toggle", order = 2,
					name = L["RlmTZ"]
				},
				type = {
					type = "toggle", order = 3,
					name = L["RlmType"]
				},
				language = {
					type = "toggle", order = 4,
					name = L["RlmLang"]
				},
				connectedrealms = {
					type = "toggle", order = 5,
					name = L["RlmConn"]
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
					type = "toggle",
					name = LFGLIST_NAME,
					desc = L["CtryFlgGrpFndrDesc"]
				},
				communities_countryflag = {
					type = "toggle",
					name = COMMUNITIES,
					desc = L["CtryFlgCommDesc"]
				}
			}
		}
	}
};

local function RegisterOptionPanel()
	LibStub("AceConfig-3.0"):RegisterOptionsTable(addon, options);
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addon);
end

function RegisterSlashCommand()
	function SlashCmdList.TOOLTIPREALMINFO(cmd)
		local _print = function(key)
			ns.print( L[ TooltipRealmInfoDB[key] and "CmdNowIsShown" or "CmdNowIsHidden"]:format(L[key]) );
		end
		local cmd, arg = strsplit(" ", cmd, 2);
		cmd = cmd:lower();

		if cmd=="timezone" or cmd=="type" or cmd=="language" or cmd=="connectedrealms" then
			TooltipRealmInfoDB[cmd] = not TooltipRealmInfoDB[cmd];
			_print(cmd);
		elseif cmd=="loadedmessage" then
			TooltipRealmInfoDB.loadedmessage = not TooltipRealmInfoDB.loadedmessage;
			ns.print(L["CmdLoadedMsg"],TooltipRealmInfoDB.loadedmessage and VIDEO_OPTIONS_ENABLED or VIDEO_OPTIONS_DISABLED);
		elseif cmd=="config" then
			InterfaceOptionsFrame_OpenToCategory(addon);
			InterfaceOptionsFrame_OpenToCategory(addon);
		else
			ns.print(L["CmdListInfo"]);
			for i,v in ipairs({"timezone","language","type","connectedrealms"})do
				ns.print("", v, "|cffffff00-", L[TooltipRealmInfoDB[v] and "CmdListOptHide" or "CmdListOptShow"]:format(L[v]));
			end
			ns.print("","loadedmessage","|cffffff00-",L["CmdListLoadedMsg"]);
			ns.print("","config","|cffffff00-",L["CmdListOptions"]);
		end
	end

	SLASH_TOOLTIPREALMINFO1 = L["CmdSlashStringLong"];
	SLASH_TOOLTIPREALMINFO2 = L["CmdSlashStringShort"];
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
		RegisterOptionPanel();
		RegisterSlashCommand();
		if TooltipRealmInfoDB.loadedmessage then
			ns.print(L["AddOnLoaded"],"","\n",L["CmdOnLoadInfo"]);
		end
	elseif event=="ADDON_LOADED" and "Blizzard_Communities"==name then
		hooksecurefunc(CommunitiesFrame.MemberList,"RefreshListDisplay",CommunitiesMemberList_RefreshListDisplay_Hook);
	elseif event=="PLAYER_LOGIN" then
		local t = date("*t");
		DST = t.isdst and 1 or 0;
	end
end);
frame:RegisterEvent("ADDON_LOADED");
frame:RegisterEvent("PLAYER_LOGIN");
