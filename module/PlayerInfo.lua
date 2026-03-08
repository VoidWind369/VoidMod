local point = {
    player_up = {
        p = "BOTTOMLEFT",
        x = 430.0,
        y = 130.0
    },
    player_down = {
        p = "BOTTOMLEFT",
        x = 430.0,
        y = 10.0
    }
}

function VoidFrame:Void_PlayerInfo()
    local specID, name, description, icon, role, primaryStat = GetSpecializationInfo(GetSpecialization())
    -- 主属性
    local attribute = UnitStat("player", primaryStat or 3)

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

    local currentSpeed, runSpeed, flightSpeed, swimSpeed = GetUnitSpeed("player")
    local speedPercent = (currentSpeed / 7) * 100 -- 7是基础奔跑速度
    --local power = UnitPower("player", Enum.PowerType.Mana)

    -- 副属性
    local crit = GetCritChance()
    local haste = GetHaste()
    local mastery = GetMasteryEffect()
    local versatility = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE)
    local first = string.format("|cFFFFFF00生命：%d\n%s：%d\n护甲：%d\n移速：%.2f%%|r", health, primaryStatName, attribute, armor,
        speedPercent)
    local info = string.format("|cFF00FF00暴击：%6.2f%%\n急速：%6.2f%%\n精通：%6.2f%%\n全能：%6.2f%%|r", crit, haste, mastery,
        versatility)
    return first, info
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

--- # 显示文字通用属性
function AddString(fontString, string)
    fontString:SetPoint("LEFT", 13.5, 0)
    fontString:SetText(string)
    fontString:SetTextScale(1.2)
    -- fontString:SetShadowColor(1.0, 1.0, 1.0, 0.5)
    fontString:SetSpacing(1.5)
    fontString:SetJustifyH("LEFT")
end

--- # 创建主属性框体
function VoidFrame:Void_CreatePlayerInfoDisplay_UP(first)
    VoidModCharacterDB.point.player_up = VoidModCharacterDB.point.player_up or {
        p = point.player_up.p,
        x = point.player_up.x,
        y = point.player_up.y
    }

    self.voidPlayerInfo_UP = CreateFrame("Frame", "PlayerInfo_UP", UIParent, "BackdropTemplate")
    self.voidPlayerInfo_UP:SetSize(170, 100)
    self.voidPlayerInfo_UP:SetPoint(VoidModCharacterDB.point.player_up.p, VoidModCharacterDB.point.player_up.x,
        VoidModCharacterDB.point.player_up.y)
    SetPlayerInfoFrameStyle(self.voidPlayerInfo_UP)

    self.voidPlayerInfoText_UP = self.voidPlayerInfo_UP:CreateFontString(nil, "OVERLAY", "GameFontNormal")

    AddString(self.voidPlayerInfoText_UP, first)
end

--- # 创建副属性框体
function VoidFrame:Void_CreatePlayerInfoDisplay_Down(info)
    VoidModCharacterDB.point.player_down = VoidModCharacterDB.point.player_down or {
        p = point.player_down.p,
        x = point.player_down.x,
        y = point.player_down.y
    }
    self.voidPlayerInfo_DOWN = CreateFrame("Frame", "PlayerInfo_DOWN", UIParent, "BackdropTemplate")
    self.voidPlayerInfo_DOWN:SetSize(170, 100)
    self.voidPlayerInfo_DOWN:SetPoint(VoidModCharacterDB.point.player_down.p, VoidModCharacterDB.point.player_down.x,
        VoidModCharacterDB.point.player_down.y)
    SetPlayerInfoFrameStyle(self.voidPlayerInfo_DOWN)

    self.voidPlayerInfoText_DOWN = self.voidPlayerInfo_DOWN:CreateFontString(nil, "OVERLAY", "GameFontNormal")

    AddString(self.voidPlayerInfoText_DOWN, info)
end

--- # 创建玩家信息框体
function VoidFrame:Void_CreatePlayerInfoDisplay()
    VoidModCharacterDB.point = VoidModCharacterDB.point or point

    local first, info = VoidFrame:Void_PlayerInfo()
    self:Void_CreatePlayerInfoDisplay_UP(first)
    self:Void_CreatePlayerInfoDisplay_Down(info)

    MovableDisplay(self.voidPlayerInfo_UP)
    MovableDisplay(self.voidPlayerInfo_DOWN)

    MovableFrameStop(self.voidPlayerInfo_UP, VoidModCharacterDB.point.player_up, point.player_up)
    MovableFrameStop(self.voidPlayerInfo_DOWN, VoidModCharacterDB.point.player_down, point.player_down)
end

--- # 刷新玩家信息框体
function VoidFrame:Void_UpdatePlayerInfoDisplay()
    local first, info = VoidFrame:Void_PlayerInfo()
    self.voidPlayerInfoText_UP:SetText(first)
    self.voidPlayerInfoText_DOWN:SetText(info)
end
