function GetTargetBuff()
    local festering_aura = C_UnitAuras.GetUnitAuraBySpellID("target", 1241077)
    if festering_aura then
        print("毒镰", festering_aura.expirationTime)
    else
        print("补毒镰")
    end
end

function PrintSpell()
    local spellInfo = C_Spell.GetSpellInfo(12410977)
    print(spellInfo.name)
end
