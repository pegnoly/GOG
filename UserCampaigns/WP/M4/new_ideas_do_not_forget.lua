--------------------------------------------------------------------------------
-- из квеста на разрушение завесы - непосредственно бой и разрушение
-- известные проблемы:
--  - цвет эффекта разрушения(не проблема, по факту)
--  - положение стены на арене(не сильная проблема, но лучше решить - разобраться, как работает placement в loc-объектах)
Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'necro_wall', 'DestroyNecroWall')

function DestroyNecroWall(hero, region)
  BlockGame()
  PlayFX('Unholy_word', hero)
  sleep(25)
  if RemoveHeroAliveCreatures(hero) then
    MessageBox(rtext('Излучение Пелены Тьмы уничтожает ваших живых солдат!'))
  end
  UnblockGame()
  sleep()
  if StartCombat(hero, nil, 1, 1, 1,
                 nil, nil, ARENAS.NECRO_BARRIER, nil) then
    Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'necro_wall', nil)
    PlayFX('Necro_wall_destroy', 'IlshamAggar', '', 25, 1, 0, 90)
    sleep()
    StopVisualEffects('necro_wall')
  end
end

function RemoveHeroAliveCreatures(hero)
  local removed = {}
  for slot = 0, 6 do
    local creature, count = GetObjectArmySlotCreature(hero, slot)
    if not(creature == 0 or count == 0) then
      if (not removed[creature]) and
         (not((GetCreatureTown(creature) == TOWN_NECROMANCY) or
               contains(ELEMS, creature) or
               contains(CONSTRUCTS, creature) or
               contains(NEUTRAL_UNDEAD, creature))) then
        count = GetObjectCreatures(hero, creature)
        removed[creature] = count
      end
    end
  end
  if length(removed) == 0 then
    return nil
  else
    for creature, count in removed do
      RemoveHeroCreatures(hero, creature, count)
    end
    return 1
  end
end

--------------------------------------------------------------------------------
--

Touch.DisableObject('utopia_01')
Touch.SetFunction('utopia_01', '_u_fight',
function(hero, object)
  if StartCombat(hero, nil, 3,
                 GetRandFrom_E(nil, CREATURE_BLACK_DRAGON, CREATURE_ACIDIC_DRAGON, CREATURE_ACIDIC_DRAGON), 30,
                 GetRandFrom_E(nil, CREATURE_BLACK_DRAGON, CREATURE_RED_DRAGON, CREATURE_ACIDIC_DRAGON), 30,
                 GetRandFrom_E(nil, CREATURE_BLACK_DRAGON, CREATURE_RED_DRAGON, CREATURE_ACIDIC_DRAGON), 30) then
  print('test E ok')
  end
end)