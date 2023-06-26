spec_demonic_charge =
{
  heroes = {"Horrtag"},
  [ATTACKER] = {},
  [DEFENDER] = {}
}

function SpecDemonicCharge_AddUnit(creature, side)
  if spec_demonic_charge[side].inferno_units_to_charge and (GetCreatureTown(creature) == TOWN_INFERNO) then
    spec_demonic_charge[side].inferno_units_to_charge[creature] = 1
  end
end


function SpecDemonicCharge_CreatureMove(creature, side)
  if spec_demonic_charge[side].inferno_units_to_charge[creature] then
    startThread(
    function()
      while combatReadyPerson() == %creature do
        sleep()
      end
      spec_demonic_charge[%side].inferno_units_to_charge[%creature] = nil
      SetATB(%creature, 1)
    end)
  end
end

AddCombatEvent(combat_event_add_creature, 'spec_demonic_charge_add_creature', SpecDemonicCharge_AddUnit)

if contains(spec_demonic_charge.heroes, GetHeroName(GetAttackerHero())) then
   spec_demonic_charge[ATTACKER] =
   {
     inferno_units_charged = {},
   }
   AddCombatFunction(CombatFunctions.ATTACKER_CREATURE_MOVE,
   function(creature)
     SpecDemonicCharge_CreatureMove(creature, ATTACKER)
   end)
end
if GetDefenderHero() and contains(spec_demonic_charge.heroes, GetHeroName(GetDefenderHero())) then
   spec_demonic_charge[DEFENDER] =
   {
     inferno_units_charged = {},
   }
   AddCombatFunction(CombatFunctions.DEFENDER_CREATURE_MOVE,
   function(creature)
     SpecDemonicCharge_CreatureMove(creature, DEFENDER)
   end)
end