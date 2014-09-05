--[[ 
    @Package       WhatIsUnique
    @Description   Adds a line to a tooltip when an item has a unique model.
    @Author        Robert "Fluxflashor" Veitch <Robert@Fluxflashor.net>
    @Repo          http://github.com/Fluxflashor/WhatIsUnique
    @File          Core.lua 
    ]]

local WHATISUNIQUE, WhatIsUnique = ...
local EventFrame = CreateFrame("FRAME", "WhatIsUnique_EventFrame")

local about = LibStub("tekKonfig-AboutPanel").new(nil, "WhatIsUnique")

WhatIsUnique.AddonName = WHATISUNIQUE
WhatIsUnique.Author = GetAddOnMetadata(WHATISUNIQUE, "Author")
WhatIsUnique.Version = GetAddOnMetadata(WHATISUNIQUE, "Version")

WhatIsUnique.TestMode = false
WhatIsUnique.TooltipCache = { }

function split(str, pat)
    local t = {}  -- NOTE: use {n = 0} in Lua-5.0
    local fpat = "(.-)" .. pat
    local last_end = 1
    local s, e, cap = str:find(fpat, 1)
    while s do
        if s ~= 1 or cap ~= "" then
            table.insert(t,cap)
        end
        last_end = e+1
        s, e, cap = str:find(fpat, last_end)
    end
    if last_end <= #str then
        cap = str:sub(last_end)
        table.insert(t, cap)
    end
    return t
end

function Set (list)
   local set = {}
   for _, l in ipairs(list) do set[l] = true end
   return set
end

WhatIsUnique.UniqueModelItemIds = Set { "109170", "109169", "113988", "113886", "113934", "113904", "113966", "113897", "119448", "113869", "113980", "113913", "113927", "113973", "113885", "113874", "113965", "113939", "113862", "113979", "113953", "111076", "115854", "115603", "113607", "113652", "113640", "113838", "113848", "113836", "113667", "113837", "113639", "113857", "113591", "109168", "110033", "110046", "110057", "110039", "119174", "110031", "116644", "116453", "116646", "116454", "118803", "113134", "111526", "113131", "117382", "119405", "120059", "115030", "120065", "115066", "117384", "119463", "119397", "118400", "116809", "118799", "114905", "118238", "118242", "118240", "118239", "118797", "118802", "118231", "107658", "44924", "79340", "79341", "79343", "89393", "89399", "95391", "89685", "115797", "86394", "79342", "79339", "88723", "86198", "77192", "78878", "72814", "72804", "72862", "72876", "72822", "72808", "72860", "72844", "72833", "72863", "72866", "72828", "72810", "72884", "69575", "67605", "59364", "59599", "52492", "87565", "66960", "89575", "50051", "50052", "47658", "48697", "48711", "48712", "50290", "50262", "50191", "50227", "50267", "88631", "88650", "40384", "40383", "40385", "40388", "40402", "40386", "40396", "40395", "49846", "49844", "46025", "49827", "49840", "49839", "46031", "40343", "40265", "40497", "40348", "40346", "40491", "40408", "40406", "40336", "40368", "40280", "40407", "39422", "40239", "40244", "40233", "39714", "45204", "45208", "45074", "40429", "37191", "44050", "44504", "40702", "45128", "45222", "45212", "39255", "37883", "45076", "44948", "44926", "41257", "43284", "37631", "37626", "36989", "37108", "44051", "34337", "34335", "37812", "34989", "34997", "35047", "34164", "34165", "34196", "34346", "34197", "34348", "34347", "37813", "30908", "32336", "30906", "30902", "32471", "30910", "32374", "34896", "34898", "34891", "34529", "34530", "33763", "89574", "30881", "32369", "30103", "32248", "30108", "32269", "32325", "32236", "30105", "32344", "32237", "29988", "30874", "29993", "29981", "30095", "30058", "29924", "30082", "53890", "33493", "28794", "28783", "28773", "28771", "28767", "30722", "87525", "87523", "28573", "28524", "28657", "28749", "28604", "28522", "28633", "28673", "27507", "29138", "27829", "28188", "28210", "27747", "27767", "27846", "28397", "27490", "27842", "28416", "28222", "27840", "27903", "28263", "27512", "27476", "28393", "28345", "28400", "25237", "31291", "28033", "27524", "27794", "27791", "27526", "27890", "27898", "30009", "31062", "23540", "32854", "29356", "29353", "29355", "29348", "29362", "29351", "118401", "118396", "118395", "118409", "118411", "118403", "118408", "118397", "118413", "118402", "118412", "118404", "118405", "118398", "118399", "29165", "115446", "23497", "89573", "24378", "22812", "22799", "24394", "22691", "21134", "22816", "22809", "23221", "22988", "19364", "19363", "21679", "22814", "21273", "21275", "21272", "21242", "21616", "77559", "77583", "21622", "21650", "19361", "19347", "18609", "18608", "19368", "19353", "19350", "19357", "19334", "18805", "19362", "19358", "38633", "38632", "21466", "17069", "21478", "18822", "21492", "21498", "19903", "19927", "19323", "17015", "15418", "20368", "65958", "89572", "17733", "9685", "809", "9380", "65977", "18388", "89571", "4110", "4111", "65973", "54935", "62179", "89570", "53280", "55904", "8226", "10049", "89566", "60924", "22995", "19970", "65465", "84661", "65474", "65477", "62880", "88535", "9602", "4763", "66876", "60952", "116826", "116825", "107849", "107850", "84660", "66170" }

function WhatIsUnique:MessageUser(message)
    DEFAULT_CHAT_FRAME:AddMessage(string.format("|cfffa8000WhatIsUnique|r: %s", message));
end


function WhatIsUnique:GetItemIDFromTooltip(tooltip)
    local _, link = tooltip:GetItem()
    return split(link, ':')[2]
end


function WhatIsUnique:RegisterEvents()

end

function WhatIsUniqueOnTooltipSetItem(tooltip, ...)
    local item_id = WhatIsUnique:GetItemIDFromTooltip(tooltip)
    if WhatIsUnique.UniqueModelItemIds[item_id] then
        tooltip:AddLine("|cfffa8000Unique Model!|r")
    end
    --tooltip:AddLine(item_id)
end

function WhatIsUnique:Initialize()
    EventFrame:RegisterEvent("ADDON_LOADED");
    EventFrame:SetScript("OnEvent", function(self, event, ...) WhatIsUnique:EventHandler(self, event, ...) end)
    GameTooltip:SetScript("OnTooltipSetItem", WhatIsUniqueOnTooltipSetItem);
end

function WhatIsUnique:EventHandler(self, event, ...)
    if (event == "ADDON_LOADED") then
        local LoadedAddonName = ...;
        if (WhatIsUnique.TestMode) then
            WhatIsUnique:MessageUser(string.format("LoadedAddonName is %s", LoadedAddonName));
        end
        if (LoadedAddonName == AddonName) then
            if (WhatIsUnique.Version == "@project-version@") then
                WhatIsUnique.Version = "Github Master";
            end
            if (WhatIsUnique.Author == "@project-author@") then
                WhatIsUnique.Author = "Fluxflashor (Github)";
            end
            WhatIsUnique:MessageUser(string.format("Loaded Version is %s. Author is %s.", WhatIsUnique.Version, WhatIsUnique.Author));
            if (WhatIsUnique.TestMode) then
                WhatIsUnique:MessageUser(string.format("%s is %s.", LoadedAddonName, AddonName));
            end
            if (WhatIsUnique.AddOnDisabled) then
                if (WhatIsUnique.TestMode) then
                    WhatIsUnique:MessageUser("Unregistering Events.");
                end
                if (not WhatIsUnique.SuppressWarnings) then
                    WhatIsUnique:WarnUser("WhatIsUnique is disabled.");
                end
                WhatIsUnique:Enable(false);
            end
        end
        WhatIsUnique:RegisterEvents();
    end
end

WhatIsUnique:Initialize()