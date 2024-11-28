
ARTIFACT_Q_ELEMENTAL_FROZEN_HEART = 351
ARTIFACT_Q_ELEMENTAL_BLAZING_HEART = 352
ARTIFACT_Q_ELEMENTAL_DAZZLING_HEART = 353
ARTIFACT_Q_ELEMENTAL_STONE_HEART = 354
ARTIFACT_Q_COMPLETE_KEY_OF_ELEMENTS = 355
ARTIFACT_Q_SECRET_TREASURE_BOOK = 356
ARTIFACT_Q_BOOK_CIPHER_FRAGMENT = 357
ARTIFACT_Q_BOOK_CIPHER_KEY = 358

MCCS_CUSTOM_ABILITY_CREATE_ELEMENTAL_KEY = "MCCS_CUSTOM_ABILITY_CREATE_ELEMENTAL_KEY"

c1m1_q_treasures_and_secrets = {
            --*ПЕРЕМЕННЫЕ*--
    
    -- техническая информация --
    name = "C1M1_TREASURES_AND_SECRETS",

    path = {
        text = secondary_quest_path.."TreasuresAndSecrets/Texts/",
        dialog = secondary_quest_path.."TreasuresAndSecrets/Dialogs/"
    },

    dialogs = {
        TempOne = "GOG_C1M1_Q_TREASURES_AND_SECRETS_TAVERN_TEMP_DIALOG_ONE",
        TempTwo = "GOG_C1M1_Q_TREASURES_AND_SECRETS_TAVERN_TEMP_DIALOG_TWO",
        TreasureVisited = "GOG_C1M1_Q_TREASURES_AND_SECRETS_TREASURE_VISITED_DIALOG",
        Final = "GOG_C1M1_Q_TREASURES_AND_SECRETS_FINAL_DIALOG"
    },

    stockpiles = {
        "start_zone_elemental_stockpile",
        "deep_forest_elemental_stockpile",
        "big_mountain_foot_elemental_stockpile",
        "west_swamp_elemental_stockpile"
    },

    hearts = {
        ARTIFACT_Q_ELEMENTAL_BLAZING_HEART, 
        ARTIFACT_Q_ELEMENTAL_DAZZLING_HEART, 
        ARTIFACT_Q_ELEMENTAL_STONE_HEART, 
        ARTIFACT_Q_ELEMENTAL_FROZEN_HEART
    },
    spellpower_artifacts = {
        ARTIFACT_EVERCOLD_ICICLE, 
        ARTIFACT_PHOENIX_FEATHER_CAPE, 
        ARTIFACT_TITANS_TRIDENT, 
        ARTIFACT_EARTHSLIDERS
    },
    rare_resources = {SULFUR, MERCURY, GEM, CRYSTAL},
    resource_amount_for_key = 15,

    Init = 
    function ()
        Quest.Names["C1M1_TREASURES_AND_SECRETS"] = secondary_quest_path.."TreasuresAndSecrets/name.txt"
        for _, stockpile in c1m1_q_treasures_and_secrets.stockpiles do
            Touch.DisableObject(stockpile)
            Touch.SetDefault(stockpile,
            function (hero, object)
                MessageBox(c1m1_q_treasures_and_secrets.path.text.."stockpile_inactive.txt")
            end)
        end
    end,

    Start = 
    function (hero)
        Quest.Start(c1m1_q_treasures_and_secrets.name, hero)
        for _, stockpile in c1m1_q_treasures_and_secrets.stockpiles do
            Quest.SetObjectQuestmark(stockpile, QUESTMARK_OBJ_IN_PROGRESS, QUESTMARK_HEIGHT_ELEMENTAL_STOCKPILE)
            Touch.SetFunction(stockpile, "treasures_and_secrets_fight", c1m1_q_treasures_and_secrets.StockpileTouch)
        end
        CombatConnection.combat_scripts_paths['treasures_and_secrets_elementals'] = GetMapDataPath()..'Combat/GreatElementals/script.lua'
        CombatConnection.CreateCombatFunctionsList(CombatConnection.combat_scripts_paths)
        SetGameVar("stone_heart", "not_collected")
        SetGameVar("blazing_heart", "not_collected")
        SetGameVar("dazzling_heart", "not_collected")
        SetGameVar("frozen_heart", "not_collected")
        Touch.SetFunction("forest_edge_tavern", "treasures_and_secrets_talk", c1m1_q_treasures_and_secrets.TavernTalk)
        startThread(c1m1_q_treasures_and_secrets.KeyCreationAbilityInit)
        startThread(c1m1_q_treasures_and_secrets.KeyCreationAbilityActivationThread, hero)
    end,

    TavernTalk = 
    function (hero, object)
        local progress = Quest.GetProgress(c1m1_q_treasures_and_secrets.name)
        if progress == 0 or progress == 1 then
            MiniDialog.Start(c1m1_q_treasures_and_secrets.path.dialog.."TavernTempDialogOne/", PLAYER_1, c1m1_q_treasures_and_secrets.dialogs.TempOne)
            return
        end
        --
        if progress == 2 then
            MiniDialog.Start(c1m1_q_treasures_and_secrets.path.dialog.."TreasureVisitedDialog/", PLAYER_1, c1m1_q_treasures_and_secrets.dialogs.TreasureVisited)
            Quest.Update(c1m1_q_treasures_and_secrets.name, 3, hero)
            return
        end
    end,

    StockpileTouch = 
    function (hero, object)
        if object == "start_zone_elemental_stockpile" then
            startThread(c1m1_q_treasures_and_secrets.ObsidianFight, hero, object)
            return
        elseif object == "deep_forest_elemental_stockpile" then
            startThread(c1m1_q_treasures_and_secrets.BlazingFight, hero, object)
            return
        elseif object == "big_mountain_foot_elemental_stockpile" then
            startThread(c1m1_q_treasures_and_secrets.DazzlingFight, hero, object)
            return
        elseif object == "west_swamp_elemental_stockpile" then
            startThread(c1m1_q_treasures_and_secrets.FrozenFight, hero, object)
            return
        end
    end,

    ObsidianFight = 
    function (hero, object)
        if MCCS_StartCombat(hero, nil, 4, {
            CREATURE_FIRE_ELEMENTAL, 1,
            CREATURE_WATER_ELEMENTAL, 1,
            CREATURE_AIR_ELEMENTAL, 1,
            CREATURE_OBSIDIAN_ELEMENTAL, 1
        }, nil, nil, nil, 1) then
            if GetGameVar("stone_heart") == "collected" then
                MarkObjectAsVisited(object, hero)
                Art.Distribution.Give(hero, ARTIFACT_Q_ELEMENTAL_STONE_HEART, 1)
                Touch.RemoveFunction(object, "treasures_and_secrets_fight")
                Quest.ResetObjectQuestmark(object)
                Touch.SetDefault(object, function (_, _)
                    MessageBox(c1m1_q_treasures_and_secrets.path.text.."stockpile_empty.txt")
                end) 
            end
        end
    end,

    BlazingFight = 
    function (hero, object)
        if MCCS_StartCombat(hero, nil, 4, {
            CREATURE_BLAZE_ELEMENTAL, 1,
            CREATURE_WATER_ELEMENTAL, 1,
            CREATURE_AIR_ELEMENTAL, 1,
            CREATURE_EARTH_ELEMENTAL, 1
        }, nil, nil, nil, 1) then
            if GetGameVar("blazing_heart") == "collected" then
                MarkObjectAsVisited(object, hero)
                Art.Distribution.Give(hero, ARTIFACT_Q_ELEMENTAL_BLAZING_HEART, 1)
                Touch.RemoveFunction(object, "treasures_and_secrets_fight")
                Quest.ResetObjectQuestmark(object)
                Touch.SetDefault(object, function (_, _)
                    MessageBox(c1m1_q_treasures_and_secrets.path.text.."stockpile_empty.txt")
                end) 
            end
        end
    end,

    DazzlingFight = 
    function (hero, object)
        if MCCS_StartCombat(hero, nil, 4, {
            CREATURE_FIRE_ELEMENTAL, 1,
            CREATURE_WATER_ELEMENTAL, 1,
            CREATURE_STORM_ELEMENTAL, 1,
            CREATURE_EARTH_ELEMENTAL, 1
        }, nil, nil, nil, 1) then
            if GetGameVar("dazzling_heart") == "collected" then
                MarkObjectAsVisited(object, hero)
                Art.Distribution.Give(hero, ARTIFACT_Q_ELEMENTAL_DAZZLING_HEART, 1)
                Touch.RemoveFunction(object, "treasures_and_secrets_fight")
                Quest.ResetObjectQuestmark(object)
                Touch.SetDefault(object, function (_, _)
                    MessageBox(c1m1_q_treasures_and_secrets.path.text.."stockpile_empty.txt")
                end) 
            end
        end
    end,

    SetupIceElementalsFight = 
    function (hero, object)
        if MCCS_StartCombat(hero, nil, 4, {
            CREATURE_FIRE_ELEMENTAL, 1,
            CREATURE_ICE_ELEMENTAL, 1,
            CREATURE_AIR_ELEMENTAL, 1,
            CREATURE_EARTH_ELEMENTAL, 1
        }, nil, nil, nil, 1) then
            if GetGameVar("frozen_heart") == "collected" then
                MarkObjectAsVisited(object, hero)
                Art.Distribution.Give(hero, ARTIFACT_Q_ELEMENTAL_FROZEN_HEART, 1)
                Touch.RemoveFunction(object, "treasures_and_secrets_fight")
                Quest.ResetObjectQuestmark(object)
                Touch.SetDefault(object, function (_, _)
                    MessageBox(c1m1_q_treasures_and_secrets.path.text.."stockpile_empty.txt")
                end) 
            end
        end
    end,

    KeyCreationAbilityInit = 
    function ()
        CustomAbility.Hero.DialogPredefAnswers[MCCS_CUSTOM_ABILITY_CREATE_ELEMENTAL_KEY] = {
            c1m1_q_treasures_and_secrets.path.text.."ability_create_key.txt",
            MCCS_CUSTOM_ABILITY_CREATE_ELEMENTAL_KEY,
            1,
            1
        }
        CustomAbility.Hero.Callbacks[MCCS_CUSTOM_ABILITY_CREATE_ELEMENTAL_KEY] = c1m1_q_treasures_and_secrets.KeyCreationAbilityActivated
    end,

    KeyCreationAbilityActivationThread = 
    function (hero)
        local hearts = {ARTIFACT_Q_ELEMENTAL_BLAZING_HEART, ARTIFACT_Q_ELEMENTAL_DAZZLING_HEART, ARTIFACT_Q_ELEMENTAL_STONE_HEART, ARTIFACT_Q_ELEMENTAL_FROZEN_HEART}
        local spellpower_artifacts = {ARTIFACT_EVERCOLD_ICICLE, ARTIFACT_PHOENIX_FEATHER_CAPE, ARTIFACT_TITANS_TRIDENT, ARTIFACT_EARTHSLIDERS}
        local rare_resources = {SULFUR, MERCURY, GEM, CRYSTAL}
        while 1 do
            if list_iterator.All(c1m1_q_treasures_and_secrets.hearts, function(heart) return HasArtefact(%hero, heart) end) and
                list_iterator.All(c1m1_q_treasures_and_secrets.spellpower_artifacts, function (art) return HasArtefact(%hero, art) end) and
                list_iterator.All(c1m1_q_treasures_and_secrets.rare_resources, function (res) return GetPlayerResource(PLAYER_1, res) >= c1m1_q_treasures_and_secrets.resource_amount_for_key end) then
                if not CustomAbility.Hero.AbilitiesByHero[hero][MCCS_CUSTOM_ABILITY_CREATE_ELEMENTAL_KEY] then
                    CustomAbility.Hero.AbilitiesByHero[hero][MCCS_CUSTOM_ABILITY_CREATE_ELEMENTAL_KEY] = 1
                end
            else
                if CustomAbility.Hero.AbilitiesByHero[hero][MCCS_CUSTOM_ABILITY_CREATE_ELEMENTAL_KEY] then
                    CustomAbility.Hero.AbilitiesByHero[hero][MCCS_CUSTOM_ABILITY_CREATE_ELEMENTAL_KEY] = nil
                end
            end
            sleep()
        end
    end,

    KeyCreationAbilityActivated = 
    function (hero, player)
        for _, heart in c1m1_q_treasures_and_secrets.hearts do
            RemoveArtefact(hero, heart)
        end
        for _, art in c1m1_q_treasures_and_secrets.spellpower_artifacts do
            RemoveArtefact(hero, art)
        end
        for _, res in c1m1_q_treasures_and_secrets.rare_resources do
            Resource.Change(hero, res, -c1m1_q_treasures_and_secrets.resource_amount_for_key)
        end
        CustomAbility.Hero.AbilitiesByHero[hero][MCCS_CUSTOM_ABILITY_CREATE_ELEMENTAL_KEY] = nil
        Art.Distribution.Give(hero, ARTIFACT_Q_COMPLETE_KEY_OF_ELEMENTS, 1)
        Quest.Update(c1m1_q_treasures_and_secrets.name, 1, hero)
    end,

    Test = 
    function ()
        for _, heart in c1m1_q_treasures_and_secrets.hearts do
            GiveArtefact("Karlam", heart)
        end
        for _, art in c1m1_q_treasures_and_secrets.spellpower_artifacts do
            GiveArtefact("Karlam", art)
        end
        for _, res in c1m1_q_treasures_and_secrets.rare_resources do
            Resource.Change("Karlam", res, c1m1_q_treasures_and_secrets.resource_amount_for_key)
        end
    end
}

q1t = c1m1_q_treasures_and_secrets.Test