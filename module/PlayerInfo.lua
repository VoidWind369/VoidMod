local point = {
    player_up = {
        p = "BOTTOMLEFT",
        x = 430.0,
        y = 145.0
    },
    player_down = {
        p = "BOTTOMLEFT",
        x = 430.0,
        y = 5.0
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

    -- 装等
    local avgItemLevel, avgItemLevelEquipped, avgItemLevelPvp = GetAverageItemLevel()

    local health = UnitHealthMax("player")
    local base, effectiveArmor, armor, bonusArmor = UnitArmor("player")

    local isGliding, canGlide, forwardSpeed = C_PlayerInfo.GetGlidingInfo()
    local currentSpeed = isGliding and forwardSpeed or GetUnitSpeed("player")
    local speedPercent = Round(currentSpeed / BASE_MOVEMENT_SPEED * 100)
    --local power = UnitPower("player", Enum.PowerType.Mana)

    -- 副属性
    local crit, crit_value = GetCritChance(), GetCombatRating(CR_CRIT_MELEE)
    local haste, haste_value = GetHaste(), GetCombatRating(CR_HASTE_MELEE)
    local mastery, mastery_value = GetMasteryEffect(), GetCombatRating(CR_MASTERY)
    local versatility, versatility_value = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE),
        GetCombatRating(CR_VERSATILITY_DAMAGE_DONE)

    VoidModCharacterDB.haste = haste

    -- 吸血 (Leech)
    local leech, leech_value = GetLifesteal(), GetCombatRating(CR_LIFESTEAL)
    -- 闪避 (Avoidance)
    local avoidance, avoidance_value = GetCombatRatingBonus(CR_AVOIDANCE),
        GetCombatRating(CR_AVOIDANCE)
    -- 加速 (Speed)
    local speed, speed_value = GetCombatRatingBonus(CR_SPEED), GetCombatRating(CR_SPEED)

    -- local a, b, c = GetCombatRating(CR_HASTE_MELEE), GetCombatRating(CR_HASTE_RANGED),
    --     GetCombatRating(CR_HASTE_SPELL)
    -- print("近战" .. a .. " 远程" .. b .. " 法术" .. c)

    local first_table = {
        name = {
            "|cFFFFFF00装等|r",
            "|cFFFFFF00生命|r",
            "|cFFFFFF00" .. primaryStatName .. "|r",
            "|cFFFFFF00护甲|r",
            "|cFFFFFF00移速|r",
        },
        value = {
            avgItemLevelEquipped == avgItemLevel and "|cFFFF69B4" .. avgItemLevel .. "|r" or
            string.format("|cFFFF69B4%.1f|r/%.1f", avgItemLevelEquipped, avgItemLevel),
            health,
            attribute,
            armor,
            string.format("%.2f%%", speedPercent),
        }
    }

    local last_table = {
        name = { "|cFF00FF00暴击|r", "|cFF00FF00急速|r", "|cFF00FF00精通|r", "|cFF00FF00全能|r", "|cFF228B22吸血|r", "|cFF228B22闪避|r", "|cFF228B22加速|r" },
        value = {
            string.format("%.2f%%  |cFFFF8C00%d|r", crit, crit_value),
            string.format("%.2f%%  |cFFFF8C00%d|r", haste, haste_value),
            string.format("%.2f%%  |cFFFF8C00%d|r", mastery, mastery_value),
            string.format("%.2f%%  |cFFFF8C00%d|r", versatility, versatility_value),
            string.format("%.2f%%  |cFFFF8C00%d|r", leech, leech_value),
            string.format("%.2f%%  |cFFFF8C00%d|r", avoidance, avoidance_value),
            string.format("%.2f%%  |cFFFF8C00%d|r", speed, speed_value),
        },
    }
    return first_table, last_table
end

function PrintCombatRating()
    for i = 1, 32, 1 do
        local key, value = GetCombatRatingBonus(i), GetCombatRating(i)
        print("属性", i, key, value)
    end
end

--- # 创建主属性框体
function VoidFrame:Void_CreatePlayerInfoDisplay_UP(first)
    VoidModCharacterDB.point.player_up = VoidModCharacterDB.point.player_up or {
        p = point.player_up.p,
        x = point.player_up.x,
        y = point.player_up.y
    }

    self.voidPlayerInfo_UP = CreateFrame("Frame", "PlayerInfo_UP", UIParent, "BackdropTemplate")
    self.voidPlayerInfo_UP:SetSize(170, 110)
    self.voidPlayerInfo_UP:SetPoint(VoidModCharacterDB.point.player_up.p, VoidModCharacterDB.point.player_up.x,
        VoidModCharacterDB.point.player_up.y)
    SetInfoFrameStyle(self.voidPlayerInfo_UP)

    -- self.voidPlayerInfoText_UP = self.voidPlayerInfo_UP:CreateFontString(nil, "OVERLAY", "GameFontNormal")

    -- AddString(self.voidPlayerInfoText_UP, first)
    self.voidPlayerInfoText_UP = {
        self.voidPlayerInfo_UP:CreateFontString(nil, "OVERLAY", "GameTooltipText"),
        self.voidPlayerInfo_UP:CreateFontString(nil, "OVERLAY", "GameTooltipText"),
    }
    AddStringLeft(self.voidPlayerInfoText_UP[1], table.concat(first.name, "\n"), 1.1)
    AddStringRight(self.voidPlayerInfoText_UP[2], table.concat(first.value, "\n"), 1.1)
end

--- # 创建副属性框体
function VoidFrame:Void_CreatePlayerInfoDisplay_Down(info)
    VoidModCharacterDB.point.player_down = VoidModCharacterDB.point.player_down or {
        p = point.player_down.p,
        x = point.player_down.x,
        y = point.player_down.y
    }
    self.voidPlayerInfo_DOWN = CreateFrame("Frame", "PlayerInfo_DOWN", UIParent, "BackdropTemplate")
    self.voidPlayerInfo_DOWN:SetSize(170, 135)
    self.voidPlayerInfo_DOWN:SetPoint(VoidModCharacterDB.point.player_down.p, VoidModCharacterDB.point.player_down.x,
        VoidModCharacterDB.point.player_down.y)
    SetInfoFrameStyle(self.voidPlayerInfo_DOWN)

    -- self.voidPlayerInfoText_DOWN = self.voidPlayerInfo_DOWN:CreateFontString(nil, "OVERLAY", "GameFontNormal")

    -- AddString(self.voidPlayerInfoText_DOWN, info)
    self.voidPlayerInfoText_DOWN = {
        self.voidPlayerInfo_DOWN:CreateFontString(nil, "OVERLAY", "GameTooltipText"),
        self.voidPlayerInfo_DOWN:CreateFontString(nil, "OVERLAY", "GameTooltipText"),
    }

    AddStringLeft(self.voidPlayerInfoText_DOWN[1], table.concat(info.name, "\n"))
    AddStringRight(self.voidPlayerInfoText_DOWN[2], table.concat(info.value, "\n"))
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
    if self.voidPlayerInfo_UP and self.voidPlayerInfo_DOWN then
        local first, info = VoidFrame:Void_PlayerInfo()
        self.voidPlayerInfoText_UP[1]:SetText(table.concat(first.name, "\n"))
        self.voidPlayerInfoText_UP[2]:SetText(table.concat(first.value, "\n"))
        self.voidPlayerInfoText_DOWN[1]:SetText(table.concat(info.name, "\n"))
        self.voidPlayerInfoText_DOWN[2]:SetText(table.concat(info.value, "\n"))
    end
end
