umino_spec_combat = {
    heroes = {"Umino"},
    base_atb_shift = 0.15,
    atb_shift_per_level = 0.1,
    [ATTACKER] = {
        level = 0
    },
    [DEFENDER] = {
        level = 0
    }
}

if GetAttackerHero() and contains(umino_spec_combat.heroes, GetHeroName(GetAttackerHero())) then
    umino_spec_combat[ATTACKER].level = GetGameVar(GetHeroName(GetAttackerHero()).."_lvl") + 0
    AddCombatFunction(CombatFunctions.ON_SPELL_CAST, "umino_spec_multishot_detect_attacker",
    function (caster, spell, _)
        UminoSpec_DetectMultishotCast(caster, spell, ATTACKER)
    end)
end

if GetDefenderHero() and contains(umino_spec_combat.heroes, GetHeroName(GetDefenderHero())) then
    umino_spec_combat[DEFENDER].level = GetGameVar(GetHeroName(GetDefenderHero()).."_lvl") + 0
    AddCombatFunction(CombatFunctions.ON_SPELL_CAST, "umino_spec_multishot_detect_defender",
    function (caster, spell, _)
        UminoSpec_DetectMultishotCast(caster, spell, DEFENDER)
    end)
end

function UminoSpec_DetectMultishotCast(caster, spell, side)
    if caster == GetHero(side) and spell == 61 then -- multishot doesn't have constant
        print("Umino casted multishot...")
        EndTurn(GetHero(side), umino_spec_combat.base_atb_shift + umino_spec_combat.atb_shift_per_level * umino_spec_combat[ATTACKER].level)
    end
end