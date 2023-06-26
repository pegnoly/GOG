print('post: ', GetGameVar('post') + 0)
if not ((GetGameVar('post') + 0) > 0) then return end

post_armies =
{
  {
    {types = {CREATURE_WAR_DANCER}, num = 25 * diff, x = 15, y = 7},
    {types = {CREATURE_GRAND_ELF, CREATURE_SHARP_SHOOTER}, num = 15 + 8 * diff, x = 15, y = 2},
    {types = {CREATURE_GRAND_ELF, CREATURE_SHARP_SHOOTER}, num = 20 + 6 * diff, x = 15, y = 4},
    {types = {CREATURE_DRUID_ELDER}, num = 10 + 5 * diff, x = 15, y = 3},
    {types = {CREATURE_WAR_UNICORN}, num = 5 + 3 * diff, x = 14, y = 9},
    {types = {CREATURE_TREANT_GUARDIAN}, num = 2 * diff, x = 13, y = 3},
  },

  {
    {types = {CREATURE_SPRITE}, num = 30 + 45 * diff, x = 13, y = 4},
    {types = {CREATURE_DRYAD}, num = 55 + 30 * diff, x = 13, y = 10},
    {types = {CREATURE_GRAND_ELF}, num = 25 + 8 * diff, x = 15, y = 9},
    {types = {CREATURE_SHARP_SHOOTER}, num = 15 + 9 * diff, x = 15, y = 8},
    {types = {CREATURE_HIGH_DRUID}, num = 10 + 7 * diff, x = 14, y = 9},
    {types = {CREATURE_DRUID_ELDER}, num = 15 + 5 * diff, x = 14, y = 8},
    {types = {CREATURE_WAR_UNICORN}, num = 8 + 3 * diff, x = 13, y = 6},
    {types = {CREATURE_ANGER_TREANT}, num = 3 * diff, x = 13, y = 7},
  },

  {
    {types = {CREATURE_DRYAD}, num = 85 + 36 * diff, x = 12, y = 2},
    {types = {CREATURE_GRAND_ELF}, num = 35 + 10 * diff, x = 15, y = 3},
    {types = {CREATURE_TREANT_GUARDIAN}, num = 3 + diff, x = 10, y = 1},
    {types = {CREATURE_ANGER_TREANT}, num = 2 * diff, x = 8, y = 5},
    {types = {CREATURE_TREANT}, num = 4 + (1.5 * diff), x = 8, y = 10},
    {types = {CREATURE_ANGER_TREANT}, num = 1 + 2 * (DIFF == 0 and 1 or DIFF), x = 10, y = 14},
    {types = {CREATURE_GOLD_DRAGON}, num = diff, x = 12, y = 7}
  }
}

AddCombatFunction(CombatFunctions.START,
function()
  EnableAutoFinish(nil)
  for i, unit in GetCreatures(DEFENDER) do
    removeUnit(unit)
    repeat
      sleep()
    until not exist(unit)
  end
  local post = GetGameVar('post') + 0
  for i, unit in post_armies[post] do
    AddCreature(DEFENDER, GetRandFromT(unit.types), unit.num, unit.x, unit.y, nil)
  end
  sleep()
  EnableAutoFinish(1)
end)