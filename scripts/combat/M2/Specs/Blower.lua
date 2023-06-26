spec_blower =
{
  heroes = {"Demrog"},
  timer_lvl_divisor = 4,
  mine_num_lvl_divisor = 3,
  [ATTACKER] = {},
  [DEFENDER] = {}
}

function SpecBlower_HeroMove(hero, side)
  if spec_blower[side].cast_timer < 1 then
    local mines_num = ceil(spec_blower[side].lvl / spec_blower.mine_num_lvl_divisor)
    local enemy_stack_count = length(GetCreatures(1 - side))
    if mines_num < enemy_stack_count then
      mines_num = enemy_stack_count
    end
    local curr_mana = GetUnitManaPoints(hero)
    SetUnitManaPoints(hero, curr_mana + 100)
    while GetUnitManaPoints(hero) ~= (curr_mana + 100) do
      sleep()
    end
    local already_casted_creatures = {}
    while mines_num ~= 0 do
      local creature = GetRandFromT_ETbl(already_casted_creatures, GetCreatures(1 - side))
      local x, y = pos(creature)
      pcall(UnitCastAreaSpell, hero, SPELL_LAND_MINE, x, y)
      already_casted_creatures[len(already_casted_creatures) + 1] = creature
      mines_num = minus_num - 1
      sleep()
    end
    SetUnitManaPoints(hero, curr_mana)
  else
    spec_blower[side].cast_timer = spec_blower[side].cast_timer - 1
  end
end