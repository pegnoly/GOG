inventory = {
    blanks_count = {},
    insignia_count = {},
    seals_count = {},
    sigils_count = {},

    Init = function ()
        startThread(inventory.InitBlanks)
        startThread(inventory.InitInsignias)
        startThread(inventory.InitSeals)
        startThread(inventory.InitSigils)
    end,

    InitBlanks = function ()
        for blank = ARTIFACT_PRIMARY_WEAPON_BLANK, ARTIFACT_POCKET_BLANK do
            inventory.blanks_count[blank] = 0
        end
    end,

    InitInsignias = function ()
        for insignia = ARTIFACT_INSIGNIA_OF_POWER, ARTIFACT_INISGNIA_OF_COURAGE do
            inventory.insignia_count[insignia] = 0
        end
    end,

    InitSeals = function ()
        for seal = ARTIFACT_SEAL_OF_MIGHT, ARTIFACT_SEAL_OF_MAGIC do
            inventory.seals_count[seal] = 0
        end
    end,

    InitSigils = function ()
        for sigil = ARTIFACT_SIGIL_OF_STEPPE, ARTIFACT_SIGIL_OF_DRAGONS do
            inventory.sigils_count[sigil] = 0
        end
    end,

    --- Changes count for blank of given type in inventory 
    ---@param blank_type ArtifactBlankType
    ---@param count integer
    UpdateBlankCount = function (blank_type, count)
        inventory.blanks_count[blank_type] = inventory.blanks_count[blank_type] + count
    end,

    ---comment
    ---@param insignia_type any
    ---@param count any
    UpdateInsigniaCount = function (insignia_type, count)
        inventory.insignia_count[insignia_type] = inventory.insignia_count[insignia_type] + count
    end
}