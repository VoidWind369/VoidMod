function VoidFrame:MessageStart(text, playerName, languageName, channelName)
    print(channelName .. "|cFA500FF0" .. playerName .. "|r say: " .. text)
    if text == "123" then
        C_PartyInfo.InviteUnit(playerName)
    elseif text == "团队" then
        C_PartyInfo.ConfirmConvertToRaid()
    elseif text == "小队" then
        C_PartyInfo.ConvertToParty()
    elseif string.find(text, "倒数") then
        local num_str = string.gsub(text, "倒数", "")
        local num = tonumber(strtrim(num_str)) or 10
        print("|cFFFF0000开始倒计时|r", num, "|cFFFF0000秒|r")
        C_PartyInfo.DoCountdown(num)
    elseif text == "属性" then
        self:Void_PlayerInfo()
    end
end

function VoidFrame:PartyStart(name, isTank, isHealer, isDamage, isNativeRealm, allowMultipleRoles, inviterGUID, questSessionActive)
    AcceptGroup()
    StaticPopup_Hide("PARTY_INVITE")
    print("被|cFA500FF0" .. name .. "|r邀请进组")
end

function VoidFrame:Void_PlayerInfo()
    -- 主属性
    local health = UnitHealth("player")
    local power = UnitPower("player", Enum.PowerType.Mana)

    -- 副属性
    local crit = GetCritChance()
    local haste = GetHaste()
    local mastery = GetMasteryEffect()
    local versatility = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE)
    local first = string.format("|cFCF00FF0基础属性|r\n|cFFFFFF00生命：%d\n法力：%d|r", health, power)
    local info = string.format("|cFCF00FF0强化属性|r\n|cFF00FF00暴击：%6.2f%%\n急速：%6.2f%%\n精通：%6.2f%%\n全能：%6.2f%%|r", crit, haste, mastery, versatility)
    return string.format("%s\n%s", first, info)
end

function VoidFrame:Void_CreatePlayerInfoDisplay()
    self.voidPlayerInfoText = UIParent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.voidPlayerInfoText:SetPoint("CENTER", -470, -400)
    self.voidPlayerInfoText:SetText(VoidFrame:Void_PlayerInfo())
    self.voidPlayerInfoText:SetTextScale(1.2)
end

function VoidFrame:Void_UpdatePlayerInfoDisplay()
    self.voidPlayerInfoText:SetText(VoidFrame:Void_PlayerInfo())
end