
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
local _SOCIAL_QUEUE_COMMUNITIES_HEADER_FORMAT = "(.*) %((.*)%)"; -- SOCIAL_QUEUE_COMMUNITIES_HEADER_FORMAT:gsub("%(","%%("):gsub("%)","%%)"):gsub("%%s","(.*)");
if LOCALE_zhTW then
	_SOCIAL_QUEUE_COMMUNITIES_HEADER_FORMAT = "(.*)%((.*)%)";
end
local id, name, api_name, rules, locale, battlegroup, region, timezone, connections, latin_name, latin_api_name, iconstr, iconfile = 1,2,3,4,5,6,7,8,9,10,11,12,13; -- LibRealmInfo:GetRealmInfo()
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

local myRealm = {GetRealmName(),nil};
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

local function GetRealmFromNameString(str)
	local _,realmName = strsplit("-",str,2);
	return (realmName and strlen(realmName)>0 and realmName) or myRealm[1];
end

local function GetRealmInfo(object)
	if not (type(object)=="string" and object:trim():len()>0) then
		return false;
	end

	local realmName,_ = object or "";
	if object:match("Player%-") then -- player guid string
		_, _, _, _, _, _, realmName = GetPlayerInfoByGUID(object);
	elseif object and strlen(object)>0 and object:match("%-") then -- name-realm string
		_,realmName = strsplit("-",object,2);
		if (realmName and strlen(realmName)==0) or realmName==nil then
			realmName = myRealm[1];
		end
	else
		realmName = object or myRealm[1];
	end

	--ns:debug("TTRI","<GetRealmInfo>",object,realmName)

	local realmInfo = {LRI:GetRealmInfo((realmName and strlen(realmName)>0 and realmName) or myRealm[1],regionFix)}

	if #realmInfo==0 then
		ns:debug("<GetRealmInfo>","<NoResultFor>",object,realmName);
		return;
	end

	-- modify locale
	if realmInfo[region]=="EU" then
		if realmInfo[locale]=="enUS" then
			realmInfo[locale] = "enGB"; -- Great Britain
		elseif realmInfo[locale]=="ptBR" then
			realmInfo[locale] = "ptPT"
		end
	end

	-- add icon
	if realmInfo[region]=="US" and realmInfo[timezone]=="AEST" then
		realmInfo[iconfile] = media.."enAU"; -- flag of australian
	else
		realmInfo[iconfile] = media..realmInfo[locale];
	end
	realmInfo[iconstr] = "|T"..realmInfo[iconfile]..":0:2|t";

	-- modify rules
	local rules_l = realmInfo[rules]:lower();
	if rules_l=="rp" or rules_l=="rppvp" then
		realmInfo[rules] = "RP PvE";
	elseif rules_l=="pvp" then
		realmInfo[rules] = "PvE";
	else
		realmInfo[rules] = gsub(realmInfo[rules],"V","v");
	end

	-- modify timezones
	if not realmInfo[timezone] then
		if realmInfo[region]=="EU" then
			if realmInfo[locale]=="enGB" or realmInfo[locale]=="ptPT" then
				realmInfo[timezone] = 0 + DST;
			elseif locale=="ruRU" then
				realmInfo[timezone] = 3; -- no DST
			else
				realmInfo[timezone] = 1 + DST;
			end
		elseif realmInfo[region]=="CN" or realmInfo[region]=="TW" then
			realmInfo[timezone] = 8;
		else
			realmInfo[timezone] = 9;
		end
	else
		realmInfo[timezone] = Code2UTC[realmInfo[timezone]] + DST;
	end

	if not realmInfo[timezone] then
		realmInfo[timezone] = "Unknown";
	else
		realmInfo[timezone] = "UTC" .. ( (realmInfo[timezone]==0 and " ") or (realmInfo[timezone]<0 and "-") or "+" ) .. realmInfo[timezone];
	end

	return realmInfo;
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

	local realmInfo = GetRealmInfo(object);

	if not (type(realmInfo)=="table" and #realmInfo>0) then
		return false;
	end

	if type(tt)~="string" and realmInfo[iconstr] and TooltipRealmInfoDB.countryflag=="charactername" then
		local ttName = tt:GetName();
		if ttName then
			_G[ttName.."TextLeft1"]:SetText(_G[ttName.."TextLeft1"]:GetText().." "..realmInfo[iconstr]);
		end
	end

	for i,v in ipairs(tooltipLines)do
		if CheckLineVisibility(v[1]) then
			local title,text = _title:format(L[v[3]]),"";
			if v[1]=="language" then
				local lCode = realmInfo[v[2]]:upper();
				if _G["LFG_LIST_LANGUAGE_"..lCode]~=nil or _G[lCode]~=nil then
					text = text .. (_G["LFG_LIST_LANGUAGE_"..lCode] or _G[lCode]);
					if realmInfo[iconstr] and TooltipRealmInfoDB.countryflag=="languageline" then
						text = text .. realmInfo[iconstr];
					end
				else
					text = text .. realmInfo[v[2]].."?";
				end
			elseif v[1]=="connectedrealms" then
				local names,color = {},"ffffff";
				if realmInfo[v[2]] and #realmInfo[v[2]]>1 then
					for i=1,#realmInfo[v[2]] do
						local _, realm_name = LRI:GetRealmInfoByID(realmInfo[v[2]][i],regionFix);
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
			elseif v[2] and realmInfo[v[2]] then
				text = text .. realmInfo[v[2]];
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

	if type(tt)~="string" and realmInfo[iconstr] and TooltipRealmInfoDB.countryflag=="ownline" then
		tt:AddLine(realmInfo[iconstr]);
	end

	return tt;
end

-- some gametooltip scripts/funcion hooks
local function _OnTooltipSetUnit(self)
	local _, unit, mf = self:GetUnit();
	if not unit then
		if GetMouseFoci then
			mf = GetMouseFoci()[1];
		else
			mf = GetMouseFocus();
		end
		if mf and mf.unit then
			unit = mf.unit;
		end
	end
	if unit and UnitIsPlayer(unit) then
		local _,realm = UnitName(unit)
		AddLines(self,realm or myRealm[1]); -- realm string
	end
end

if TooltipDataProcessor then
	local ttDone = nil;
	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function()
		if ttDone==true or not TooltipRealmInfoDB.ttPlayer then return end
		ttDone = true;
		_OnTooltipSetUnit(GameTooltip)
	end);

	GameTooltip:HookScript("OnTooltipCleared", function(self)
		ttDone = nil
	end)
else--if WOW_PROJECT_ID==WOW_PROJECT_CATACLYSM_CLASSIC or WOW_PROJECT_ID==WOW_PROJECT_CLASSIC then
	GameTooltip:HookScript("OnTooltipSetUnit",function(self,...)
		if not TooltipRealmInfoDB.ttPlayer then return end
		_OnTooltipSetUnit(self);
	end);
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
				local appName = C_LFGList.GetApplicantMemberInfo(button.applicantID, owner.memberIdx);
				AddLines(self,GetRealmFromNameString(appName)); -- name-realm string
			end
		elseif owner_name:find("^QuickJoinFrame%.ScrollBox%.ScrollTarget") then
			local toonName = name:match(_SOCIAL_QUEUE_COMMUNITIES_HEADER_FORMAT);
			if toonName then
				AddLines(self,GetRealmFromNameString(toonName)); -- name-realm string
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
				AddLines(self,GetRealmFromNameString(leaderName)); -- name-realm string
			end
		elseif owner_name:find("^CommunitiesFrame%.MemberList%.ScrollBox%.ScrollTarget") then
			-- Communities > MemberList > Tooltip
			if owner.memberInfo and owner.memberInfo.clubType~=0 and text==owner.memberInfo.name then
				-- Community member list tooltips
				AddLines(self,GetRealmFromNameString(owner.memberInfo.name),nil,true) -- name-realm string
			elseif owner.Info and owner.GetApplicantName and text==owner.Info.name then
				-- Community applicant list tooltip
				local _, _, _, _, _, _, realm = GetPlayerInfoByGUID(owner.Info.playerGUID);
				GameTooltip:AddDoubleLine(FRIENDS_LIST_REALM, C((realm and strlen(realm)>0 and realm) or GetRealmName(),"ffffffff"));
				AddLines(self,realm,nil,true); -- realm string
			end
		elseif owner_name:find("^QuickJoinFrame%.ScrollBox%.ScrollTarget") and owner.entry and owner.entry.guid then
			local leader = text:match(LFG_LIST_TOOLTIP_LEADER:gsub("%%s","(.*)"));
			if leader then
				AddLines(self,GetRealmFromNameString(leader)); -- name-realm string
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
		local ttLineStr,realmName = nil,text:match(_FRIENDS_LIST_REALM);
		if realmName then
			ttLineStr = AddLines(text,realmName,NORMAL_FONT_COLOR_CODE.."%s:|r "); -- realm string
		end
		if ttLineStr then
			FriendsTooltip.height = FriendsTooltip.height - line:GetHeight(); -- remove prev. added line height
			locked=true;
			FriendsFrameTooltip_SetLine(line, anchor, ttLineStr, yOffset);
			locked=false;
		end
	end
end);

-- Groupfinder applicants (only country flags in scroll frame)
if LFGListApplicationViewer_UpdateApplicantMember then
	hooksecurefunc("LFGListApplicationViewer_UpdateApplicantMember", function(member, id, index)
		if not TooltipRealmInfoDB.finder_counryflag then return end
		local name = C_LFGList.GetApplicantMemberInfo(id, index);
		if name then
			local realmInfo = GetRealmInfo(GetRealmFromNameString(name));
			if realmInfo and #realmInfo>0 then
				member.Name:SetText(realmInfo[iconstr]..member.Name:GetText());
			end
		end
	end);
end

-- premate groups
if LFGListSearchEntry_Update then
	hooksecurefunc("LFGListSearchEntry_Update",function(button)
		if not TooltipRealmInfoDB.finder_counryflag then return end
		local realmInfo,searchResultInfo = nil,C_LFGList.GetSearchResultInfo(button.resultID);
		if searchResultInfo and searchResultInfo.leaderName then
			realmInfo = GetRealmInfo(GetRealmFromNameString(searchResultInfo.leaderName));
		end
		if realmInfo and #realmInfo>0 then
			local cur = button.Name:GetText();
			if not cur:match(addon) then
				button.Name:SetText(realmInfo[iconstr]..cur)
			end
		end
	end)
end

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
			-- get realmInfo from player guid
			if args[guid] and args[guid]:find("^Player%-%d+") then
				local _, _, _, _, _, _, realmName = GetPlayerInfoByGUID(args[guid]);
				realmInfo = GetRealmInfo((realmName and strlen(realmName)>0 and realmName) or myRealm[1]);
			end
			-- add country flag to message
			if realmInfo and realmInfo[iconstr] and TooltipRealmInfoDB[realmInfo[locale].."_countryflag"] then
				args[msg] = realmInfo[iconstr].." "..args[msg];
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
				local realmInfo = GetRealmInfo(GetRealmFromNameString(buttons[i].memberInfo.name));
				if realmInfo and #realmInfo>0 then
					buttons[i].NameFrame.Name:SetText(realmInfo[iconstr]..buttons[i].memberInfo.name);
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
				local realmInfo = GetRealmInfo(GetRealmFromNameString(buttons[i].memberInfo.name));
				if realmInfo and #realmInfo>0 then
					buttons[i].NameFrame.Name:SetText(realmInfo[iconstr]..buttons[i].memberInfo.name);
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
					name = COMMUNITIES or L["Communities"], desc = L["CtryFlgCommDesc"]
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
			type = "group", order = 200, inline = true, hidden = true,
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
		local availableLanguages = C_LFGList.GetAvailableLanguageSearchFilter() or {};
		for i=1, #availableLanguages do
			local v = availableLanguages[i];
			if GetCurrentRegion()==3 then
				if v=="enUS" then
					v = "enGB";
				elseif v=="ptBR" then
					v = "ptPT";
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
