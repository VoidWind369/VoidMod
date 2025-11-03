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
        SendChatMessage(self:Void_PlayerInfo(), "WHISPER", nil, playerName)
    end
end

function VoidFrame:PartyStart(name, isTank, isHealer, isDamage, isNativeRealm, allowMultipleRoles, inviterGUID, questSessionActive)
    AcceptGroup()
    StaticPopup_Hide("PARTY_INVITE")
    print("被|cFA500FF0" .. name .. "|r邀请进组")
end

function VoidFrame:Void_PlayerInfo()
    -- 主属性
    local attribute = math.max(UnitStat("player", 1), UnitStat("player", 2), UnitStat("player", 4))

    local health = UnitHealth("player")
    local base, effectiveArmor, armor, bonusArmor = UnitArmor("player")
    --local power = UnitPower("player", Enum.PowerType.Mana)

    -- 副属性
    local crit = GetCritChance()
    local haste = GetHaste()
    local mastery = GetMasteryEffect()
    local versatility = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE)
    local first = string.format("|cFFFFFF00生命值：%d\n主属性：%d\n护甲值：%d|r", health, attribute, armor)
    local info = string.format("|cFF00FF00暴击：%6.2f%%\n急速：%6.2f%%\n精通：%6.2f%%\n全能：%6.2f%%|r", crit, haste, mastery, versatility)
    return first, info
end

function VoidFrame:Void_CreatePlayerInfoDisplay()
    local first, info = VoidFrame:Void_PlayerInfo()
    --self.voidPlayerInfo = CreateFrame("Frame", "PlayerInfo", UIParent, "BackdropTemplate")
    --self.voidPlayerInfo:SetPoint("CENTER", 0, 0)
    --
    --self.voidPlayerInfo:SetSize(200, 110)
    --self.voidPlayerInfo:SetPoint("CENTER", -456, -361)
    --SetPlayerInfoFrameStyle(self.voidPlayerInfo)
    --
    --self.voidPlayerInfoText = self.voidPlayerInfo:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    --
    --AddString(self.voidPlayerInfoText, first)
    self:Void_CreatePlayerInfoDisplay_UP(first)
    self:Void_CreatePlayerInfoDisplay_Down(info)
end

function VoidFrame:Void_CreatePlayerInfoDisplay_UP(first)
    self.voidPlayerInfo_UP = CreateFrame("Frame", "PlayerInfo_UP", UIParent, "BackdropTemplate")
    self.voidPlayerInfo_UP:SetSize(170, 90)
    self.voidPlayerInfo_UP:SetPoint("CENTER", -456, -361)
    SetPlayerInfoFrameStyle(self.voidPlayerInfo_UP)

    self.voidPlayerInfoText_UP = self.voidPlayerInfo_UP:CreateFontString(nil, "OVERLAY", "GameFontNormal")

    AddString(self.voidPlayerInfoText_UP, first)
end

function VoidFrame:Void_CreatePlayerInfoDisplay_Down(info)
    self.voidPlayerInfo_DOWN = CreateFrame("Frame", "PlayerInfo_DOWN", UIParent, "BackdropTemplate")
    self.voidPlayerInfo_DOWN:SetSize(170, 110)
    self.voidPlayerInfo_DOWN:SetPoint("CENTER", -456, -465)
    SetPlayerInfoFrameStyle(self.voidPlayerInfo_DOWN)

    self.voidPlayerInfoText_DOWN = self.voidPlayerInfo_DOWN:CreateFontString(nil, "OVERLAY", "GameFontNormal")

    AddString(self.voidPlayerInfoText_DOWN, info)
end

function SetPlayerInfoFrameStyle(frame)
    frame:SetFrameStrata("HIGH")
    frame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 6, right = 6, top = 6, bottom = 6 },
    })
    frame:SetBackdropColor(0, 0, 0, 0.15)
    frame:SetBackdropBorderColor(0.2, 0.2, 0.2, 0.5)
end

function AddString(fontString, string)
    fontString:SetPoint("LEFT", 13.5, 0)
    fontString:SetText(string)
    fontString:SetTextScale(1.2)
    fontString:SetShadowColor(1.0, 1.0, 1.0, 0.5)
    fontString:SetSpacing(1.5)
    fontString:SetJustifyH("LEFT")
end

function VoidFrame:Void_UpdatePlayerInfoDisplay()
    local first, info = VoidFrame:Void_PlayerInfo()
    self.voidPlayerInfoText_UP:SetText(first)
    self.voidPlayerInfoText_DOWN:SetText(info)
end