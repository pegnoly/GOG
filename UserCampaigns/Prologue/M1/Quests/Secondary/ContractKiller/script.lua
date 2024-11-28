-- @quest 
-- Кампания. Личный демон.
-- Миссия. Сердце ночи.
-- Тип квеста. Второстепенный.
-- Имя квеста. Заказное убийство.

ARTIFACT_C1M1_Q_CONTRACT_KILLER_RAINBOW_CRYSTAL = 350

c1m1_q_contract_killer = {
        --*ПЕРЕМЕННЫЕ*--
    
    -- техническая информация --
    name = "C1M1_CONTRACT_KILLER",

    path = {
        text = secondary_quest_path.."ContractKiller/Texts/",
        dialog = secondary_quest_path.."ContractKiller/Dialogs/"
    },

    dialogs = {
        Start = "GOG_C1_M1_Q_CONTRACT_KILLER_TAVERN_START_DIALOG",
        TavernTemp = "GOG_C1M1_Q_CONTRACT_KILLER_TAVERN_TEMP_DIALOG",
        Seller = "GOG_C1M1_Q_CONTRACT_KILLER_SELLER_DIALOG",
        SellerKeptAlive = "GOG_C1M1_Q_CONTRACT_KILLER_SELLER_KEPT_ALIVE_DIALOG",
        Final = "GOG_C1M1_Q_CONTRACT_KILLER_TAVERN_FINAL_DIALOG"
    },

        --*ФУНКЦИИ*--
    Init = 
    function ()
        Quest.Names["C1M1_CONTRACT_KILLER"] = secondary_quest_path.."ContractKiller/name.txt"
        Quest.SetObjectQuestmark("forest_edge_tavern", QUESTMARK_OBJ_NEW, QUESTMARK_HEIGHT_TAVERN)
        Touch.SetFunction("forest_edge_tavern", "contract_killer_talk", c1m1_q_contract_killer.TavernTalk)
    end,

    TavernTalk =
    function (hero, object)
        if Quest.IsUnknown(c1m1_q_contract_killer.name) then
            MiniDialog.Start(c1m1_q_contract_killer.path.dialog.."TavernStartDialog/", PLAYER_1, c1m1_q_contract_killer.dialogs.Start)
            Touch.SetFunction("forest_edge_artifact_merchant", "contract_killer_fight", c1m1_q_contract_killer.SellerFight)
            Quest.Start(c1m1_q_contract_killer.name, hero)
            Quest.SetObjectQuestmark(object, QUESTMARK_OBJ_IN_PROGRESS, QUESTMARK_HEIGHT_TAVERN)
            Quest.SetObjectQuestmark("forest_edge_artifact_merchant", QUESTMARK_OBJ_NEW_PROGRESS, QUESTMARK_HEIGHT_ARTIFACT_MERCHANT)
            return
        end
        --
        local progress = Quest.GetProgress(c1m1_q_contract_killer.name)
        if progress == 0 then
            MiniDialog.Start(c1m1_q_contract_killer.path.dialog.."TavernTempDialog/", PLAYER_1, c1m1_q_contract_killer.dialogs.TavernTemp)
            return
        end
        if progress == 1 then
            MiniDialog.Start(c1m1_q_contract_killer.path.dialog.."TavernFinalDialog/", PLAYER_1, c1m1_q_contract_killer.dialogs.Final)
            Quest.Finish(c1m1_q_contract_killer.name, hero)
            Touch.RemoveFunction(object, "contract_killer_talk")
            c1m1_q_treasures_and_secrets.Start(hero)
            return
        end
    end,

    SellerFight = 
    function (hero, object)
        MessageBox(c1m1_q_contract_killer.path.text.."seller_fight_start.txt")
        local creatures = {
            [CREATURE_BLACK_HUNDRED_ALEBARDIST] = 150, 
            [CREATURE_BLACK_HUNDRED_ARCHER] = 80, 
            [CREATURE_BLACK_HUNDRED_BOLLARD] = 45,
            [CREATURE_BLACK_HUNDRED_SORCERER] = 21,
            [CREATURE_BLACK_HUNDRED_UHLAN] = 12
        }
        if initialDifficulty == DIFFICULTY_EASY then
            creatures[CREATURE_BLACK_HUNDRED_UHLAN] = nil
        end
        local actual_army, n = {}, 1
        for creature, count in creatures do
            if creature and count then
                actual_army[n] = creature
                actual_army[n + 1] = count
                n = n + 2
            end
        end
        if MCCS_StartCombat(hero, nil, initialDifficulty == DIFFICULTY_EASY and 4 or 5, actual_army) then
            Touch.RemoveFunction(object, "contract_killer_fight")
            startThread(c1m1_q_contract_killer.FinishSellerFight, hero, object)
        end
    end,

    FinishSellerFight = 
    function (hero, object)
        MiniDialog.Start(c1m1_q_contract_killer.path.dialog.."SellerDialog/", PLAYER_1, c1m1_q_contract_killer.dialogs.Seller)
        if MCCS_QuestionBox(c1m1_q_contract_killer.path.text.."keep_seller_alive.txt") then
            MessageBox(c1m1_q_contract_killer.path.text.."gold_taken_from_dead.txt")
            Resource.Change(hero, GOLD, 10000 - 1000 * initialDifficulty)
        else
            MiniDialog.Start(c1m1_q_contract_killer.path.dialog.."SellerKeptAliveDialog/", PLAYER_1, c1m1_q_contract_killer.dialogs.SellerKeptAlive)
        end
        Art.Distribution.Give(hero, ARTIFACT_C1M1_Q_CONTRACT_KILLER_RAINBOW_CRYSTAL, 1)
        Touch.SetDefault(object, function (h, o)
            MessageBox(c1m1_q_contract_killer.path.text.."artifact_merchant_empty.txt")
        end)
        Quest.Update(c1m1_q_contract_killer.name, 1, hero)
        Quest.ResetObjectQuestmark(object)
        Quest.SetObjectQuestmark("forest_edge_tavern", QUESTMARK_OBJ_NEW_PROGRESS, QUESTMARK_HEIGHT_TAVERN)
    end
}