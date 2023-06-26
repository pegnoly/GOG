-- @combat_script -- 
-- Кампания: Игры богов.
-- Миссия: Эльф и его тень.
-- Бой: Искаженная роха.

-- возможные стадии боя
CURSED_ROCK_FIGHT_STAGE_PREPARATION = 0
CURSED_ROCK_FIGHT_STAGE_ACTIVE = 1

cursed_rock_fight =
{
    -- текущая стадия боя
    stage = CURSED_ROCK_FIGHT_STAGE_PREPARATION,
    -- существо, на которое был скастован фантом на текущей итерации
    current_creature_to_phantom = "",
    -- таблица информации о базовых отрядах для перемещения фантомов
    replace_info = {}
}

if GetGameVar("cursed_rock_fight") == "1" then
    AddCombatFunction(CombatFunctions.START,
    function()
        startThread(CursedRockFight_Start)
    end)
    AddCombatFunction(CombatFunctions.DEFENDER_CREATURE_MOVE,
    function(creature)
        CursedRock_RockMove(creature, DEFENDER)
        if cursed_rock_fight.stage == CURSED_ROCK_FIGHT_STAGE_PREPARATION then
            return 1
        end
    end)
    -- срабатывает, когда новый отряд появляется на поле боя.
    -- 1) Стадия подготовки.
    --  a) Определить позицию для перемещения фантома по данным из таблицы базовых стеков
    --  b) Удалить реальный стек
    --  c) Переместить фантом в позицию базового стека
    --  d) Перейти к следующему стеку
    AddCombatEvent(combat_event_add_creature, "GOG_M1_combat_event_cursed_rock_fight_new_stack_added",
    function(unit, side)
        if cursed_rock_fight.stage == CURSED_ROCK_FIGHT_STAGE_PREPARATION then
            if GetUnitSide(unit) == ATTACKER and cursed_rock_fight.current_creature_to_phantom ~= "" then
                print("<color=red>Event cursed_rock_add_creature: <color=green> ", unit, " added, ", cursed_rock_fight.current_creature_to_phantom, " must be removed")
                -- 1a.
                local x = cursed_rock_fight.replace_info[cursed_rock_fight.current_creature_to_phantom].x
                local y = cursed_rock_fight.replace_info[cursed_rock_fight.current_creature_to_phantom].y
                -- 1b.
                removeUnit(cursed_rock_fight.current_creature_to_phantom)
                while exist(cursed_rock_fight.current_creature_to_phantom) do
                    sleep()
                end
                -- 1c.
                repeat
                    sleep()
                until pcall(displace, unit, x, y)
                -- 1d.
                cursed_rock_fight.replace_info[cursed_rock_fight.current_creature_to_phantom] = nil
                cursed_rock_fight.current_creature_to_phantom = ""
            end
        end
    end)
end

-- поток, определяющий момент завершения боя.
function CursedRockFight_WinThread()
    local check = 1
    EnableAutoFinish(nil)
    while 1 do
        if not next(GetAttackerCreatures()) then
            Finish(DEFENDER)
        end
        if not next(GetDefenderCreatures()) then
            if check then
                AddCreature(ATTACKER, CREATURE_GREMLIN, 1)
                check = nil
            end
            Finish(ATTACKER)
        end
        sleep()
    end
end

-- старт.
-- 1) Сохранить инфу о базовых отрядах
-- 2) Убрать базовые отряды
-- 3) Вызвать существо, которое будет фантомить
function CursedRockFight_Start()
    -- 1.
    for i, creature in GetAttackerCreatures() do
        local cx, cy = pos(creature)
        cursed_rock_fight.replace_info[creature] = {type = GetCreatureType(creature),  count = GetCreatureNumber(creature), x = cx, y = cy}
    end
    -- 2.
    for creature, count in attacker_real_army do
        removeUnit(creature)
    end
    -- 3.
    local helper = "cursed_rock_fight_helper"
    local rock_x, rock_y = pos(GetDefenderCreatures()[0])
    if pcall(AddCreature, ATTACKER, HELPER, 10, rock_x, rock_y, nil, helper) then
        while not exist(helper) do
            sleep()
        end
    end
    --
end

-- ход рохи.
-- 1) Подготовительная стадия.
--  a) Пока не прошла предыдущая итерация перемещения фантомов, ждем.
--  b) Определяем следующее существо, которое будем фантомить
--  c) Если таких существ нет, переходим в следующую стадию боя.
--  d) Возвращаем на поле боя существо, которое будем фантомить, основываясь на ранее сохраненной инфе. 
--     Существо ставится в центр, чтобы не было проблем с фантомами из-за блоков.
--  e) Кастуем фантома на это существо и завершаем ход(на этой стадии роха ходит только, чтобы прокать нужный далее ивент)
function CursedRock_RockMove(creature, side)
    if cursed_rock_fight.stage == CURSED_ROCK_FIGHT_STAGE_PREPARATION then
        DisableCombat()
        -- 1a.
        while cursed_rock_fight.current_creature_to_phantom ~= "" do
            sleep()
        end
        -- 1b
        local curr_info
        for creature, info in cursed_rock_fight.replace_info do
            if info then
                cursed_rock_fight.current_creature_to_phantom = creature
                curr_info = info
                break
            end
        end
        -- 1c
        if not curr_info then
            EnableAutoFinish(nil)
            startThread(CursedRockFight_WinThread)
            cursed_rock_fight.stage = CURSED_ROCK_FIGHT_STAGE_ACTIVE
            EnableCombat()
            removeUnit("cursed_rock_fight_helper")
            return 1
        end
        -- 1d
        pcall(AddCreature, ATTACKER, curr_info.type, curr_info.count, 8, 8, nil, cursed_rock_fight.current_creature_to_phantom)
        while not exist(cursed_rock_fight.current_creature_to_phantom) do
            sleep()
        end
        print("<color=red>Cursed rock move: <color=green> ", cursed_rock_fight.current_creature_to_phantom, " added")
        -- 1e
        if pcall(UnitCastAimedSpell, "cursed_rock_fight_helper", SPELL_PHANTOM, cursed_rock_fight.current_creature_to_phantom) then
        end
        EnableCombat()
        commandDefend(creature)
        EndTurn(creature, 1)
        return 1
    end
end