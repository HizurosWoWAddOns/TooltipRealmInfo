
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

L["type"]=TYPE;
L["language"]=LANGUAGE;
-- L["timezone"]
-- L["battlegroup"]

--@localization(locale="enUS", format="lua_additive_table", handle-subnamespaces="none", handle-unlocalized="ignore")@

if LOCALE_deDE then
	--@do-not-package@
	L["AddOn loaded..."] = "Addon geladen..."
	L["'AddOn loaded...' message:"] = "'Addon geladen...' Nachricht:"
	L["battlegroup"] = "Schlachtgruppe"
	L["Behind language in line 'Realm language'"] = "Hinter der Sprache in der Zeile Realmsprache"
	L["Behind the character name"] = "Hinter dem Charakternamen"
	L["Chat command list for /ttri or /tooltiprealminfo"] = "Chatbefehlsliste für /ttri oder /tooltiprealminfo"
	L["Connected realms"] = "Verbundene Realms"
	L["Country flag"] = "Landesflagge"
	L["Currently doesn't work with TipTac"] = "Funktioniert zurzeit nicht mit TipTac"
	L["Display the country flag without text on the left side in tooltip"] = "Zeige Landesflagge ohne Text auf der rechten Seite im Tooltip"
	L["For options use /ttri or /tooltiprealminfo"] = "Gib /ttri oder /tooltiprealminfo ein, um zu den Optionen zu gelangen"
	L["Hide %s in tooltip"] = "%s im Tooltip verstecken"
	L["In own tooltip line on the left site"] = "In eigener Tooltipzeile auf der rechten Seite"
	L["Open option panel"] = "Öffne Optionpanel"
	L["Prepend country flag on character name"] = "Die Landesflagge dem Charakternamen voranstellen"
	L["Realm battlegroup"] = "Realm Schlachtgruppe"
	L["Realm language"] = "Realmsprache"
	L["Realm timezone"] = "Realmzeitzone"
	L["Realm type"] = "Realmtyp"
	L["Show %s in tooltip"] = "%s im Tooltip zeigen"
	L["timezone"] = "Zeitzone"
	L["Toggle 'AddOn loaded...' message"] = "Die Nachricht \"Addon geladen\" ein-/ausschalten"
	L["Tooltip"] = "Tooltip"
	L["Tooltip line '%s' is now hidden"] = "Tooltipzeile '%s' wird jetzt versteckt"
	L["Tooltip line '%s' is now shown"] = "Tooltipzeile '%s' wird jetzt gezeigt"
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
