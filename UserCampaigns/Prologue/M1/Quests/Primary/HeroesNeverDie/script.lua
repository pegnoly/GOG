-- @quest
-- Кампания: Игры богов.
-- Миссия: Эльф и его тень.
-- Квест: Герои не умирают.
-- Тип квеста: Основной.

heroes_never_die =
{
        --*Переменные*--

    -- техническая информация --
    name = "HEROES_NEVER_DIE",
    path = 
    {
        dialog = q_path.."Primary/HeroesNeverDie/Dialogs/",
        text = q_path.."Primary/HeroesNeverDie/Texts/"
    },

    Init =
    function()
        AddHeroCreatures('Karlam', CREATURE_GREMLIN_SABOTEUR, 100 - 15 * initialDifficulty - random(5))
        AddHeroCreatures('Karlam', CREATURE_MARBLE_GARGOYLE, 30 - 5 * initialDifficulty)
        AddHeroCreatures('Karlam', CREATURE_OBSIDIAN_GARGOYLE, 25 - 3 * defaultDifficulty)
        AddHeroCreatures('Karlam', CREATURE_ARCH_MAGI, 1)
        --
        startThread(heroes_never_die.KarlamAlive)
        print("<color=green>M1_Q_HeroesNeverDie.Init successfull")
    end,

    KarlamAlive = 
    function()
        while IsHeroAlive("Karlam") do
            sleep()
        end
        sleep(10)
        Loose()
    end
}
