
TooltipRealmInfoDB = {};
local addon, ns = ...;
local L = ns.L;

-- very nice addon from Phanx :) Thanks...
local LRI = LibStub("LibRealmInfo");

local frame, media = CreateFrame("frame"), "Interface\\AddOns\\"..addon.."\\media\\";
local _LFG_LIST_TOOLTIP_LEADER = gsub(LFG_LIST_TOOLTIP_LEADER,"%%s","(.+)");
local _FRIENDS_LIST_REALM = FRIENDS_LIST_REALM.."|r(.+)";
local id, name, api_name, rules, locale, battlegroup, region, timezone, connections, latin_name, latin_api_name, icon = 1,2,3,4,5,6,7,8,9,10,11,12;
local Code2UTC = {EST=-5,CST=-6,MST=-7,PST=-8,AEST=10};
local DST = 0;
local dbDefaults = {
	battlegroup = false,
	timezone = false,
	rules = true,
	locale = true
};
local L = setmetatable({},{__index=function(t,k) local v=tostring(k);rawset(t,k,v);return v;end});

L["locale"] = LANGUAGE;

if LOCALE_deDE then
	-- L["battlegroup"]
	-- L["timezone"]
	-- L["rules"]
	-- L["Show"]
	-- L["Hide"]
	-- L["Chat command list for /ttri or /tooltiprealminfo"]
	-- L["%s in tooltip"]
	-- L["tooltip line '%s' set on '%s'"]
	-- L["For options use /ttri or /tooltiprealminfo"]
	-- L["AddOn loaded..."]
end

ns.print=function(...)
	local colors,t,c = {"0099ff","00ff00","ff6060","44ffff","ffff00","ff8800","ff44ff","ffffff"},{},1;
	local strings = {...};
	if strings[1]~="" then
		tinsert(strings,1,addon..":");
	end
	for i,v in ipairs(strings) do
		if type(v)=="string" and v:match("||c") then
			tinsert(t,v);
		else
			tinsert(t,"|cff"..colors[c]..tostring(v).."|r");
			c = c<#colors and c+1 or 1;
		end
	end
	print(unpack(t));
end

local function realm_fix(str)
	if str:find("%(") then
		str = gsub(str,"("," ("); -- problem with Aggra(
	end
	return str;
end

local function data_update(id, name, api_name, rules, locale, battlegroup, region, timezone, connections, latin_name, latin_api_name, icon)
	if not id then return end

	-- add icon
	icon = "|T"..media..locale..":0:2|t";

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

	return id, name, api_name, rules, locale, battlegroup, region, timezone, connections, latin_name, latin_api_name, icon;
end

local function AddLines(tt,realm)
	for i,v in ipairs({ {"locale",locale}, {"rules",rules}, {"timezone",timezone}, {"battlegroup",battlegroup} })do
		if TooltipRealmInfoDB[v[1]] then
			local title,text = ("%s %s: "):format(L["Realm"],L[v[1]]),"";
			if v[1]=="locale" then
				local lCode = realm[v[2]]:upper();
				if _G["LFG_LIST_LANGUAGE_"..lCode]~=nil or _G[lCode]~=nil then
					text = text .. (_G["LFG_LIST_LANGUAGE_"..lCode] or _G[lCode]);
					if realm[icon] then
						text = text .. realm[icon];
					end
				else
					text = text .. realm[v[2]].."?";
				end
			elseif v[2] and realm[v[2]] then
				text = text .. realm[v[2]];
			else 
				print(v[2]);
			end
			if type(tt)=="string" then
				tt = tt.."|n"..title..text;
			else
				tt:AddLine(title.."|cffffffff"..text.."|r");
			end
		end
	end
end

GameTooltip:HookScript("OnTooltipSetUnit",function(self,...)
	local name, unit = self:GetUnit(); 
	if not unit then
		mf = GetMouseFocus();
		if mf then unit = mf.unit end
	end
	if unit and UnitIsPlayer(unit) then
		local realm = {data_update(LRI:GetRealmInfoByUnit(unit))};
		if #realm>0 then
			AddLines(self,realm);
		end
	end
end);

hooksecurefunc(GameTooltip,"AddLine",function(self,line_str)
	local owner, owner_name = GameTooltip:GetOwner();
	if owner then
		owner_name = owner:GetName();
	end
	-- GroupFinder > SearchResult > Tooltip
	if owner_name and owner_name:find("^LFGListSearchPanelScrollFrameButton") then
		local leaderName = line_str:match(_LFG_LIST_TOOLTIP_LEADER);
		if leaderName then
			local charName, realmName = strsplit("-",leaderName);
			local realm = {data_update(LRI:GetRealmInfo(realm_fix(realmName)))};
			if #realm>0 then
				AddLines(self,realm);
			end
		end
	end
end);

-- Friend list tooltip
hooksecurefunc("FriendsFrameTooltip_SetLine",function(line, anchor, text, yOffset)
	if yOffset == -4 then
		local realmName = text:match(_FRIENDS_LIST_REALM);
		if realmName then
			local realm = {data_update(LRI:GetRealmInfo(realm_fix(realmName)))};
			if #realm>0 then
				FriendsTooltip.height = FriendsTooltip.height - line:GetHeight(); -- remove prev. added line height
				AddLines(text,realm);
				FriendsFrameTooltip_SetLine(line, anchor, text, yOffset);
			end
		end
	end
end);

frame:SetScript("OnEvent",function(self,event)
	local t = date("*t");
	DST = t.isdst and 1 or 0;
	if TooltipRealmInfoDB==nil then
		TooltipRealmInfoDB = {};
	end
	for k,v in pairs(dbDefaults)do
		if TooltipRealmInfoDB[k]==nil then
			TooltipRealmInfoDB[k]=v;
		end
	end
	ns.print(L["AddOn loaded..."],"","\n",L["For options use /ttri or /tooltiprealminfo"]);
	self:UnregisterEvent(event);
end);
frame:RegisterEvent("PLAYER_ENTERING_WORLD");

SlashCmdList["TOOLTIPREALMINFO"] = function(cmd)
	local _print = function(key) ns.print(L["tooltip line '%s' set on '%s'"]:format(L[key],TooltipRealmInfoDB[key] and L["Show"] or L["Hide"])) end
	local cmd, arg = strsplit(" ", cmd, 2)
	cmd = cmd:lower()
	
	if cmd=="battlegroup" or cmd=="timezone" or cmd=="rules" or cmd=="locale" then
		TooltipRealmInfoDB[cmd] = not TooltipRealmInfoDB[cmd];
		_print(cmd);
	else
		ns.print(L["Chat command list for /ttri or /tooltiprealminfo"]);
		for i,v in ipairs({"battlegroup","timezone","rules","locale"})do
			ns.print("", v, "-", (TooltipRealmInfoDB[v] and L["Hide"] or L["Show"]) .." ".. L["%s in tooltip"]:format(L[v]));
		end
	end
end

SLASH_TOOLTIPREALMINFO1 = "/tooltiprealminfo"
SLASH_TOOLTIPREALMINFO2 = "/ttri"
