KARLAM_SPEC_STATE_NO_SPECIAL_STATE = 0
KARLAM_SPEC_STATE_BOND_ASSIGNED_THIS_TURN = 1
KARLAM_SPEC_STATE_DUPLICATED_THIS_TURN = 2

while not KARLAM_SPEC_STATE_DUPLICATED_THIS_TURN do
    sleep()
end

karlam_spec = {
    heroes = {"Karlam"},
    [ATTACKER] = {
        magic_bond_target = ""
    },
    [DEFENDER] = {
        magic_bond_target = ""
    },
    state = KARLAM_SPEC_STATE_NO_SPECIAL_STATE
}


if contains(karlam_spec.heroes, GetHeroName(GetAttackerHero())) then
    EnableCinematicCamera(nil)
    AddCombatFunction(CombatFunctions.ON_SPELL_CAST, "karlam_spec_on_spell_cast",
    function (caster, spell, target)
        if spell == 63 then
            AssignMagicBondTarget(caster, spell, target)
        end
        if karlam_spec.state == KARLAM_SPEC_STATE_NO_SPECIAL_STATE then
            --print("No special state of karlam's spec, trying to duplicate")
            DuplicateCast(caster, spell, target)
        else
            --print("Some special state of karlam's spec: ", karlam_spec.state, ", returning")
            karlam_spec.state = KARLAM_SPEC_STATE_NO_SPECIAL_STATE
            return
        end
    end)
end

function AssignMagicBondTarget(caster, spell, target)
    if IsHero(caster) and contains(karlam_spec.heroes, GetHeroName(caster)) then
        if spell == 63 then
            ---@type CombatSide
            local side = GetUnitSide(caster)
            karlam_spec[side].magic_bond_target = target
            karlam_spec.state = KARLAM_SPEC_STATE_BOND_ASSIGNED_THIS_TURN
            print("Magic bond casted on ", target)
        end
    end
end

function DuplicateCast(caster, spell, target)
    if IsHero(caster) and contains(karlam_spec.heroes, GetHeroName(caster)) then
        ---@type CombatSide
        local side = GetUnitSide(caster)
        if karlam_spec[side].magic_bond_target ~= "" then
            local bond_target = karlam_spec[side].magic_bond_target
            ---@type SpellSchoolType
            local spell_school = Spell.Params.School(spell)
            if spell_school == MAGIC_SCHOOL_DESTRUCTIVE then
                SetUnitManaPoints(caster, 4)
                while GetUnitManaPoints(caster) ~= 4 do
                    sleep()
                end
                local duplicate_target = ""
                for i, creature in GetCreatures(1 - side) do
                    if creature ~= target and creature ~= bond_target then
                        duplicate_target = creature
                        break
                    end
                end
                pcall(UnitCastAimedSpell, caster, spell, duplicate_target)
                CombatFlyingSign(rtext("Duplicated"), duplicate_target, 15)
                karlam_spec.state = KARLAM_SPEC_STATE_DUPLICATED_THIS_TURN
                return
            end
        end
    end
end