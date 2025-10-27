-- 创建主框架
local frame = CreateFrame("Frame", "TotemWeaponMonitorFrame", UIParent)
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("UNIT_AURA")

-- 漩涡武器法术ID
local TOTEM_WEAPON_SPELL_ID = 344179

-- 显示设置
local MAX_STACKS = 10
local DOT_SIZE = 25           -- 每个小圆点的大小
local DOT_SPACING = 6         -- 圆点间距
local BAR_WIDTH = (DOT_SIZE + DOT_SPACING) * MAX_STACKS
local BAR_HEIGHT = DOT_SIZE + 10
local POSITION_X = 0
local POSITION_Y = -260

local currentStacks = 0
local lastStacks = 0

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        self:Initialize()
    elseif event == "UNIT_AURA" then
        local unit = ...
        if unit == "player" then
            self:UpdateTotemWeaponStacks()
        end
    end
end)

function frame:Initialize()
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00漩涡武器小圆点监控已加载|r")

    -- 创建小圆点显示框架
    self:CreateDotProgress()

    -- 注册斜杠命令
    SLASH_TOTEM_WEAPON1 = "/twm"
    SlashCmdList["TOTEM_WEAPON"] = function(msg)
        self:HandleSlashCommand(msg)
    end
end

function frame:CreateDotProgress()
    -- 主框架
    self.dotFrame = CreateFrame("Frame", nil, UIParent)
    self.dotFrame:SetSize(BAR_WIDTH, BAR_HEIGHT)
    self.dotFrame:SetPoint("CENTER", POSITION_X, POSITION_Y)
    self.dotFrame:SetFrameStrata("HIGH")

    -- 背景条
    self.dotFrame.background = self.dotFrame:CreateTexture(nil, "BACKGROUND")
    self.dotFrame.background:SetSize(BAR_WIDTH + DOT_SPACING, BAR_HEIGHT + DOT_SPACING)
    self.dotFrame.background:SetPoint("CENTER")
    self.dotFrame.background:SetColorTexture(0, 0, 0, 0.3)
    self.dotFrame.background:SetGradient("VERTICAL",
            CreateColor(0, 0, 0, 0.25),
            CreateColor(0.2, 0.2, 0.2, 0.45)
    )

    -- 创建10个小圆点
    self.dots = {}

    for i = 1, MAX_STACKS do
        local dot = CreateFrame("Frame", nil, self.dotFrame)
        dot:SetSize(DOT_SIZE, DOT_SIZE)
        dot:SetPoint("LEFT", (i - 1) * (DOT_SIZE + DOT_SPACING) + (DOT_SPACING / 2), 0)

        -- 发光效果
        dot.glow = dot:CreateTexture(nil, "BACKGROUND")
        dot.glow:SetSize(DOT_SIZE, DOT_SIZE)
        dot.glow:SetPoint("CENTER")
        dot.glow:SetBlendMode("ADD")
        dot.glow:Hide()

        -- 小圆点纹理 - 使用白色纹理然后通过渐变上色
        dot.tex = dot:CreateTexture(nil, "OVERLAY")
        dot.tex:SetSize(DOT_SIZE, DOT_SIZE)
        dot.tex:SetPoint("CENTER")

        -- 关键：使用白色方形纹理，渐变会覆盖颜色
        dot.tex:SetTexture("Interface\\Buttons\\WHITE8x8")
        dot.glow:SetTexture("Interface\\Buttons\\WHITE8x8")

        -- 初始状态
        dot.tex:SetGradient("VERTICAL",
                CreateColor(0.5, 0.5, 0.5, 0.9),
                CreateColor(0.2, 0.2, 0.2, 0.9)
        )

        self.dots[i] = dot
    end

    -- 初始隐藏
    self.dotFrame:Hide()
end

function frame:UpdateDotProgress(stacks)
    for i = 1, MAX_STACKS do
        local dot = self.dots[i]

        if i <= stacks then
            -- 激活的小圆点 - 饱满的纵向渐变
            local topColor, bottomColor = self:GetGradientColors(i)
            dot.tex:SetGradient("VERTICAL", topColor, bottomColor)

            -- 发光效果
            dot.glow:SetGradient("VERTICAL", topColor, bottomColor)
            dot.glow:SetAlpha(0.2)
            dot.glow:Show()
            dot:SetAlpha(0.5)
        else
            -- 未激活的小圆点 - 深灰色渐变
            dot.tex:SetGradient("VERTICAL",
                    CreateColor(0.5, 0.5, 0.5, 0.9),
                    CreateColor(0.2, 0.2, 0.2, 0.9)
            )
            dot.glow:Hide()
            dot:SetAlpha(0.2)
        end
    end
end

function frame:GetGradientColors(dotIndex)
    -- 饱满的金属渐变色
    if dotIndex <= 3 then
        -- 蓝色金属
        return CreateColor(0.8, 0.9, 1.0, 0.7), CreateColor(0.2, 0.4, 0.9, 0.7)
    elseif dotIndex <= 6 then
        -- 绿色金属
        return CreateColor(0.9, 1.0, 0.8, 0.7), CreateColor(0.3, 0.7, 0.3, 0.7)
    elseif dotIndex <= 8 then
        -- 金色金属
        return CreateColor(1.0, 1.0, 0.7, 0.7), CreateColor(0.8, 0.6, 0.2, 0.7)
    else
        -- 红色金属
        return CreateColor(1.0, 0.8, 0.6, 0.7), CreateColor(0.9, 0.3, 0.1, 0.7)
    end
end

function frame:UpdateTotemWeaponStacks()
    local auraData = C_UnitAuras.GetUnitAuraBySpellID("player", TOTEM_WEAPON_SPELL_ID)

    if auraData then
        currentStacks = auraData.applications or 1

        -- 更新小圆点进度
        self:UpdateDotProgress(currentStacks)

        -- 显示框架
        self.dotFrame:Show()

        -- 层数变化时播放音效
        if currentStacks ~= lastStacks then
            if currentStacks > lastStacks then
                -- 层数增加时播放音效
                if currentStacks == 10 then
                    PlaySound(SOUNDKIT.RAID_WARNING) -- 满层特殊音效
                else
                    PlaySound(SOUNDKIT.UI_70_SOUL_ASH_UI_MAW_ENERGY_GAIN)
                end
            end
            lastStacks = currentStacks
        end

    else
        -- 没有buff时隐藏
        currentStacks = 0
        lastStacks = 0
        self.dotFrame:Hide()
    end
end

function frame:HandleSlashCommand(msg)
    local command = strlower(strtrim(msg))

    if command == "test" then
        self:TestDisplay()
    elseif command == "move" then
        self:ToggleMoveMode()
    elseif command == "reset" then
        self:ResetPosition()
    elseif command == "scale" then
        self:ToggleScale()
    else
        self:PrintHelp()
    end
end

function frame:TestDisplay()
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
        if currentStacks == 0 then
            self.dotFrame:Hide()
        else
            self:UpdateDotProgress(currentStacks)
        end
    end)
end

function frame:ToggleMoveMode()
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

function frame:ResetPosition()
    self.dotFrame:ClearAllPoints()
    self.dotFrame:SetPoint("CENTER", POSITION_X, POSITION_Y)
    self.dotFrame:SetScale(1)
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00位置和大小已重置|r")
end

function frame:ToggleScale()
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

function frame:PrintHelp()
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00漩涡武器小圆点监控命令:|r")
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00/twm test|r - 测试显示效果")
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00/twm move|r - 切换移动模式")
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00/twm scale|r - 切换大小")
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00/twm reset|r - 重置位置和大小")
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00/twm|r - 显示帮助")
end

-- 保存配置
local function SavePosition()
    if frame.dotFrame then
        local point, relativeTo, relativePoint, xOfs, yOfs = frame.dotFrame:GetPoint()
        TOTEM_WEAPON_MONITOR_POSITION = {
            point = point,
            x = xOfs,
            y = yOfs,
            scale = frame.dotFrame:GetScale()
        }
    end
end

-- 加载保存的位置
local function LoadPosition()
    if TOTEM_WEAPON_MONITOR_POSITION then
        frame.dotFrame:ClearAllPoints()
        frame.dotFrame:SetPoint(
                TOTEM_WEAPON_MONITOR_POSITION.point or "CENTER",
                UIParent,
                TOTEM_WEAPON_MONITOR_POSITION.point or "CENTER",
                TOTEM_WEAPON_MONITOR_POSITION.x or POSITION_X,
                TOTEM_WEAPON_MONITOR_POSITION.y or POSITION_Y
        )
        frame.dotFrame:SetScale(TOTEM_WEAPON_MONITOR_POSITION.scale or 1)
    end
end

-- 在显示框架创建后加载位置
C_Timer.After(1, LoadPosition)