isfet_spec = {
    heroes = {"M2_Isfet", "M2_Isfet_Heroic"},
    ATTACKER = {
        already_accelerated_stacks = {}
    },
    DEFENDER = {
        already_accelerated_stacks = {}
    }
}

if contains(isfet_spec.heroes, GetHeroName(GetAttackerHero())) then
    AddCombatFunction(CombatFunctions.ATTACKER_CREATURE_MOVE, 
    function(creature)
        IsfetSpec_CreatureMove(creature, ATTACKER)
    end) 
end

if GetDefenderHero() and contains(isfet_spec.heroes, GetHeroName(GetDefenderHero())) then
    AddCombatFunction(CombatFunctions.DEFENDER_CREATURE_MOVE, 
    function(creature)
        IsfetSpec_CreatureMove(creature, DEFENDER)
    end) 
end

function IsfetSpec_CreatureMove(creature, side)
    if isfet_spec[side].already_accelerated_stacks[creature] then
        return
    end
    while combatReadyPerson() == creature do
        sleep()
    end
    setATB(creature, 1)
    playAnimation(creature, "happy", ONESHOT)
end