-- @quest
-- Кампания: Игры богов.
-- Миссия: Эльф и его тень.
-- Квест: Призрачная надежда.
-- Тип квеста: Второстепенный.

ghost_hope =
{
        --*ПЕРЕМЕННЫЕ*--
    -- техническая информация --
    name = "GHOST_HOPE",
    path = 
    {
        text = q_path.."Secondary/GhostHope/Texts/",
        dialog = q_path.."Secondary/GhostHope/Dialogs/"
    },

    Init =
    function(hero, player)
        MiniDialog.Start(ghost_hope.path.dialog..'StartDialog/', player)
        Quest.Start(ghost_hope.name, hero)
        print("<color=green>M1_Q_GhostHope.Init successfull")
    end,
}