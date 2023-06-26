--------------------------------------------------------------------------------
-- ������������� ������ - �������� ����. ������� ������� - ������ ��������� � ���(�� �� � 1 ������)

if not (GetPlayerHeroName() == Noelli or GetEnemyHeroName() == Noelli) then return end

noe_side = GetHeroName(GetAttackerHero()) == Noelli and ATTACKER or DEFENDER -- �������, �� ������� ��������� ������
noe_witches_count = GetGameVar('noe_spec_witches_count') + 0 -- ����� �����, ������� ������ ���� ��������
noe_current_kills = GetGameVar('noe_spec_current_kills') + 0 -- ������� ����� �������, ����������� �������� ������� ������
--noe_current_up    = GetGameVar('noe_spec_current_up') + 0
noe_kills_to_up   = GetGameVar('noe_spec_kills_to_up') + 0 -- ����� ������� �� ��������� ������ �����
noe_last_unit = '' -- ��������� ��������, ����������� ���
-- ���� ������� ������� �� - ����� �����������(�� ���� ����� ����� ���������� ���������� ���)
noe_witches_types = {CREATURE_WITCH, CREATURE_BLOOD_WITCH, CREATURE_BLOOD_WITCH_2, CREATURE_MATRON, CREATURE_MATRIARCH, CREATURE_SHADOW_MISTRESS, 335, 367}

-- ������ ����� � ������ ���
function WitchesSummon()
  local x, y = 0
  if noe_side == ATTACKER then
    x, y = 2, 2
  else
    x, y = 11, 11
  end
  pcall(SummonCreature, noe_side, CREATURE_MATRIARCH, noe_witches_count, x, y, 1, 'noe_witch')
end

-- ��� ������ �������� ��������� �������, �����������, ��� ��� ������ � �����
function CheckWitchesKilledUnit(unit)
  -- ���� ��� �������� ������
  if GetUnitSide(noe_last_unit) == noe_side then
    local type = GetCreatureType(noe_last_unit)
    -- � ������ � ����� �������
    if contains(noe_witches_types, type) then
      -- �������� ����� �������
      noe_current_kills = noe_current_kills + 1
      local msg = '+1 ��������. '
      -- ���� �� �������� ������ ������ �����
      if noe_current_kills < noe_kills_to_up then
        -- ������ ������� ����� �������
        msg = msg..noe_current_kills..' �� '..noe_kills_to_up..' �� ������ �����.'
      -- ����� �������?
      elseif noe_current_kills == noe_kills_to_up then
        -- �������� ������� ��������
        noe_current_kills = 0
        -- ���������� ����� ������� �� ���������� ������
        noe_kills_to_up = noe_kills_to_up + noe_kills_to_up / 2
        -- ���������� �� � ���������� ����������
        SetGameVar('noe_spec_kills_to_up', noe_kills_to_up)
        SetGameVar('noe_spec_witches_count', noe_witches_count + 1)
        msg = msg..'������� ����� �������!'
      end
      startThread(CombatFlyingSign, rtext(msg), GetHero(noe_side), 60.0)
      SetGameVar('noe_spec_current_kills', noe_current_kills)
    end
  end
end

function SaveUnit(unit)
  if IsCreature(unit) then
    noe_last_unit = unit
  end
end

AddCombatFunction(CombatFunctions.START, WitchesSummon)
AddCombatFunction(CombatFunctions.UNIT_MOVE, SaveUnit)
AddCombatFunction(CombatFunctions[noe_side == ATTACKER and 'DEFENDER_CREATURE_DEATH' or 'ATTACKER_CREATURE_DEATH'], CheckWitchesKilledUnit)