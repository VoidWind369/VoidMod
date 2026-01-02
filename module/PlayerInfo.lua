local point = {
    up = {
        p = "BOTTOMLEFT",
        x = 430.0,
        y = 130.0
    },
    down = {
        p = "BOTTOMLEFT",
        x = 430.0,
        y = 10.0
    }
}

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
    fontString:SetShadowColor(1.0, 1.0, 1.0, 0.5)
    fontString:SetSpacing(1.5)
    fontString:SetJustifyH("LEFT")
end

--- # 创建主属性框体
function VoidFrame:Void_CreatePlayerInfoDisplay_UP(first)
    self.voidPlayerInfo_UP = CreateFrame("Frame", "PlayerInfo_UP", UIParent, "BackdropTemplate")
    self.voidPlayerInfo_UP:SetSize(170, 100)
    self.voidPlayerInfo_UP:SetPoint(VoidModCharacterDB.point.up.p, VoidModCharacterDB.point.up.x, VoidModCharacterDB.point.up.y)
    SetPlayerInfoFrameStyle(self.voidPlayerInfo_UP)

    self.voidPlayerInfoText_UP = self.voidPlayerInfo_UP:CreateFontString(nil, "OVERLAY", "GameFontNormal")

    AddString(self.voidPlayerInfoText_UP, first)
end

--- # 创建副属性框体
function VoidFrame:Void_CreatePlayerInfoDisplay_Down(info)
    VoidModCharacterDB.point.down = VoidModCharacterDB.point.down or point.down
    VoidModCharacterDB.point.down.p = VoidModCharacterDB.point.down.p or point.down.p
    VoidModCharacterDB.point.down.x = VoidModCharacterDB.point.down.x or point.down.x
    VoidModCharacterDB.point.down.y = VoidModCharacterDB.point.down.y or point.down.y
    self.voidPlayerInfo_DOWN = CreateFrame("Frame", "PlayerInfo_DOWN", UIParent, "BackdropTemplate")
    self.voidPlayerInfo_DOWN:SetSize(170, 100)
    self.voidPlayerInfo_DOWN:SetPoint(VoidModCharacterDB.point.down.p, VoidModCharacterDB.point.down.x, VoidModCharacterDB.point.down.y)
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

    MovableDisplayStop()
end

--- # 刷新玩家信息框体
function VoidFrame:Void_UpdatePlayerInfoDisplay()
    local first, info = VoidFrame:Void_PlayerInfo()
    self.voidPlayerInfoText_UP:SetText(first)
    self.voidPlayerInfoText_DOWN:SetText(info)
end

function MovableDisplayStop()
    -- 拖动停止
    VoidFrame.voidPlayerInfo_UP:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        self.isMoving = false
        local p, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
        VoidModCharacterDB.point.up.p = p -- 保存
        VoidModCharacterDB.point.up.x = xOfs -- 保存
        VoidModCharacterDB.point.up.y = yOfs -- 保存
    end)
    VoidFrame.voidPlayerInfo_DOWN:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        self.isMoving = false
        local p, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
        VoidModCharacterDB.point.down.p = p -- 保存
        VoidModCharacterDB.point.down.x = xOfs -- 保存
        VoidModCharacterDB.point.down.y = yOfs -- 保存
    end)

    -- 双击居中
    VoidFrame.voidPlayerInfo_UP:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" and self.doubleClick then
            self:ClearAllPoints()
            self:SetPoint(point.up.p, point.up.x, point.up.y)
            local p, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
            -- 保存到变量或保存文件
            VoidModCharacterDB.point.up.p = p -- 保存
            VoidModCharacterDB.point.up.x = xOfs -- 保存
            VoidModCharacterDB.point.up.y = yOfs -- 保存
            self.doubleClick = false
        end
    end)

    VoidFrame.voidPlayerInfo_DOWN:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" and self.doubleClick then
            self:ClearAllPoints()
            self:SetPoint(point.down.p, point.down.x, point.down.y)
            local p, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
            -- 保存到变量或保存文件
            VoidModCharacterDB.point.down.p = p -- 保存
            VoidModCharacterDB.point.down.x = xOfs -- 保存
            VoidModCharacterDB.point.down.y = yOfs -- 保存
            self.doubleClick = false
        end
    end)
end