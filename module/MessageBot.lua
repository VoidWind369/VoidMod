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
        self:Void_PlayerInfo()
    end
end

function VoidFrame:PartyStart(name, isTank, isHealer, isDamage, isNativeRealm, allowMultipleRoles, inviterGUID, questSessionActive)
    AcceptGroup()
    StaticPopup_Hide("PARTY_INVITE")
    print("被|cFA500FF0" .. name .. "|r邀请进组")
end

function VoidFrame:Void_PlayerInfo()
    -- 主属性
    local strength = UnitAttackPower("player", 1)
    local agility = UnitAttackPower("player", 2)
    local stamina = UnitAttackPower("player", 3)
    local intellect = UnitAttackPower("player", 4)

    local attackPower = UnitAttackPower("player")
    local spellHaste = UnitSpellHaste("player")
    local armor = UnitArmor("player")
    local currentSpeed = GetUnitSpeed("player")

    -- 副属性
    local spellHastePercent = UnitSpellHaste("player")
    local critChance = GetCritChance()
    local mastery = GetMastery()
    local hitBonus = GetCombatRatingBonus(CR_HIT_MELEE)
    print("基础属性\n力量：" .. strength .. "\n敏捷：" .. agility .. "\n耐力：" .. stamina .. "\n智力：" .. intellect)
    print("战斗属性\n攻击强度：" .. attackPower .. "\n法术强度：" .. spellHaste .. "\n护甲：" .. armor .. "\n移动速度：" .. currentSpeed)
    print("强化属性\n急速：" .. spellHastePercent .. "\n暴击：" .. critChance .. "\n精通：" .. mastery .. "\n全能：" .. hitBonus)
end