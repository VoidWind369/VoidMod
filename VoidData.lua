function InitDatabase()
    VoidModDB = VoidModDB or {}
    VoidModCharacterDB = VoidModCharacterDB or {
        point = {}
    }
    VoidModCharacterDB.status = VoidModCharacterDB.status or {
        PlayerInfo = true,
        SkillLine = true,
        ShieldInfo = true,
        TotemInfo = true,
        TotemTool = true,
    }
    VoidModCharacterDB.totem = VoidModCharacterDB.totem or {}
end

function NewDatabase()
    VoidModDB = {}
    VoidModCharacterDB = {
        point = {}
    }
    VoidModCharacterDB.status = {
        PlayerInfo = true,
        SkillLine = true,
        ShieldInfo = true,
        TotemInfo = true,
        TotemTool = true,
    }
    VoidModCharacterDB.totem = {}
    ReloadUI()
end
