function VoidFrame:Void_PlayerInfo()
    local specID, name, description, icon, role, primaryStat = GetSpecializationInfo(GetSpecialization())
    -- 主属性
    local attribute = UnitStat("player", primaryStat or 0)

    local primaryStatName = "主属性"
    if primaryStat == 1 then
        primaryStatName = "力量"
    elseif primaryStat == 2 then
        primaryStatName = "敏捷"
    elseif primaryStat == 4 then
        primaryStatName = "智力"
    end

    local health = UnitHealth("player")
    local base, effectiveArmor, armor, bonusArmor = UnitArmor("player")

    local baseSpeed, currentSpeed, playerSpeedMod = GetUnitSpeed("player")
    local speedPercent = (currentSpeed / 7) * 100  -- 7是基础奔跑速度
    --local power = UnitPower("player", Enum.PowerType.Mana)

    -- 副属性
    local crit = GetCritChance()
    local haste = GetHaste()
    local mastery = GetMasteryEffect()
    local versatility = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE)
    local first = string.format("|cFFFFFF00生命：%d\n%s：%d\n护甲：%d\n移速：%.2f%%|r", health, primaryStatName, attribute, armor, speedPercent)
    local info = string.format("|cFF00FF00暴击：%6.2f%%\n急速：%6.2f%%\n精通：%6.2f%%\n全能：%6.2f%%|r", crit, haste, mastery, versatility)
    return first, info
end

function VoidFrame:Void_CreatePlayerInfoDisplay()
    local first, info = VoidFrame:Void_PlayerInfo()
    self:Void_CreatePlayerInfoDisplay_UP(first)
    self:Void_CreatePlayerInfoDisplay_Down(info)
end

function VoidFrame:Void_CreatePlayerInfoDisplay_UP(first)
    self.voidPlayerInfo_UP = CreateFrame("Frame", "PlayerInfo_UP", UIParent, "BackdropTemplate")
    self.voidPlayerInfo_UP:SetSize(170, 100)
    self.voidPlayerInfo_UP:SetPoint("CENTER", -456, -365)
    SetPlayerInfoFrameStyle(self.voidPlayerInfo_UP)

    self.voidPlayerInfoText_UP = self.voidPlayerInfo_UP:CreateFontString(nil, "OVERLAY", "GameFontNormal")

    AddString(self.voidPlayerInfoText_UP, first)
end

function VoidFrame:Void_CreatePlayerInfoDisplay_Down(info)
    self.voidPlayerInfo_DOWN = CreateFrame("Frame", "PlayerInfo_DOWN", UIParent, "BackdropTemplate")
    self.voidPlayerInfo_DOWN:SetSize(170, 100)
    self.voidPlayerInfo_DOWN:SetPoint("CENTER", -456, -470)
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