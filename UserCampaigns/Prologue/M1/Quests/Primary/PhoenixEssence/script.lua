-- @quest 
-- Кампания. Личный демон.
-- Миссия. Сердце ночи.
-- Тип квеста. Основной.
-- Имя квеста. Эссенция жизни.

ARTIFACT_C1_M1_LIFE_ESSENCE = 402

phoenix_essence = {
        --*ПЕРЕМЕННЫЕ*--

    -- техническая информация --
    name = "C1_M1_PHOENIX_ESSENCE",
    path = 
    {
        text = primary_quest_path.."PhoenixEssence/Texts/",
        dialog = primary_quest_path.."PhoenixEssence/Dialogs/"
    },

    Init = 
    function ()
        Touch.DisableObject("qPhoenix", DISABLED_INTERACT)
        Touch.SetFunction("qPhoenix", "C1_M1_q_phoenix_essence_phoenix_touch", phoenix_essence.PhoenixTouch)
    end,

    Start = 
    function ()
        Quest.Start(phoenix_essence.name, "Karlam")
    end,

    PhoenixTouch =
    function (hero, object)
        PlayObjectAnimation(object, "specability", ONESHOT)
        sleep(15)
        RemoveObject(object)
        MessageBox(phoenix_essence.path.."phoenix_found.txt")
        Quest.Finish(phoenix_essence.name, hero)
        Art.Distribution.Give(hero, ARTIFACT_C1_M1_LIFE_ESSENCE, 1)
    end
}