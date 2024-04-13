-- @combat_script -- 
-- Кампания: Игры богов.
-- Миссия: Эльф и его тень.
-- Бой: Эффект крови искаженной рохи.

if GetGameVar(GetHeroName(GetAttackerHero()).."_rock_blood_used") == "1" then
    AddCombatFunction(CombatFunctions.START,
    function()
        startThread(CursedRockBloodEffect_Start, ATTACKER)
    end)
end

if GetDefenderHero() and GetGameVar(GetHeroName(GetDefenderHero()).."_rock_blood_used") == "1" then
    AddCombatFunction(CombatFunctions.START,
    function()
        startThread(CursedRockBloodEffect_Start, DEFENDER)
    end)
end

function CursedRockBloodEffect_Start(side)
    local helper = "cursed_rock_blood_effect_helper_"..side
    if pcall(AddCreature, side, HELPER, 100, -1, -1, nil, helper) then
        while not exist(helper) do
            sleep()
        end
        for i, creature in GetCreatures(side) do
            pcall(UnitCastAimedSpell, helper, SPELL_REGENERATION, creature)
        end
        sleep(10)
        removeUnit(helper)
        while exist(helper) do
            sleep()
        end
    end
end