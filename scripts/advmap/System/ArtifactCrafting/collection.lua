art_craft = {
    path = {
        texts = "/scripts/advmap/System/ArtifactCrafting/Texts/"
    }
}

art_craft.collection = {
    Init = function ()
        for art, type in NEW_ARTIFACTS_DATA do
            if type >= ARTIFACT_PRIMARY_WEAPON_BLANK and type <= ARTIFACT_POCKET_BLANK then
                -- collect blank
                Touch.SetTrigger(art)
                Touch.SetFunction(art, "art_craft_collect_blank", art_craft.collection.CollectBlank)
            elseif type >= ARTIFACT_INSIGNIA_OF_POWER and type <= ARTIFACT_INISGNIA_OF_COURAGE then
                -- collect insignia
                Touch.SetTrigger(art)
            elseif type == ARTIFACT_SEAL_OF_MIGHT or type == ARTIFACT_SEAL_OF_MAGIC then
                -- collect seal
                Touch.SetTrigger(art)
            elseif type >= ARTIFACT_SIGIL_OF_STEPPE and type <= ARTIFACT_SIGIL_OF_DRAGONS then
                -- collect sigil
                Touch.SetTrigger(art)
            end
        end
    end,

    CollectBlank = function (hero, object)
        local blank_type = NEW_ARTIFACTS_DATA[object]
        inventory.UpdateBlankCount(blank_type, 1)
        MessageQueue.AddMessage(GetObjectOwner(hero), {
            art_craft.path.texts.."collection.txt"; count = 1, collectable = Art.Params.Name(blank_type), total = inventory.blanks_count[blank_type]
        }, hero, 6.0)
    end,

    CollectInsignia = function (hero, object)
        local insignia_type = NEW_ARTIFACTS_DATA[object]
        inventory.UpdateInsigniaCount(insignia_type, 1)
        MessageQueue.AddMessage(GetObjectOwner(hero), {
            art_craft.path.texts.."collection.txt"; count = 1, collectable = Art.Params.Name(insignia_type), total = inventory.blanks_count[insignia_type]
        }, hero, 6.0)
    end
}