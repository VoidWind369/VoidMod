local totemWeapon = {
    -- 漩涡武器法术ID
    totemWeapon_spell_id = 344179,

    -- 显示设置
    max_stacks = 10,
    dot_size = 36, -- 每个小圆点的大小
    dot_spacing = 1, -- 圆点间距
    position_x = 0,
    position_y = -260,

    currentStacks = 0,
    lastStacks = 0,
}

function VoidFrame:CreateDotProgress()
    local bar_width = (totemWeapon.dot_size + totemWeapon.dot_spacing) * totemWeapon.max_stacks
    local bar_height = totemWeapon.dot_size + 10

    -- 主框架
    self.dotFrame = CreateFrame("Frame", nil, UIParent)
    self.dotFrame:SetSize(bar_width, bar_height)
    self.dotFrame:SetPoint("CENTER", totemWeapon.position_x, totemWeapon.position_y)
    self.dotFrame:SetFrameStrata("HIGH")

    -- 背景条
    self.dotFrame.background = self.dotFrame:CreateTexture(nil, "BACKGROUND")
    self.dotFrame.background:SetSize(bar_width + totemWeapon.dot_spacing, bar_height + totemWeapon.dot_spacing)
    self.dotFrame.background:SetPoint("CENTER")
    self.dotFrame.background:SetColorTexture(0, 0, 0, 0.3)
    self.dotFrame.background:SetTexture(130937)
    self.dotFrame.background:SetGradient("VERTICAL",
            CreateColor(0, 0, 0, 0.15),
            CreateColor(0.2, 0.2, 0.2, 0.2)
    )

    -- 创建10个小圆点
    self.dots = {}

    for i = 1, totemWeapon.max_stacks do
        local dot = CreateFrame("Frame", nil, self.dotFrame)
        dot:SetSize(totemWeapon.dot_size, totemWeapon.dot_size)
        dot:SetPoint("LEFT", (i - 1) * (totemWeapon.dot_size + totemWeapon.dot_spacing) + (totemWeapon.dot_spacing / 2), 0)

        -- 发光效果
        dot.glow = dot:CreateTexture(nil, "BACKGROUND")
        dot.glow:SetSize(totemWeapon.dot_size, totemWeapon.dot_size)
        dot.glow:SetAlpha(0.2)
        dot.glow:SetPoint("CENTER")
        dot.glow:SetBlendMode("ADD")
        dot.glow:Hide()

        -- 小圆点纹理 - 使用白色纹理然后通过渐变上色
        dot.tex = dot:CreateTexture(nil, "OVERLAY")
        dot.tex:SetSize(totemWeapon.dot_size, totemWeapon.dot_size)
        dot.tex:SetPoint("CENTER")

        -- 关键：使用白色方形纹理，渐变会覆盖颜色
        --dot.tex:SetTexture("Interface\\Buttons\\WHITE8x8")
        --dot.glow:SetTexture("Interface\\Buttons\\WHITE8x8")

        dot.tex:SetTexture(518448)
        dot.glow:SetTexture(518448)

        -- 初始状态
        dot.tex:SetGradient("VERTICAL",
                CreateColor(0.5, 0.5, 0.5, 1),
                CreateColor(0.2, 0.2, 0.2, 1)
        )
        dot:SetAlpha(0.3)

        self.dots[i] = dot
    end

    -- 不是增强初始隐藏
    local specID = GetSpecializationInfo(GetSpecialization())
    if not specID == 263 then
        self.dotFrame:Hide()
    end
end

function VoidFrame:UpdateDotProgress(stacks)
    local alpha = 1
    for i = 1, totemWeapon.max_stacks do
        local dot = self.dots[i]

        if i <= stacks then
            -- 激活的小圆点 - 饱满的纵向渐变
            local topColor, bottomColor = self:GetGradientColors(i, alpha)
            dot.tex:SetGradient("VERTICAL", topColor, bottomColor)

            -- 发光效果
            dot.glow:SetGradient("VERTICAL", topColor, bottomColor)
            dot.glow:Show()
            dot:SetAlpha(1)
        else
            -- 未激活的小圆点 - 深灰色渐变
            dot.tex:SetGradient("VERTICAL",
                    CreateColor(0.5, 0.5, 0.5, alpha),
                    CreateColor(0.2, 0.2, 0.2, alpha)
            )
            dot.glow:Hide()
            dot:SetAlpha(0.3)
        end
    end
end

function VoidFrame:GetGradientColors(dotIndex, alpha)
    -- 饱满的金属渐变色
    if dotIndex <= 4 then
        -- 蓝色金属
        return CreateColor(0.8, 0.9, 1.0, alpha), CreateColor(0.2, 0.4, 0.9, alpha)
    elseif dotIndex <= 7 then
        -- 金色金属
        return CreateColor(1.0, 1.0, 0.7, alpha), CreateColor(0.8, 0.6, 0.2, alpha)
    elseif dotIndex <= 9 then
        -- 橙色金属
        return CreateColor(1.0, 0.8, 0.7, alpha), CreateColor(1.0, 0.5, 0.1, alpha)
    else
        -- 红色金属
        return CreateColor(1.0, 0.4, 0.4, alpha), CreateColor(1.0, 0.0, 0.0, alpha)
    end
end

function VoidFrame:UpdateTotemWeaponStacks()
    local auraData = C_UnitAuras.GetUnitAuraBySpellID("player", totemWeapon.totemWeapon_spell_id)

    if auraData then
        totemWeapon.currentStacks = auraData.applications or 0
        -- 显示框架
        self.dotFrame:Show()
    else
        -- 没有buff时隐藏
        totemWeapon.currentStacks = 0
        totemWeapon.lastStacks = 0
        local specID = GetSpecializationInfo(GetSpecialization())
        if not specID == 263 then
            self.dotFrame:Hide()
        end
    end
    -- 更新小圆点进度
    self:UpdateDotProgress(totemWeapon.currentStacks)
end

function VoidFrame:TestDisplay()
    -- 测试显示不同层数
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00测试小圆点进度...|r")

    -- 循环测试不同层数
    local testIndex = 1
    C_Timer.NewTicker(0.3, function()
        self:UpdateDotProgress(testIndex)
        self.dotFrame:Show()
        testIndex = testIndex + 1
        if testIndex > 10 then
            testIndex = 1
        end
    end, 10) -- 测试10秒

    C_Timer.After(10.5, function()
        if totemWeapon.currentStacks == 0 then
            self.dotFrame:Hide()
        else
            self:UpdateDotProgress(totemWeapon.currentStacks)
        end
    end)
end

function VoidFrame:ToggleMoveMode()
    if self.dotFrame:IsMovable() then
        self.dotFrame:EnableMouse(false)
        self.dotFrame:SetMovable(false)
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00移动模式已关闭|r")
    else
        self.dotFrame:EnableMouse(true)
        self.dotFrame:SetMovable(true)
        self.dotFrame:RegisterForDrag("LeftButton")
        self.dotFrame:SetScript("OnDragStart", function(self)
            self:StartMoving()
        end)
        self.dotFrame:SetScript("OnDragStop", function(self)
            self:StopMovingOrSizing()
            SavePosition()
        end)
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00移动模式已开启 - 拖动框架移动位置|r")
    end
end

function VoidFrame:ResetPosition()
    self.dotFrame:ClearAllPoints()
    self.dotFrame:SetPoint("CENTER", totemWeapon.position_x, totemWeapon.position_y)
    self.dotFrame:SetScale(1)
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00位置和大小已重置|r")
end

function VoidFrame:ToggleScale()
    local currentScale = self.dotFrame:GetScale()
    if currentScale == 1 then
        self.dotFrame:SetScale(1.3)
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00放大模式|r")
    elseif currentScale == 1.3 then
        self.dotFrame:SetScale(0.8)
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00缩小模式|r")
    else
        self.dotFrame:SetScale(1)
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00正常大小|r")
    end
end

-- 保存配置
local function SavePosition()
    if VoidFrame.dotFrame then
        local point, relativeTo, relativePoint, xOfs, yOfs = VoidFrame.dotFrame:GetPoint()
        TOTEM_WEAPON_MONITOR_POSITION = {
            point = point,
            x = xOfs,
            y = yOfs,
            scale = VoidFrame.dotFrame:GetScale()
        }
    end
end

-- 加载保存的位置
local function LoadPosition()
    if TOTEM_WEAPON_MONITOR_POSITION then
        VoidFrame.dotFrame:ClearAllPoints()
        VoidFrame.dotFrame:SetPoint(
                TOTEM_WEAPON_MONITOR_POSITION.point or "CENTER",
                UIParent,
                TOTEM_WEAPON_MONITOR_POSITION.point or "CENTER",
                TOTEM_WEAPON_MONITOR_POSITION.x or totemWeapon.position_x,
                TOTEM_WEAPON_MONITOR_POSITION.y or totemWeapon.position_y
        )
        VoidFrame.dotFrame:SetScale(TOTEM_WEAPON_MONITOR_POSITION.scale or 1)
    end
end

-- 在显示框架创建后加载位置
C_Timer.After(1, LoadPosition)