-- 创建主框架
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("UNIT_AURA")

-- 嗜血类法术ID列表
local BLOODLUST_SPELL_IDS = {
    [2825] = "|cFF0070DE嗜血 Bloodlust|r",
    [32182] = "|cFF0070DE英勇 Heroism|r",
    [80353] = "|cFF69CCF0时光扭曲 Time Warp|r",
    [264667] = "|cFFABD473原始狂怒 Primal Rage|r",
    [390386] = "|cFF33937F守护巨龙之怒 Fury of the Aspects|r",
    [178207] = "|cFFC69B6D狂怒战鼓|r",
    [230935] = "|cFFC69B6D高山战鼓|r",
    [256740] = "|cFFC69B6D漩涡战鼓|r",
    [308084] = "|cFFC69B6D尊主打击|r",
    [354646] = "|cFFC69B6D戈姆毒气|r",
}

local D_SPELL_IDS = {
    [192106] = "闪电护盾",
    [52127] = "水之护盾",
    [136089] = "大地护盾",
}

-- 语音文件路径
local VOICE_FILE = "Interface\\AddOns\\VoidMod\\void_voice.ogg"
local YURIN = "Interface\\AddOns\\VoidMod\\yurin.wav"

local hasBloodlust = false
local lastPlayTime = 0

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        self:Initialize()
    elseif event == "UNIT_AURA" then
        local unit = ...
        if unit == "player" then
            self:CheckBloodlust()
        end
    end
end)

function frame:Initialize()
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00恶龙咆哮已加载|r")
    
    -- 注册斜杠命令
    SLASH_BLOODLUSTSIMPLE1 = "/bls"
    SlashCmdList["BLOODLUSTSIMPLE"] = function(msg)
        if msg == "test" then
            self:TestAlert("ogg")
        elseif msg == "wav" then
            self:TestAlert("wav")
        elseif msg == "debug" then
            self:DebugBuffs()
        elseif msg == "ele" then
            self:DebugEleBuff()
        else
            self:PrintHelp()
        end
    end
    
    -- 每秒检查一次
    C_Timer.NewTicker(1, function()
        self:CheckBloodlust()
    end)
end

function frame:CheckBloodlust()
    local foundBuff = false
    local buffName = ""
    local spellIdFound = 0
    
    -- 使用C_UnitAuras.GetUnitAuraBySpellID
    for bloodlustId, bloodlustName in pairs(BLOODLUST_SPELL_IDS) do
        local auraData = C_UnitAuras.GetUnitAuraBySpellID("player", bloodlustId)
        if auraData then
            foundBuff = true
            buffName = auraData.name
            spellIdFound = auraData.spellId
            break
        end
    end
    
    -- 处理buff状态变化
    if foundBuff and not hasBloodlust then
        self:OnBloodlustGained(buffName, spellIdFound, "wav")
        hasBloodlust = true
    elseif not foundBuff and hasBloodlust then
        hasBloodlust = false
    end
end

function frame:OnBloodlustGained(buffName, spellId, ogg)
    local currentTime = GetTime()
    
    -- 防止重复播放（10秒内）
    if currentTime - lastPlayTime < 10 then
        return
    end
    
    lastPlayTime = currentTime
    
    -- 在聊天框显示
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000※ 你获得了 " .. buffName .. " (ID:" .. spellId .. ")！|r")
    
    -- 播放语音
    self:PlayBloodlustVoice(ogg)
    
    -- 屏幕提示
    self:ShowSimpleAlert(buffName)
end

function frame:TestAlert(ogg)
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00测试嗜血提示...|r")
    self:OnBloodlustGained("嗜血测试", 2825, ogg)
end

function frame:PlayBloodlustVoice(ogg)
    -- 播放外部语音文件
    if PlaySoundFile then
        if ogg == "ogg" then
            PlaySoundFile(VOICE_FILE, "Master")
        else
            PlaySoundFile(YURIN, "Master")
        end
    else
        -- 备选：使用游戏内置音效
        PlaySound(569200, "Master") -- 嗜血音效
    end
end

function frame:ShowSimpleAlert(buffName)
    -- 屏幕中央错误提示
    UIErrorsFrame:AddMessage("💥 " .. buffName .. "！", 1.0, 1.0, 0.0, 1.0)
    
    -- 创建大文字提示
    if not self.alertText then
        self.alertText = UIParent:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
        self.alertText:SetPoint("CENTER", 0, 100)
        self.alertText:SetTextColor(1, 0, 0, 1)
        self.alertText:SetShadowColor(0, 0, 0, 1)
        self.alertText:SetShadowOffset(2, -2)
    end
    
    self.alertText:SetText("※ " .. buffName .. "！")
    self.alertText:SetAlpha(1)
    
    -- 淡出动画
    self.alertText.fadeInfo = {}
    self.alertText.fadeInfo.mode = "OUT"
    self.alertText.fadeInfo.timeToFade = 3
    self.alertText.fadeInfo.startAlpha = 1
    self.alertText.fadeInfo.endAlpha = 0
    UIFrameFade(self.alertText, self.alertText.fadeInfo)
end

function frame:DebugBuffs()
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00=== 嗜血Buff检测 ===|r")
    for bloodlustId, bloodlustName in pairs(BLOODLUST_SPELL_IDS) do
        local auraData = C_UnitAuras.GetUnitAuraBySpellID("player", bloodlustId)
        if auraData then
            DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00已激活|r" .. bloodlustName:sub(1, 10) .. (auraData.name or "未知") .. " (ID: " .. (auraData.spellId or "?") .. ")|r")
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000未找到|r" .. bloodlustName)
        end
    end
    
    -- 显示当前嗜血状态
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00当前嗜血状态: " .. (hasBloodlust and "|cFF00FF00已激活|r" or "|cFFFF0000未激活|r"))
end

function frame:DebugEleBuff()
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00护盾Buff检测|r")
    for spellId, spellName in pairs(D_SPELL_IDS) do
        local auraData = C_UnitAuras.GetUnitAuraBySpellID("player", spellId)
        if auraData then
            DEFAULT_CHAT_FRAME:AddMessage("|cFF888888" .. (auraData.name or "未知") .. " (ID: " .. (auraData.spellId or "?") .. ")|r")
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000未找到" .. spellName .. "护盾|r")
        end
    end
end

function frame:PrintHelp()
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00嗜血监控命令:|r")
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00/bls test|r - 测试提示效果")
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00/bls debug|r - 显示当前所有buff和ID")
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00/bls|r - 显示帮助")
end