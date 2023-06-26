STANDALONE = 0
LAN        = 1

function GetMode()
  return (GetGameVar('IsHotseat') == 'true') and STANDALONE or LAN
end

function IsStandalone()
  return (GetGameVar('IsHotseat') == 'true')
end

function IsLAN()
  return (GetGameVar('IsHotseat') == '')
end

-- ��������� ���������� ���� ������� � �������
LVL_TO_SUMMON =
{
  2, 2, 3, 5, 7, 9, 12, 15, 18, 22, 26, 30, 35, 40, 45, 51, 58, 66, 74, 84, 96, 109, 120, 135, 150, 170, 190, 212, 235, 265, 300, 340, 380, 425, 475, 550, 630, 720, 850, 1000
}
-- ���������/���������� ��������������� �����
function DisableCombat()
  combatSetPause(1)
  EnableCinematicCamera(nil)
end

function EnableCombat()
  combatSetPause(nil)
  EnableCinematicCamera(1)
end

-- ������������ ������ setATB ����� return 1
function EndTurn(unit, newATB)
  while combatReadyPerson() == unit do
    sleep()
  end
  setATB(unit, newATB)
end

-- ����� ��������� ��������� ����� ������ �� ���� � ��������� ������� �����
function NewCreaturesAddToTablesThread()
  while 1 do
    while not combatReadyPerson() do
      sleep()
    end
    -- ����� ��������� ��� ������ �����
    local curr_unit = combatReadyPerson()
    -- ���������, ���� �� � ����� ������ ��������, �� ���������� � �������
    for i, unit in GetCreatures(ATTACKER) do
      local c
      for creature, count in attacker_army do
        if unit == creature then -- ����� ����������
          c = 1 -- �����
          break
        end
      end
      if not c then -- ���������� ���
        attacker_army[unit] = GetCreatureNumber(unit) -- �������� ����� � �������
        print(unit, ' added to attacker army table...')
        local copies = 0
        for i, table in attacker_army_copies do
          table[unit] = GetCreatureNumber(unit)
          copies = copies + 1
        end
        print('...and to all ', copies, ' copies...')
        -- ��������� ������ ���������� �������
        for i, event in combat_event_add_creature do
          print(i)
          event(unit, ATTACKER)
        end
      end
    end
    -- ���������� ��� ������� ������
    for i, unit in GetCreatures(DEFENDER) do
      local c
      for creature, count in defender_army do
        if unit == creature then
          c = 1
          break
        end
      end
      if not c then
        defender_army[unit] = GetCreatureNumber(unit)
        print(unit, ' added to defender army table...')
        local copies = 0
        for i, table in defender_army_copies do
          table[unit] = GetCreatureNumber(unit)
          copies = copies + 1
        end
        print('...and to all ', copies, ' copies...')
        --
        for i, event in combat_event_add_creature do
          event(unit, DEFENDER)
        end
		--
      end
    end
    -- ��������� ��������� ����
    while combatReadyPerson() == curr_unit do
      sleep()
    end
    -- ��������� ������ ��������� ����
    for i, event in combat_event_turn_end do
      for side = ATTACKER, DEFENDER do
        event(side)
      end
    end
    --
    sleep()
  end
end

-- ������� ����� ����� ����� ������� side
-- ���������� � ������� ��������� �� ������, �� ������ ����� ����� ������������ �� ������ ����������
-- ����������, ������� �������� ����� ����� ���������� �������
function NewArmyCopy(side, new_table)
  local tbl = side == ATTACKER and attacker_army or defender_army
  local copy_table = side == ATTACKER and attacker_army_copies or defender_army_copies
  table.copy(tbl, new_table)
  local l = length(copy_table)
  copy_table[l + 1] = new_table
end

-- ������������� ����
function InitRandom()
	local seed_t = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
	local seed = {}
	local shift = 0
	for side = 0, 1 do
		for j, unit in GetCreatures(side) do
			local type = GetCreatureType(unit)
			local num = GetCreatureNumber(unit)
			local x, y = pos(unit)
			local n = mod(type, 180) + 180 * (x + 14 * (y + 14 * mod(num, 200)))
			shift = shift + 7
			for i=1,24 do
				local bit = mod(n, 2)
				n = (n - bit) / 2
				local index = mod(shift + i, 24) + 1
				seed_t[index] = seed_t[index] ~= bit or 0
			end
		end
		local x = 0
		local p = 1
		for i=1,24 do
			x = x + p * seed_t[i]
			p = p * 2
		end
		for i=1,12 do
			seed_t[i], seed_t[25 - i] = seed_t[25 - i], seed_t[i]
		end
		seed[side+1] = x
		seed[side+3] = x
		seed[side+5] = x
	end
	print('PRNG seed = ' .. seed[1] .. ':' .. seed[2])
	random = NewPRNG(seed)
end

-- ���������, �������� �� � ����� �����-���� ����� �� ��������� ����� ������� side
function GetRealArmy(side)
  local tbl = side == ATTACKER and attacker_real_army or defender_real_army
  for unit, num in tbl do
    if GetCreatureNumber(unit) > 0 then
      return 1
    end
  end
  return nil
end

-- ������� ���� ����� ������� side �� ������ ��������� power �������
function GetArmyPower(side)
  local answer = 0
  for i, unit in GetCreatures(side) do
    answer = answer + GetCreaturePower(unit) * GetCreatureNumber(unit)
  end
  return answer
end

-- ������������ ���������� ����� ����� �������
function CheckDist(unit1, unit2)
  --print('<color=red>CheckDist: <color=green>', unit1, ', ', unit2)
  x1, y1 = pos(unit1)
  if IsWarMachine(unit1) or GetCreatureSize(unit1) == 2 then
    x1, y1 = x1 - 0.5, y1 - 0.5
  end
  x2, y2 = pos(unit2)
  if IsWarMachine(unit2) or GetCreatureSize(unit2) == 2 then
    x2, y2 = x2 - 0.5, y2 - 0.5
  end
  local dist1 = x2 - x1
  local dist2 = y2 - y1
  local answer = sqrt(dist1 * dist1 + dist2 * dist2)
  --print('dist: ', answer)
  return floor(answer)
end

-- ����������, ��� ���� (pX, pY) ��������� � �������� (root_x, root_y, root_x + px, root_y + py)
function IsUnitInPlace(root_x, root_y, px, py, unit)
  local ans = nil
  local max_x = root_x + px
  local max_y = root_y + py
  local x, y = pos(unit)
  if (x >= root_x and x <= max_x) and
     (y >= root_y and y <= max_y) then
    ans = 1
    return ans
  else
    return ans
  end
end

-- ����� ��������� �������� ���������� ������� �� ����� � ���������� ������������� ������ ������� side
-- ���������� ���������� �����, �������� ���������� ��� ����� area ������
function CheckArena(side)
  local x1, y1 = 1, 1
  local count = 0
  for y = 0, 15 do
    for x = 0, 15 do -- ��� ������ ����� �� ����
      local temp_count = 0
      for i, unit in GetCreatures(side) do -- ���������� ���� ������ �������
        if IsUnitInPlace(x, y, 3, 3, unit) then -- �� ������� ��������� � ������� 4�4, � ������ �������� ����� x,y
          temp_count = temp_count + 1 -- ������� ��������� � ������� �������
        end
      end
      if temp_count > count then -- ���� ����� ��������� ��������� ������� ������������
        count = temp_count -- ��������� ������������
        x1 = x + 1 -- ������������� ��������� ���������� ��� �����������
        y1 = y + 1
      end
    end
  end
  return x1, y1
end