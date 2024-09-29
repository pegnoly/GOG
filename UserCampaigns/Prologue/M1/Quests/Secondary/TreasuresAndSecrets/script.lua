
ARTIFACT_Q_ELEMENTAL_FROZEN_HEART = 351
ARTIFACT_Q_ELEMENTAL_BLAZING_HEART = 352
ARTIFACT_Q_ELEMENTAL_DAZZLING_HEART = 353
ARTIFACT_Q_ELEMENTAL_STONE_HEART = 354

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

    Init = 
    function ()
        for _, stockpile in c1m1_q_treasures_and_secrets.stockpiles do
            Touch.SetDefault(stockpile,
            function (hero, object)
                MessageBox(c1m1_q_treasures_and_secrets.path.text.."stockpile_inactive.txt")
            end)
        end
    end,

    Start = 
    function (hero)
        Quest.Start(c1m1_q_treasures_and_secrets.name, hero)
        Touch.SetFunction("forest_edge_tavern", "treasures_and_secrets_talk", c1m1_q_treasures_and_secrets.TavernTalk)
    end,

    TavernTalk = 
    function (hero, object)
        local progress = Quest.GetProgress(c1m1_q_treasures_and_secrets.name)
        if progress == 0 then
            MiniDialog.Start(c1m1_q_treasures_and_secrets.path.dialog.."TavernTempDialogOne/", PLAYER_1, c1m1_q_treasures_and_secrets.dialogs.TempOne)
            return
        end
        --
        if progress == 1 then
            MiniDialog.Start(c1m1_q_treasures_and_secrets.path.dialog.."TreasureVisitedDialog/", PLAYER_1, c1m1_q_treasures_and_secrets.dialogs.TreasureVisited)
            
            return
        end
    end
}