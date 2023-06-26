-- @combat_script -- 
-- Кампания: Игры богов.
-- Миссия: Эльф и его тень.
-- Бой: Ноэлли.

noellie_fight =
{
    path = m_path.."Combat/NoellieFight/",
    -- информация о местах призыва ведьм
    witches_info =
    {
        ['witch1'] = {type = CREATURE_MATRON, x = 8,  y = 4},
        ['witch2'] = {type = CREATURE_MATRIARCH, x = 9,  y = 2},
        ['witch3'] = {type = CREATURE_SHADOW_MISTRESS, x = 8,  y = 11},
    },
    -- ход, на котором ведьма применяет энергетический канал
    channel_cast_turn = 5 - diff,
    -- текущий счетчик ходов до каста канала
    current_channel_cast_turn = 0,
    
    -- текущий раунд кастов хаоса
    chaos_spell_round = 1,
    -- прогресс раунда кастов при каждом ходе Ноэлли
    chaos_spell_round_progress = DIFF == DIFFICULTY_HEROIC and 0.6 or 0.4,
    -- спеллы, которые можно кастовать на конкретном раунде
    chaos_spells_groups = 
    {
        [1] = {SPELL_LIGHTNING_BOLT, SPELL_ICE_BOLT, SPELL_EMPOWERED_MAGIC_ARROW, SPELL_EMPOWERED_STONE_SPIKES},
        [2] = {SPELL_EMPOWERED_ICE_BOLT, SPELL_EMPOWERED_LIGHTNING_BOLT, SPELL_FIREBALL, SPELL_EMPOWERED_FROST_RING},
        [3] = {SPELL_EMPOWERED_FIREBALL, SPELL_METEOR_SHOWER, SPELL_FIREWALL, SPELL_EMPOWERED_CHAIN_LIGHTNING},
        [4] = {SPELL_IMPLOSION, SPELL_EMPOWERED_METEOR_SHOWER}
    },

    -- флаг активности хода Ноэлли
    noellie_turn_active = 0,
    -- позиция на атб, в которую отправляется Ноэлли после каста
    noellie_atb_return_factor = 0.3 + 0.03 * diff
}

-- призыв ведьм
function NoellieFight_SummonWitches()
    DisableCombat()
    pcall(SummonCreature, DEFENDER, CREATURE_COVEN_LEADER, 8 + 2 * diff, 9, 13, 1, "coven_leader")
    while not exist("coven_leader") do
        sleep()
    end
    SetUnitManaPoints("coven_leader", 100)
    sleep(200)
    local msg_rnd = random(3)
    startThread(CombatFlyingSign, noellie_fight.path.."coven_leader_witches_summon_"..msg_rnd..".txt", "coven_leader", 30.0)
    playAnimation("coven_leader", "specability", ONESHOT)
    sleep(30)
    for witch, info in noellie_fight.witches_info do
        if not exist(witch) then
            pcall(SummonCreature, DEFENDER, info.type, 8 + 2 * diff, info.x, info.y, 1, witch)
        end
    end
    EnableCombat()
end

-- ход существа Ноэлли
-- 1) Обновить ману ведьмам.
-- 2) Если ходит глава ковена - обновить число ходов до каста канала, и если нужный ход наступил, скастовать канал.
function NoellieFight_NoellieCreatureMove(creature, side)
    -- 1.
    if contains(keys(noellie_fight.witches_info), creature) then
        SetUnitManaPoints(creature, GetUnitMaxManaPoints(creature))
    end
    -- 2.
    if creature == "coven_leader" then
        noellie_fight.current_channel_cast_turn = noellie_fight.current_channel_cast_turn + 1
        if noellie_fight.current_channel_cast_turn == noellie_fight.channel_cast_turn then
            startThread(CombatFlyingSign, noellie_fight.path.."coven_leader_power_feed_cast.txt", "coven_leader", 30.0)
            pcall(commandDoSpecial, creature, SPELL_ABILITY_POWER_FEED)
            return 1
        end
    end
end

-- ход Ноэлли
-- 1) Прибавить прогресс раунда кастов. Если дошли до 4 раунда, больше не прогрессировать.
-- 2) Определить спелл для каста на текущем ходу и его тип.
-- 3) Спелл направленный:
--  a) Определить 3 стека с самой большой текущей силой
--  b) Скастовать спелл на случайный из них
-- 4) Спелл площадной - скастовать его в самое большое скопление войск игрока.
function NoellieFight_NoellieMove(hero)
    --
    if noellie_fight.noellie_turn_active == 0 then
        noellie_fight.noellie_turn_active = 1
    else
        noellie_fight.noellie_turn_active = 0
        return 1
    end
    --
    local side = 1 - GetUnitSide(hero)
    -- 1.
    noellie_fight.chaos_spell_round = noellie_fight.chaos_spell_round + noellie_fight.chaos_spell_round_progress
    local current_round = floor(noellie_fight.chaos_spell_round)
    if current_round >= 4 then
        current_round = 4
    end
    print("<color=red>Noellie fight:<color=green>: current round iteration ", noellie_fight.chaos_spell_round, ", actual round ", current_round)
    -- 2.
    local spell = GetRandFromT(noellie_fight.chaos_spells_groups[current_round])
    local spell_type = GetSpellType(spell)
    print("<color=red>Noellie fight:<color=green>: casting spell ", spell)
    -- 3.
    if spell_type == AIMED then
        local creature_to_cast = ""
        local current_powers = {}
        for i, creature in GetCreatures(side) do
            current_powers[creature] = GetCreaturePower(creature) * GetCreatureNumber(creature)
        end
        local stacks_to_select, n = {}, 0
        -- 3a.
        while n <= (len(GetCreatures(side)) >= 3 and 3 or len(GetCreatures(side))) do
            local current_max_power = -1
            local stack_with_max_power = ""
            for stack, power in current_powers do
                if stack and power and power > current_max_power then
                    current_max_power = power
                    stack_with_max_power = stack
                end
            end
            n = n + 1
            stacks_to_select[n] = stack_with_max_power
            current_powers[stack_with_max_power] = nil
            sleep()
        end
        print("<color=red>Noellie fight:<color=green>: targets for spell ", stacks_to_select)
        -- 3b.
        creature_to_cast = GetRandFromT(stacks_to_select)
        if pcall(UnitCastAimedSpell, hero, spell, creature_to_cast) then
            EndTurn(hero, noellie_fight.noellie_atb_return_factor)
            return 1
        else
            return nil
        end
    else
        -- 4.
        local x, y = CheckArena(side)
        if pcall(UnitCastAreaSpell, hero, spell, x, y) then
            EndTurn(hero, noellie_fight.noellie_atb_return_factor)
            return 1
        else 
            return nil
        end
    end
    return 1
end

if GetDefenderHero() and GetHeroName(GetDefenderHero()) == "Noellie" then
    AddCombatFunction(CombatFunctions.START,
    function()
        startThread(NoellieFight_SummonWitches)
    end)
    --
    AddCombatFunction(CombatFunctions.UNIT_MOVE,
    function(unit)
        if unit ~= GetDefenderHero() and noellie_fight.noellie_turn_active == 1 then
            noellie_fight.noellie_turn_active = 0
        end
    end)
    --
    AddCombatFunction(CombatFunctions.DEFENDER_CREATURE_MOVE,
    function(creature)
        NoellieFight_NoellieCreatureMove(creature, DEFENDER)
    end)
    --
    AddCombatFunction(CombatFunctions.DEFENDER_HERO_MOVE, NoellieFight_NoellieMove)
end
