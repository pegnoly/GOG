-- добавить настройку опыта, артов и статов при найме и паверапе!!!

enemy =
{
  p2_all_heroes = {'Gles', 'Nemor', 'Straker', 'Tamika', 'Aberrar', 'Effig', 'Pelt', 'Merikh', 'Zenda', 'Scata', 'Quamar', 'Gutbert'},
  
  active_heroes =
  {
    [BlackHand] = {days_alive = 0, death_timeout = 0, hire_count = 0},
    [BlueHand]  = {days_alive = 0, death_timeout = 0, hire_count = 0},
    [GreenHand] = {days_alive = 0, death_timeout = 0, hire_count = 0},
  },
  
  defenders = {},
  
  respawn_q = {},
  freeze_q_flag = 0,
  
  max_active_heroes = 6,
  active_warriors = 0,
  active_hit_runners = 0,
  
  towns = {'IlshamAggar', 'Lernur', 'Freymia', 'Crianna', 'Castlecross', 'Carn'},
--  d_p_rot = {['IlshamAggar_deploy_point'] = 90, ['Lernur_deploy_point'] = 90, ['Freymia_deploy_point'] = 180,
--             ['Crianna_deploy_point'] = 0, ['Castlecross_deploy_point'] = 180, ['Carn_deploy_point'] = 270},
  
  death_max_timeout = 6 - diff, -- 11 - diff
  
  army_grow = {30 + 16 * diff, 20 + 11 * diff, 13 + 7 * diff, 9 + 4 * diff, 5 + 2.5 * diff, 3 + 1.5 * diff, 1 + diff},
  def_grow  = {22 + 13 * diff, 16 + 10 * diff, 12 + 6 * diff, 7 + 4 * diff, 4 + 2 * diff, 2 + 1.5 * diff, 1 + diff},
  stat_grow = {2, 4, 5, 3},
  
  alt_grade_prock_chance = 35 + 10 * diff
}

function BlockTownsGarrisons(param)
  for i, town in enemy.towns do
    if not (GetObjectOwner(town) == PLAYER_1) then
      BlockTownGarrisonForAI(town, param)
    end
  end
end

function Player2SortHeroes()
  local n = 12
  while n > 5 do
    local temp = random(n) + 1
    enemy.active_heroes[enemy.p2_all_heroes[temp]] = {days_alive = 0, death_timeout = 0, hire_count = 0}
    table.insert(enemy.respawn_q, enemy.p2_all_heroes[temp])
    enemy.p2_all_heroes = table.remove(enemy.p2_all_heroes, temp)
    n = n - 1
  end
  print('defenders: ')
  enemy.defenders = table.copy(enemy.p2_all_heroes, enemy.defenders)
  table.print(enemy.defenders)
  print('respawn queue: ')
  table.print(enemy.respawn_q)
end

function Player2RespawnThread()
  while 1 do
    while not IsPlayerCurrent(PLAYER_2) do
      sleep()
    end
    --
    if length(enemy.respawn_q) == 0 then
      print('Player2Respawn: Нет героев, доступных для воскрешения, ждем следующий ход')
      repeat
        sleep()
      until not IsPlayerCurrent(PLAYER_2)
    else
      local resp_possible_count = (enemy.max_active_heroes + 1) - length(GetPlayerHeroes(PLAYER_2))
      resp_possible_count = resp_possible_count > 3 and 3 or resp_possible_count
      print('Число доступных воскрешений: ', resp_possible_count)
      local possible_points, n = {}, 0
      for i, town in enemy.towns do
        local owner = GetObjectOwner(town)
        if owner > PLAYER_1 and owner <= PLAYER_4 then
          n = n + 1
          possible_points[n] = town..'_deploy_point'
        end
      end
      -- подогнать число респаунов к числу точек(опционально)
      if resp_possible_count > length(possible_points) then
        resp_possible_count = length(possible_point)
      end
      --
      while resp_possible_count > 0 and length(possible_points) > 0 and length(enemy.respawn_q) > 0 do
        print('Герои для воскрешения: ')
        table.print(enemy.respawn_q)
        print('Точки: ')
        table.print(possible_points)
        local r_h = random(length(enemy.respawn_q)) + 1
        local r_p = random(length(possible_points)) + 1
        local _hero, _point = enemy.respawn_q[r_h], possible_points[r_p]
        print('Воскрешение героя ', _hero, ' в точке ', _point)
        if _hero and _point then
          if pcall(DeployReserveHero, _hero, RegionToPoint(_point)) then
            resp_possible_count = resp_possible_count - 1
            enemy.respawn_q = table.remove(enemy.respawn_q, r_h)
            possible_points = table.remove(possible_points, r_p)
--            enemy.freeze_q_flag = 1
--            while enemy.freeze_q_flag == 1 do
--              sleep()
--            end
          end
        end
      end
      repeat
        sleep()
      until not IsPlayerCurrent(PLAYER_2)
    end
    sleep()
  end
end

-- поток респауна Синей и Зеленой Руки, если может реснуться один, ресаются оба
function HandsRespawnThread()
  while 1 do
    while not IsPlayerCurrent(PLAYER_2) do
      sleep()
    end
    if not IsHeroAlive(BlueHand) and enemy.active_heroes[BlueHand].death_timeout == 0 then
      DeployReserveHero(BlueHand, RegionToPoint('bh_deploy_point'))
      if not IsHeroAlive(GreenHand) then
        enemy.active_heroes[GreenHand].death_timeout = 0
        DeployReserveHero(GreenHand, RegionToPoint('gh_deploy_point'))
      end
    end
    if not IsHeroAlive(GreenHand) and enemy.active_heroes[GreenHand].death_timeout == 0 then
      DeployReserveHero(GreenHand, RegionToPoint('gh_deploy_point'))
      if not IsHeroAlive(BlueHand) then
        enemy.active_heroes[BlueHand].death_timeout = 0
        DeployReserveHero(BlueHand, RegionToPoint('bh_deploy_point'))
      end
    end
    repeat
      sleep()
    until not IsPlayerCurrent(PLAYER_2)
    sleep()
  end
end

-- обновление инфы о прожитых днях/кулдауне воскрешения -> в триггер нового дня
function UpdateNecrosInfo()
  for hero, info in enemy.active_heroes do
    if info.days_alive > 0 then
      info.days_alive = info.days_alive + 1
    end
    if info.death_timeout > 0 then
      info.death_timeout = info.death_timeout - 1
      if info.death_timeout == 0 and hero ~= BlueHand and hero ~= GreenHand then
        table.insert(enemy.respawn_q, hero)
        print(hero, ' ready to respawn')
      end
    end
  end
end

-- функция найма новых некров
function NewNecroHire(hero, thread)
  --
  if hero == Naadir or contains(enemy.defenders, hero) then
    print('ADD_HERO_TRIGGER: defender, so skip default setup')
    return
  end
  --
  if not thread then
    startThread(NewNecroHire, hero, 1)
    return
  end
  --
  --EnableHeroAI(hero, nil) -- временно выключаем ИИ, чтобы избежать некоторых проблем с настройками армии
  EnemyHeroArmySetup(hero, enemy.army_grow) -- базовая настройка армии
  sleep()
  -- настройка Черной Руки - отдельно
  if hero == BlackHand then
    ChangeHeroStat(hero, STAT_EXPERIENCE, LEVELS[31 + diff])
    for stat = STAT_ATTACK, STAT_KNOWLEDGE do
      ChangeHeroStat(hero, stat, ceil(GetHeroStat(hero, stat) * (0.3 + 0.05 * diff)))
    end
    sleep(10)
    EnableHeroAI(hero, nil)
    SetHeroRoleMode(hero, HERO_ROLE_MODE_HERMIT)
    SetObjectPosition(hero, GetObjectPosition('IlshamAggar'))
  else
    -- Синяя и Зеленая Рука так же отдельно
    if hero == BlueHand or hero == GreenHand then
      SetHeroRoleMode(hero, HERO_ROLE_MODE_HERMIT)
      -- дополнительно накручиваются статы
      for stat = STAT_ATTACK, STAT_KNOWLEDGE do
        ChangeHeroStat(hero, stat, floor(GetHeroStat(hero, stat) * (0.1 + 0.05 * diff)))
      end
      for slot = 0, 6 do
        local creature, count = GetObjectArmySlotCreature(hero, slot)
        if not(creature == 0 or count == 0) then
          AddHeroCreatures(hero, creature, ceil(count * (0.4 + 0.1 * DIFF))) -- и войска
        end
      end
    else -- для обычных героев
      if enemy.active_heroes[hero].hire_count > 0 then
        print(hero, ' hired again...')
        -- добавляем немного опыта и статов
        ChangeHeroStat(hero, STAT_EXPERIENCE, 4000 * diff * time.week)
        for stat = STAT_ATTACK, STAT_KNOWLEDGE do
          ChangeHeroStat(hero, stat, enemy.stat_grow[stat] + random(diff))
        end
      else -- наняли первый раз
        MakeHeroReturnToTavernAfterDeath(hero, 1)
        print(hero, ' hired first time...')
        -- выставляем базовые статы
        ChangeHeroStat(hero, STAT_EXPERIENCE, LEVELS[22 + diff])
        for stat = STAT_ATTACK, STAT_KNOWLEDGE do
          ChangeHeroStat(hero, stat, enemy.stat_grow[stat] * sqrt(time.week * diff) + random(diff))
        end
      end
      local all_arts = floor(4 + diff + time.week / 2)
      local relics = floor(0.1 * (diff + time.week / 4) * all_arts)
      local majors = random(all_arts - relics) + 1
      --
      local cs_sum = GetHeroSkillMastery(hero, SKILL_DESTRUCTIVE_MAGIC) + GetHeroSkillMastery(hero, SKILL_SUMMONING_MAGIC) + GetHeroSkillMastery(hero, SKILL_SORCERY)
      --
      local art_set = {}
      if cs_sum == 9 then
        print('CreateArtSet: генерируется сет chaos_summon для некроманта')
        art_set = CreateArtSet(all_arts, relics, majors, ARTS_PRESETS[TOWN_NECROMANCY]['chaos_summon'], 0.6 + 0.1 * diff)
      else
        art_set = CreateArtSet(all_arts, relics, majors)
      end
      for i, art in art_set do
        GiveArtefact(hero, art)
      end
      --EnableHeroAI(hero, 1) -- для обычных героев включаем ИИ обратно
    end
  end
  enemy.active_heroes[hero] = {days_alive = 1, death_timeout = 0, hire_count = enemy.active_heroes[hero].hire_count + 1}
  --print(enemy.heroes[hero].hire_count)
  --BlockTownsGarrisons(0)
end

-- настройка армии
function EnemyHeroArmySetup(hero, coefs_table)
  local object = GetHeroTown(hero) or hero
  print('Setup for ', object)
  local tiers = TIER_TABLES[TOWN_NECROMANCY]
  local max_up = length(tiers[1])
  -- неулучшенные существа у нанятых/взятые с караванов, их стоит удалить
  local removed = {CREATURE_SKELETON, CREATURE_WALKING_DEAD, CREATURE_MANES, CREATURE_VAMPIRE, CREATURE_LICH, CREATURE_WIGHT, CREATURE_BONE_DRAGON}
  local temp_creature = 1
  -- цикл по тирам существ
  for i = 1, 7 do
    if temp_creature then
      AddObjectCreatures(object, CREATURE_PEASANT, 1)
      sleep()
      -- удаляем ненужных существ
      for j, rm in removed do
        local rmc = GetObjectCreatures(object, rm)
        if rmc > 0 then
          RemoveObjectCreatures(object, rm, rmc)
          sleep()
        end
      end
    end
    local hero_tier = GetHeroCreaturesByTier(hero, TOWN_NECROMANCY, i) -- уже имеющиеся существа текущего тира у героя
    local count = (coefs_table[i] * time.week) + random(8 - i) -- число, которое нужно добавить
    if hero_tier then -- существа такого тира уже есть?
      AddObjectCreatures(object, GetRandFromT(hero_tier), count) -- добавить что-то из них
    else
      -- EWA - версия и прокнул альтгрейд
      if max_up == 4 and ((random(100) + 1) < enemy.alt_grade_prock_chance) then
        -- добавить конкретно его
        AddObjectCreatures(object, tiers[i][4], count)
      else
        -- иначе добавить рандомных 1-2 грейда
        AddObjectCreatures(object, GetRandFrom(tiers[i][2], tiers[i][3]), count)
      end
    end
    sleep()
    if temp_creature then
      RemoveObjectCreatures(object, CREATURE_PEASANT, 1)
      temp_creature = nil
      sleep()
    end
  end
end

-- настройка городов некромантов
function SetupNecroTowns()
  -- выключить найм всех, кроме некров
  for i = TOWN_HEAVEN, TOWN_BASTION do
    if i == TOWN_NECROMANCY then
      AllowHeroHiringByRaceForAI(PLAYER_2, i, 1)
      AllowHeroHiringByRaceForAI(PLAYER_3, i, 1)
      AllowHeroHiringByRaceForAI(PLAYER_4, i, 1)
    else
      AllowHeroHiringByRaceForAI(PLAYER_2, i, 0)
      AllowHeroHiringByRaceForAI(PLAYER_3, i, 0)
      AllowHeroHiringByRaceForAI(PLAYER_4, i, 0)
    end
  end
  -- от сложности апнуть гильдию и двеллы в городах. В Ильшам-Аггаре все отстроено по дефолту
  for i, town in {'Lernur', 'Crianna', 'Freymia'} do
    for i = 1, diff do
      UpgradeTownBuilding(town, TOWN_BUILDING_MAGIC_GUILD)
    end
    for i = TOWN_BUILDING_DWELLING_1, TOWN_BUILDING_DWELLING_3 + DIFF do
      UpgradeTownBuilding(town, i)
    end
  end
  -- на герое сразу построить грааль
  if diff == 4 then
    UpgradeTownBuilding('IlshamAggar', TOWN_BUILDING_GRAIL)
  end
end

-- настройка найма существ в городах.
-- в начале каждой недели считается общее число существ во всех городах под контролем некров.
-- существа распределяются между вражескими героями и удаляются из городов.
-- Почему-то на первой неделе существа не удаляются.
function NecroTownsCreaturesSetup()
  local tiers_table = {0, 0, 0, 0, 0, 0, 0} -- таблица существ по тирам
  for i, town in enemy.towns do
    if GetObjectOwner(town) == PLAYER_2 then
      local k = 0
      for j = CREATURE_SKELETON, CREATURE_BONE_DRAGON, 2 do
        k = k + 1
        local count = GetObjectDwellingCreatures(town, j) -- определить существ тира в городе
        if count ~= -1 then -- если есть
          tiers_table[k] = tiers_table[k] + count -- добавить в таблицу
          SetObjectDwellingCreatures(town, j, 0) -- убрать из города
        end
      end
    end
  end
  -- перебрать живых вражеских героев
  for hero, info in enemy.active_heroes do
    local tiers = TIER_TABLES[TOWN_NECROMANCY]
    local max_up = length(tiers[1])
    if IsHeroAlive(hero) then
      local object = GetHeroTown(hero) or hero
      -- посчитать коэффициенты распределения существ
      local coef = 4
      if object == 'IlshamAggar' or object == 'BlackHand' then
        coef = 1.75
      elseif object == 'BlueHand' or object == 'GreenHand' then
        coef = 2.5
      end
      -- перебрать существ героя по тирам
      for i = 1, 7 do
        local hero_tier = GetHeroCreaturesByTier(hero, TOWN_NECROMANCY, i)
        local count = ceil(tiers_table[i] / coef)
        if count >= 1 then
          if hero_tier then -- уже есть существа этого тира?
            AddObjectCreatures(object, GetRandFromT(hero_tier), count) -- добавить их, в зависимости от коэффициента
          else -- нет существ
            -- прок альтгрейда
            if max_up == 4 and ((random(100) + 1) < enemy.alt_grade_prock_chance) then
              -- добавить конкретно его
              AddObjectCreatures(object, tiers[i][4], count)
            else
              -- иначе добавить рандомных 1-2 грейда
              AddObjectCreatures(object, GetRandFrom(tiers[i][2], tiers[i][3]), count)
            end
          end
          print(ceil(tiers_table[i] / coef), ' creatures added to ', object)
        end
      end
    end
  end
end

-- поток проверяет заход героев в ворота города и если это произошло, зашедшему герою будут переданы существа из гарнизона, сконвертированные в тех, что уже имеются у героя.
-- идеально для решения всех проблем с караванами, к тому же ИИ запрещен заход в гарнизоны
function NecroTownsCreaturesUpdate()
  local necro_tiers = TIER_TABLES[TOWN_NECROMANCY]
  local max_up = length(necro_tiers[1])
  while 1 do
    for hero, info in enemy.active_heroes do
      if IsHeroAlive(hero) then
        for i, town in enemy.towns do
          if GetObjectOwner(town) ~= PLAYER_1 and -- город принадлежит ИИ?
             GetTownRace(town) == TOWN_NECROMANCY and
             IsHeroInTown(hero, town, 1, 0) and -- герой стоит в воротах?
             not GetTownHero(town) then -- и нет героя в гарнизоне города?
            for slot = 0, 6 do
              -- перебрать существ в гарнизоне
              local creature, count = GetObjectArmySlotCreature(town, slot)
              if not (creature == 0 or count == 0) then
                local cr_tier, cr_town = GetCreatureTier(creature), GetCreatureTown(creature)
                local hero_tier = GetHeroCreaturesByTier(hero, TOWN_NECROMANCY, cr_tier)
                -- добавить существ, имеющихся у героя
                if hero_tier then
                  RemoveObjectCreatures(town, creature, count)
                  local hero_add = GetRandFromT(hero_tier)
                  AddHeroCreatures(hero, hero_add, count)
                  print(count, ' ', creature, ' removed from ', town, ' and ', count, ' ', hero_add, ' added to ', hero)
                else -- или случайных из этого тира
                  RemoveObjectCreatures(town, creature, count)
                  local hero_add = GetRandFromT_E(necro_tiers[cr_tier][1], necro_tiers[cr_tier])
                  AddHeroCreatures(hero, hero_add, count)
                  print(count, ' ', creature, ' removed from ', town, ' and ', count, ' ', hero_add, ' added to ', hero)
                end
              end
            end
          end
        end
      end
    end
    sleep()
  end
end

function SiegeNecroTown(hero, object)
  local def_hero = GetRandFromT(enemy.defenders)
  DeployReserveHero(def_hero, RegionToPoint('necro_town_siege_point'))
  sleep()
  EnemyHeroArmySetup(def_hero, enemy.def_grow)
  SetObjectPosition(def_hero, GetObjectPosition('hidden_town'))
  sleep()
  local fight_id = GetLastSavedCombatIndex()
  SiegeTown(hero, 'hidden_town')
  while GetLastSavedCombatIndex() == fight_id do
    sleep()
  end
  if IsHeroAlive(hero) then
    SetObjectOwner('hidden_town', PLAYER_NONE)
    sleep()
    SetObjectOwner(object, PLAYER_1)
    Touch.RemoveFunction(object, '_necro_town_siege')
    if not Touch.HasAnyFunction(object) then
      SetObjectEnabled(object, 1)
    end
  end
end

function NecroTownsSiegeThread()
  DisableAutoEnterTown('hidden_town', 1)
  local towns_with_triggers = {}
  while 1 do
    if IsPlayerCurrent(PLAYER_1) then
      for i, town in enemy.towns do
        if town ~= 'IlshamAggar' and not contains({PLAYER_1, PLAYER_NONE}, GetObjectOwner(town)) then
          Touch.DisableObject(town)
          Touch.SetFunction(town, '_necro_town_siege', SiegeNecroTown)
          towns_with_triggers[town] = 1
        end
      end
      repeat
        sleep()
      until not IsPlayerCurrent(PLAYER_1)
      for town, _ in towns_with_triggers do
        Touch.RemoveFunction(town, '_necro_town_siege')
        if not Touch.HasAnyFunction(town) then
          SetObjectEnabled(town, 1)
          print(town, ' enabled')
        end
        towns_with_triggers[town] = nil
      end
      repeat
        sleep()
      until IsPlayerCurrent(PLAYER_1)
    end
    sleep()
  end
end

Trigger(PLAYER_ADD_HERO_TRIGGER, PLAYER_2, 'NewNecroHire')
Trigger(PLAYER_ADD_HERO_TRIGGER, PLAYER_3, 'NewNecroHire')
Trigger(PLAYER_ADD_HERO_TRIGGER, PLAYER_4, 'NewNecroHire')

-- смерть героя - сбрасываем счетчик прожитых дней
function EnemyHeroLoose(hero, winner)
  if enemy.active_heroes[hero] then
    enemy.active_heroes[hero].days_alive = 0
    enemy.active_heroes[hero].death_timeout = enemy.death_max_timeout -- + random(3-5)
    print('hero ', hero, ' lived a long live...')
  end
end

Trigger(PLAYER_REMOVE_HERO_TRIGGER, PLAYER_2, 'EnemyHeroLoose')
Trigger(PLAYER_REMOVE_HERO_TRIGGER, PLAYER_3, 'EnemyHeroLoose')
Trigger(PLAYER_REMOVE_HERO_TRIGGER, PLAYER_4, 'EnemyHeroLoose')