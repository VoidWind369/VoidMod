local boneShield = {
    -- 骨盾法术ID
    boneShield_spell_id = 195181,

    -- 显示设置
    max_stacks = 12,
    dot_size = 20, -- 每个小圆点的大小
    dot_spacing = 1, -- 圆点间距
    position_x = 0,
    position_y = -260,

    currentStacks = 0,
    lastStacks = 0,
}

function VoidFrame:CreateBoneShieldDotProgress(max_stacks, specID)
    local bar_width = (boneShield.dot_size + boneShield.dot_spacing) * max_stacks
    local bar_height = boneShield.dot_size + 10

    -- 主框架
    self.dotFrame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    self.dotFrame:SetSize(bar_width + boneShield.dot_spacing + 12, bar_height + boneShield.dot_spacing)
    self.dotFrame:SetPoint("CENTER", boneShield.position_x, boneShield.position_y)
    self.dotFrame:SetFrameStrata("HIGH")
    self.dotFrame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 6, right = 6, top = 6, bottom = 6 },
    })
    self.dotFrame:SetBackdropColor(0, 0, 0, 0.15)
    self.dotFrame:SetBackdropBorderColor(0.2, 0.2, 0.2, 0.5)

    -- 背景条
    self.dotFrame.background = self.dotFrame:CreateTexture(nil, "BACKGROUND")
    self.dotFrame.background:SetSize(bar_width + boneShield.dot_spacing + 12, bar_height + boneShield.dot_spacing)
    self.dotFrame.background:SetPoint("CENTER")

    --self.dotFrame.background:SetColorTexture(0, 0, 0, 0.3)
    self.dotFrame.background:SetGradient("VERTICAL",
            CreateColor(0, 0, 0, 0.15),
            CreateColor(0.2, 0.2, 0.2, 0.2)
    )

    -- 创建10个小圆点
    self.dots = {}

    for i = 1, max_stacks do
        local dot = CreateFrame("Frame", nil, self.dotFrame)
        dot:SetSize(boneShield.dot_size, boneShield.dot_size)
        dot:SetPoint("LEFT", (i - 1) * (boneShield.dot_size + boneShield.dot_spacing) + (boneShield.dot_spacing / 2) + 6, 0)

        -- 发光效果
        dot.glow = dot:CreateTexture(nil, "BACKGROUND")
        dot.glow:SetSize(boneShield.dot_size, boneShield.dot_size)
        dot.glow:SetAlpha(0.2)
        dot.glow:SetPoint("CENTER")
        dot.glow:SetBlendMode("ADD")
        dot.glow:Hide()

        -- 小圆点纹理 - 使用白色纹理然后通过渐变上色
        dot.tex = dot:CreateTexture(nil, "OVERLAY")
        dot.tex:SetSize(boneShield.dot_size, boneShield.dot_size)
        dot.tex:SetPoint("CENTER")

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

    -- 不是血dk初始隐藏
    if GetSpecializationInfo(GetSpecialization()) ~= specID then
        self.dotFrame:Hide()
    end
end

-- 设定骨盾层数颜色
function VoidFrame:UpdateDeathKnightDotProgress(stacks)
    local alpha = 1
    for i = 1, boneShield.max_stacks do
        local dot = self.dots[i]

        if i <= stacks then
            -- 激活的小圆点 - 饱满的纵向渐变
            local topColor, bottomColor = self:GetDeathKnightGradientColors(i, alpha)
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

function VoidFrame:GetDeathKnightGradientColors(dotIndex, alpha)
    -- 饱满的金属渐变色
    if dotIndex <= 4 then
        -- 红色金属
        return CreateColor(1.0, 0.4, 0.4, alpha), CreateColor(1.0, 0.0, 0.0, alpha)
    elseif dotIndex <= 7 then
        -- 橙色金属
        return CreateColor(1.0, 0.8, 0.7, alpha), CreateColor(1.0, 0.5, 0.1, alpha)
    elseif dotIndex <= 9 then
        -- 金色金属
        return CreateColor(1.0, 1.0, 0.7, alpha), CreateColor(0.8, 0.6, 0.2, alpha)
    else
        -- 蓝色金属
        return CreateColor(0.8, 0.9, 1.0, alpha), CreateColor(0.2, 0.4, 0.9, alpha)
    end
end

function VoidFrame:UpdateDeathKnightBuff()
    local boneShieldData = C_UnitAuras.GetUnitAuraBySpellID("player", 195181)

    if GetSpecializationInfo(GetSpecialization()) == 250 then
        self.dotFrame:Show()
    else
        self.dotFrame:Hide()
    end

    if boneShieldData then
        boneShield.currentStacks = boneShieldData.applications or 0
    else
        boneShield.currentStacks = 0
        boneShield.lastStacks = 0
    end

    -- 更新小圆点进度
    self:UpdateDeathKnightDotProgress(boneShield.currentStacks)
end