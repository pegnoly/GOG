function CursedRockTest()
    GiveHeroSkill("Karlam", PERK_MAGIC_BOND)
    TeachHeroSpell("Karlam", SPELL_ARCANE_CRYSTAL)
    sleep()
    SetGameVar('cursed_rock_fight', '1')
    local rock_variant = seven_seals.GetRockVariant()
    if MCCS_StartCombat("Karlam", nil, 1, {rock_variant, 1}, 1, nil, nil, 1) then
    end
end