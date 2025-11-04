local boneShield = {
    BloodDeathKnight_SpecId = 250,

    -- 骨盾法术ID
    spell_id = 195181,

    -- 显示设置
    max_stacks = 12,
    dot_size = 20, -- 每个小圆点的大小
    dot_spacing = 1, -- 圆点间距
    position_x = 0,
    position_y = -260,

    currentStacks = 0,
    lastStacks = 0,
}

function VoidFrame:CreateBoneShieldDotProgress()
    -- 主框架
    self.dotFrame = CreateFrame("Frame", "BoneShield", UIParent, "BackdropTemplate")
    WhiteTransparentFrame(self.dotFrame, boneShield)

    -- 创建10个小圆点
    self.boneShieldDots = {}

    for i = 1, boneShield.max_stacks do
        local boneShieldDot = CreateFrame("Frame", nil, self.dotFrame)
        WhiteTransparentDot(i, boneShieldDot, boneShield)

        boneShieldDot.glow = boneShieldDot:CreateTexture(nil, "BACKGROUND")
        WhiteTransparentDotGlow(boneShieldDot.glow, boneShield)

        boneShieldDot.tex = boneShieldDot:CreateTexture(nil, "OVERLAY")
        WhiteTransparentDotTex(boneShieldDot.tex, boneShield)

        self.boneShieldDots[i] = boneShieldDot
    end

    -- 不是血dk初始隐藏
    if GetSpecializationInfo(GetSpecialization()) ~= boneShield.BloodDeathKnight_SpecId then
        self.dotFrame:Hide()
    end
end

-- 设定骨盾层数颜色
function VoidFrame:UpdateDeathKnightDotProgress(stacks)
    local alpha = 1
    for i = 1, boneShield.max_stacks do
        local dot = self.boneShieldDots[i]

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
    local boneShieldData = C_UnitAuras.GetUnitAuraBySpellID("player", boneShield.spell_id)

    if GetSpecializationInfo(GetSpecialization()) == boneShield.BloodDeathKnight_SpecId then
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