
local _, ns = ...;

local L = setmetatable({},{
	__index=function(t,k)
		local v=tostring(k);
		rawset(t,k,v);
		return v;
	end
});

-- Hi. This addon needs your help for localization. :)
-- https://wow.curseforge.com/projects/tooltiprealminfo/localization

-- english localization
--@do-not-package@
L["AddOnLoaded"] = "AddOn loaded..."
L["Tooltip"] = "Tooltip"

-- tooltip line header and option names
L["RlmConn"] = "Connected realms"
L["RlmLang"] = "Realm language"
L["RlmPvPGrp"] = "Realm battlegroup"
L["RlmType"] = "Realm type"
L["RlmTZ"] = "Realm timezone"
L["CtryFlg"] = "Country flag"
L["CtryFlgDesc"] = "Display the country flag without text on the left side in tooltip"
L["CtryFlgSelLang"] = "Behind language in line 'Realm language'"
L["CtryFlgSelName"] = "Behind the character name"
L["CtryFlgSelOwn"] = "In own tooltip line on the left site"
L["CtryFlgTipTacInfo"] = "(Currently doesn't work with TipTac)"
L["CtryFlgGrpFndrDesc"] = "Prepend country flag on character name"

-- slash command strings
L["CmdOnLoadInfo"] = "For options use /ttri or /tooltiprealminfo"
L["CmdNowIsShown"] = "Tooltip line '%s' is now shown"
L["CmdNowIsHidden"] = "Tooltip line '%s' is now hidden"
L["CmdLoadedMsg"] = "'AddOn loaded...' message:"
L["CmdListInfo"] = "Chat command list for /ttri or /tooltiprealminfo";
L["CmdListOptShow"] = "Show %s in tooltip"
L["CmdListOptHide"] = "Hide %s in tooltip"
L["CmdListOptions"] = "Open option panel"
L["CmdListLoadedMsg"] = "Toggle 'AddOn loaded...' message"
L["CmdSlashStringLong"] = "/tooltiprealminfo"
L["CmdSlashStringShort"] = "/ttri"
--@end-do-not-package@
--@localization(locale="enUS", format="lua_additive_table", handle-subnamespaces="none", handle-unlocalized="ignore")@
-- /end of english localization

if LOCALE_deDE then
--@do-not-package@
	L["AddOnLoaded"] = "Addon geladen..."
	L["battlegroup"] = "Schlachtgruppe"
	L["CmdListInfo"] = "Chatbefehlsliste für /ttri oder /tooltiprealminfo"
	L["CmdListLoadedMsg"] = "Die Nachricht \"Addon geladen\" ein-/ausschalten"
	L["CmdListOptHide"] = "%s im Tooltip verstecken"
	L["CmdListOptions"] = "Öffne Optionpanel"
	L["CmdListOptShow"] = "%s im Tooltip zeigen"
	L["CmdLoadedMsg"] = "'Addon geladen...' Nachricht:"
	L["CmdNowIsHidden"] = "Tooltipzeile '%s' wird jetzt versteckt"
	L["CmdNowIsShown"] = "Tooltipzeile '%s' wird jetzt gezeigt"
	L["CmdOnLoadInfo"] = "Gib /ttri oder /tooltiprealminfo ein, um zu den Optionen zu gelangen"
	L["CmdSlashStringLong"] = "/tootiprealminfo"
	L["CmdSlashStringShort"] = "/ttri"
	L["CtryFlg"] = "Landesflagge"
	L["CtryFlgDesc"] = "Zeige Landesflagge ohne Text auf der rechten Seite im Tooltip"
	L["CtryFlgGrpFndrDesc"] = "Die Landesflagge dem Charakternamen voranstellen"
	L["CtryFlgSelLang"] = "Hinter der Sprache in der Zeile 'Realmsprache'"
	L["CtryFlgSelName"] = "Hinter dem Charakternamen"
	L["CtryFlgSelOwn"] = "In eigener Tooltipzeile auf der rechten Seite"
	L["CtryFlgTipTacInfo"] = "(Funktioniert zurzeit nicht mit TipTac)"
	L["RlmConn"] = "Verbundene Realms"
	L["RlmLang"] = "Realmsprache"
	L["RlmPvPGrp"] = "Realm Schlachtgruppe"
	L["RlmType"] = "Realmtyp"
	L["RlmTZ"] = "Realmzeitzone"
	L["timezone"] = "Zeitzone"
	L["Tooltip"] = "Tooltip"
--@end-do-not-package@
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
elseif LOCALE_ptBR or LOCALE_ptPT then
--@localization(locale="ptBR", format="lua_additive_table", handle-subnamespaces="none", handle-unlocalized="ignore")@
elseif LOCALE_ruRU then
--@localization(locale="ruRU", format="lua_additive_table", handle-subnamespaces="none", handle-unlocalized="ignore")@
elseif LOCALE_zhCN then
--@localization(locale="zhCN", format="lua_additive_table", handle-subnamespaces="none", handle-unlocalized="ignore")@
elseif LOCALE_zhTW then
--@localization(locale="zhTW", format="lua_additive_table", handle-subnamespaces="none", handle-unlocalized="ignore")@
end

L["type"]=TYPE;
L["language"]=LANGUAGE;
L["connectedrealms"] = L["Connected realms"];
