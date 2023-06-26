--------------------------------------------------------------------------------
-- ������ ������ ������� ��� 4 ������
--

--------------------------------------------------------------------------------
-- ������ ��������� �������� �������(����� "�������� ��������")

-- ��� ������ ����� ��������� �������� �����������
function FireUnitSavePower(unit)
  if ((not enemy_real_army[unit]) or (GetCreatureType(unit) == CREATURE_FIRE_ELEMENTAL)) then return end
  local x, y = pos(unit)
  local elem_count = (enemy_real_army[unit] * GetCreaturePower(unit)) / 829
  local name = unit..'_fire'
  if pcall(SummonCreature, enemy_side, CREATURE_FIRE_ELEMENTAL, number, x, y, 1, name) then-- ��������� �����������
    repeat sleep() until exist(name)
  end
end

-- ������� �������: ����� ������ - ������ � ������ ������������ ������� ������
if ((GetHeroName(GetHero(player_side)) == Karlam) and ((GetGameVar('fire_ring') + 0) == 1)) then
  AddCombatFunction(CombatFunctions.START,
  function()
    EnableAutoFinish(nil)
    startThread(
    function()
      while 1 do
        if not next(GetCreatures(player_side)) then
          Finish(enemy_side)
        end
        if not next(GetCreatures(enemy_side)) then
          sleep(200) -- ������� ��������, ����� ��������� ���� ����� ���������
          if not next(GetCreatures(enemy_side)) then
            Finish(player_side)
          end
        end
        sleep()
      end
    end)
  end)
  if enemy_side == ATTACKER then
    AddCombatFunction(CombatFunctions.ATTACKER_CREATURE_DEATH, FireUnitSavePower)
  else
    AddCombatFunction(CombatFunctions.DEFENDER_CREATURE_DEATH, FireUnitSavePower)
  end
end
--
--------------------------------------------------------------------------------
--
--------------------------------------------------------------------------------
-- ��������� ������

veil_line = 8
cat_msg = 0
