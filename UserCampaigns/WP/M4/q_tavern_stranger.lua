-- Очередное появление и неожиданное поручение от незнакомца из таверны.
-- Актуально на 08.06.2019

ts_q =
{
  name = 'TAVERN_STRANGER',
  path = q_path..'TavernStranger/',
  lava_cavern_points =  -- точки - регионы для перемещения по лавовой пещере
  {
    [1] = 'lava_cavern1',
    [2] = 'lava_cavern2',
    [3] = 'lava_cavern3',
    [4] = 'lava_cavern4',
    [5] = 'lava_cavern5',
    [6] = 'lava_cavern6',
    [7] = 'lava_cavern7',
    [8] = 'lava_cavern8',
    [9] = 'lava_cavern9',
    [10] = 'lava_cavern10',
    [11] = 'lava_cavern11',
    [12] = 'lava_cavern12'
  },
  rt_msg = 1,
  cc_msg = 0,
  cn_msg = 0,
  BigLavaDragon = 'BigLavaDragon',
  new_dragon_place_find_day = 0, -- день нахождения места для ритуала
  current_fire_power = 0 -- накопленная огненная энергия
}

function TS_Init()
  Touch.DisableMonster(ts_q.BigLavaDragon, DISABLED_INTERACT, 0)
  Touch.DisableObject('raintemple_tavern')
  Touch.DisableObject('castlecross_tavern')
  Touch.DisableObject('carn_tavern')
  --
  CreateMonster('lc_dragon1', CREATURE_MAGMA_DRAGON, 10, 5, 10, 1, 3, 1, 68)
  CreateMonster('lc_dragon2', CREATURE_FIRE_DRAGON, 9, 5, 10, 1, 3, 1, 347)
  CreateMonster('lc_dragon3', CREATURE_LAVA_DRAGON, 8, 5, 10, 1, 3, 1, 281)
  CreateMonster('lc_dragon4', CREATURE_MAGMA_DRAGON, 8, 5, 10, 1, 3, 1, 192)
  sleep()
  for i = 1, 4 do
    Touch.DisableMonster('lc_dragon'..i, DISABLED_ATTACK, 0)
  end
  --
  Touch.SetFunction('raintemple_tavern', '_talk', TS_RaintempleTavern)
  Touch.SetFunction('castlecross_tavern', '_talk', TS_CastlecrossTavern)
  Touch.SetFunction('carn_tavern', '_talk', TS_CarnTavern)
  --
  Trigger(REGION_ENTER_WITHOUT_STOP_TRIGGER, 'lava_cavern4', 'TS_ReachCenter')
  Trigger(REGION_ENTER_WITHOUT_STOP_TRIGGER, 'lava_cavern8', 'TS_ReachEnd')
  Trigger(REGION_ENTER_WITHOUT_STOP_TRIGGER, 'lava_cavern12', 'TS_ReachEnd')
end

startThread(TS_Init)

-- до начала: послание в таверне Рейнтемпла
function TS_RaintempleTavern(hero, object)
  if hero == Karlam and ts_q.rt_msg == 1 then
    MessageBox(ts_q.path..'ts_rt_msg.txt')
    ts_q.cc_msg = 1
    Touch.RemoveFunctions(object)
    SetObjectEnabled(object, 1)
  else
    Touch.RemoveFunctions(object)
    SetObjectEnabled(object, 1)
    sleep()
    MakeHeroInteractWithObject(hero, object)
    sleep(2)
    SetObjectEnabled(object, nil)
    Touch.SetFunction(object, '_talk', TS_RaintempleTavern)
  end
end

-- до начала: послание в таверне Кастлкросса
function TS_CastlecrossTavern(hero, object)
  if hero == Karlam and ts_q.cc_msg == 1 then
    MessageBox(ts_q.path..'ts_gc_msg.txt')
    ts_q.cn_msg = 1
    Touch.RemoveFunctions(object)
    SetObjectEnabled(object, 1)
  else
    Touch.RemoveFunctions(object)
    SetObjectEnabled(object, 1)
    sleep()
    MakeHeroInteractWithObject(hero, object)
    sleep(2)
    SetObjectEnabled(object, nil)
    Touch.SetFunction(object, '_talk', TS_CastlecrossTavern)
  end
end

-- до начала: послание в таверне Карна
function TS_CarnTavern(hero, object)
  if hero == Karlam and ts_q.cn_msg == 1 then
    MessageBox(ts_q.path..'ts_cn_msg.txt')
    Touch.RemoveFunctions(object)
    SetObjectEnabled(object, 1)
    local x = random(4) + 1
    Touch.DisableObject('ts_place'..x)
    Touch.SetFunction('ts_place'..x, '_talk', TS_MainTalk)
    for i = 1, 4 do
      if i ~= x then
        Touch.DisableObject('ts_place'..i)
        Touch.SetFunction('ts_place'..i, '_talk',
        function()
          MessageBox(rtext('Здесь никого нет...'))
        end)
      end
    end
  else
    Touch.RemoveFunctions(object)
    SetObjectEnabled(object, 1)
    sleep()
    MakeHeroInteractWithObject(hero, object)
    sleep(2)
    SetObjectEnabled(object, nil)
    Touch.SetFunction(object, '_talk', TS_CarnTavern)
  end
end

-- основной диалог
function TS_MainTalk(hero, object)
  if IsUnknown(ts_q.name) then
    MessageBox(ts_q.path..'ts_start.txt')
    StartQuest(ts_q.name, hero)
    for i = 1, 4 do
      if 'ts_place'..i ~= object then
        Touch.RemoveFunctions('ts_place'..i)
        SetObjectEnabled('ts_place'..i, 1)
      end
    end
    sleep()
    UpdateQuest(ts_q.name, 1, hero)
    Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'lava_cavern_start', 'TS_LavaCavernFirstEnter')
  else
    local progress = GetProgress(ts_q.name)
    if progress < 4 then
      MessageBox(ts_q.path..'ts_temp1.txt')
    else
      if progress == 4 then
        MessageBox(ts_q.path..'ts_temp2.txt')
        UpdateQuest(ts_q.name, 5, hero)
        ts_q.new_dragon_place_found_day = GetDate(DAY) + 1 -- +15, но пока тест
        MessageBox(ts_q.path..'spell_power_needed.txt')
      end
    end
  end
end

-- первый раз подошли к реке из лавы
function TS_LavaCavernFirstEnter(hero)
  if hero == Karlam then
    MessageBox(ts_q.path..'lava_cavern_enter.txt')
    UpdateQuest(ts_q.name, 2, hero)
    Dialog.SetState(baal_dialog, 11)
    print(baal_dialog.state)
    Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'lava_cavern_start', nil)
  end
end

-- проверяем, не находится ли герой уже в начале пещеры в нужное время, чтобы не перезаходить в регион для активации
function TS_CheckDialogStartWhenHeroAlreadyInCavern()
  if GetProgress(ts_q.name) > 2 then
    if IsObjectInRegion(Karlam, 'lava_cavern_start') then
      TS_LavaCavernMoveHandlerInit(Karlam)
    end
  else return end
end

-- если договорились с Баалом, ночью возле лавовой реки появляется диалог перемещения по ней
function TS_LavaCavernMoveHandlerInit(hero)
  if GetDate(DAY_OF_WEEK) > 4 then
    Dialog.SetState(baal_dialog, 21)
    startThread(
    function()
      while TS_CheckKarlamInLavaCavern() do -- определяем выход из этого региона
        sleep()
      end
      Dialog.SetState(baal_dialog, 1)
    end)
  else
    Dialog.SetState(baal_dialog, 1)
  end
end

function TS_CheckKarlamInLavaCavern()
  local answer = nil
  for i, region in ts_q.lava_cavern_points do
    if IsObjectInRegion(Karlam, region) then
      answer = 1
      return answer
    end
  end
  for i, region in {'lava_cavern_start', 'lava_cavern_finish1', 'lava_cavern_finish2'} do
    if IsObjectInRegion(Karlam, region) then
      answer = 1
      return answer
    end
  end
  return nil
end

-- function ts_SavePoint(point)
--   ts_q.saved_point = point
-- end

-- определяет, в какой точке лавовой пещеры сейчас находится игрок
function TS_GetCurrentPoint()
  local answer = 0
  for i, point in ts_q.lava_cavern_points do
    if IsObjectInRegion(Karlam, point) then
      answer = i
      return answer
    end
  end
  -- отдельно проверить нахождение в регионах около финишных точек
  if IsObjectInRegion(Karlam, 'lava_cavern_finish2') then
    answer = 12
    return answer
  end
  if IsObjectInRegion(Karlam, 'lava_cavern_finish1') then
    answer = 8
    return answer
  end
  return nil
end

-- если Карлам остался в пещере до утра, то он сгорает...
function TS_BurnHero()
  if not TS_GetCurrentPoint() then
    return
  else
    MessageBox(ts_q.path..'karlam_burned.txt')
    Loose()
  end
end

-- перемещает Карлама в точку с индексом index
function TS_MoveToPoint(index)
  BlockGame()
  SetObjectPosition('Karlam', RegionToPoint(ts_q.lava_cavern_points[index]))
  sleep(15)
  UnblockGame()
end

-- достигли центра пещеры - диалог немного меняется
function TS_ReachCenter(hero)
  Dialog.SetState(baal_dialog, 23)
end

-- достигли одного из концов пещеры - убирается опция 'Идти вперед'
function TS_ReachEnd(hero)
  Dialog.SetState(baal_dialog, 24)
end

-- добрались до места рождения драконов
function TS_DragonBirthPlaceReached(hero)
  BlockGame()
  Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'lava_cavern_finish1', nil)
  OpenCircleFog(101, 207, 1, 5, 1)
  sleep()
  SetObjectPosition('lc_dragon1', 96, 205, 1)
  SetObjectPosition('lc_dragon2', 99, 207, 1)
  SetObjectPosition('lc_dragon3', 101, 205, 1)
  SetObjectPosition('lc_dragon4', 99, 202, 1)
  sleep()
  for i = 1, 4 do
    PlayObjectAnimation('lc_dragon'..i, 'attack00', ONESHOT)
  end
  sleep(15)
  UnblockGame()
  if StartCombat(hero, nil, 3, CREATURE_FIRE_DRAGON, 50,
                               CREATURE_MAGMA_DRAGON, 50,
                               CREATURE_LAVA_DRAGON, 50) then
    for i = 1, 4 do
      PlayObjectAnimation('lc_dragon'..i, 'death', ONESHOT_STILL)
    end
    sleep(10)
    for i = 1, 4 do
      RemoveObject('lc_dragon'..i)
    end
    sleep()
    SetObjectPosition(ts_q.BigLavaDragon, 101, 207, 1)
    sleep()
    Touch.SetFunction(ts_q.BigLavaDragon, '_talk', TS_DragonTalk)
    sleep(10)
  end
end

Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'lava_cavern_finish1', 'TS_DragonBirthPlaceReached')

-- разговор с драконом
function TS_DragonTalk(hero, object)
  local progress = GetProgress(ts_q.name)
  if progress == 3 then
    MessageBox(ts_q.path..'big_dragon_talk.txt')
    UpdateQuest(ts_q.name, 4, hero)
  elseif progress == 8 then
    MessageBox(ts_q.path..'big_dragon_talk2.txt')
    FinishQuest(ts_q.name, hero)
    RemoveArtefact(hero, ARTIFACT_RING_OF_THE_SHADOWBRAND)
  else
    ShowFlyingSign(rtext('Хозззяяяин...'), object, -1, 10.0)
  end
end

-- место для ритуала переноса найдено
function TS_RitualPlaceFound()
  MessageBox(ts_q.path..'ritual_place_found.txt')
  ShowObject('RitualPlaceEnter', 1)
  Touch.DisableObject('RitualPlaceEnter')
  Touch.DisableObject('ritual_stand')
  Touch.SetFunction('RitualPlaceEnter', '_enter', TS_MoveToRitualPlace)
  Touch.SetFunction('ritual_stand', '_ritual', TS_DragonMoveRitual)
  UpdateQuest(ts_q.name, 6, Karlam)
end

function TS_MoveToRitualPlace(hero, object)
  SetObjectPosition(hero, 204, 19, 1)
end

-- ритуал проведен
function TS_DragonMoveRitual(hero, object)
  -- if GetHeroStat(hero, 3) >= 60 then
  -- ролик с перемещением, объяснением, что дракон слаб и выдачей огненного кольца
  SetObjectRotation(ts_q.BigLavaDragon, 48)
  sleep()
  PlayVisualEffect('/Effects/_(Effect)/Towns/Fortrest/Dwelling7/Dwelling7b.(Effect).xdb#xpointer(/Effect)', '', '', 195, 26, -2, 270, 1)
  SetObjectPosition(ts_q.BigLavaDragon, 196, 25)
  Touch.RemoveFunctions(object)
  sleep(10)
  GiveArtifact(hero, ARTIFACT_RING_OF_THE_SHADOWBRAND, 0)
  SetGameVar('fire_ring', 1)
  SetGameVar('fire_power', 0)
  UpdateQuest(ts_q.name, 7, hero)
end

-- рассчет огненной энергии, полученной в результате боя
-- если дрались руками, то сразу переходим к выводу информации - все необходимые рассчеты уже произведены в комбате
-- если был автобой, то производим рассчет с помощью информации, полученной триггером результатов боя
function TS_CalculateFirePower(fight_id)
--  if GetGameVar('combat_mode') == 'real_combat' then
--    TS_CheckCollectedFirePower()
--  else
    local dead_stacks = GetSavedCombatArmyCreaturesCount(fight_id, 0)
    -- print(dead_stacks)
    local sum = GetGameVar('fire_power') + 0
    for i = 0, dead_stacks - 1 do
      local creature, count, died = GetSavedCombatArmyCreatureInfo(fight_id, 0, i)
      sum = sum + ((GetCreaturePower(creature) * count)/829) * 10
    end
    SetGameVar('fire_power', sum)
    TS_CheckCollectedFirePower()
--  end
end

-- вывод полученной после боя энергии
function TS_CheckCollectedFirePower()
  local cp = GetGameVar('fire_power') + 0
  sleep(5)
  ShowFlyingSign(rtext('<color=red>Собрано <color_bright>'..math.round(cp - ts_q.current_fire_power)..'<color=red> единиц силы огня'), Karlam, 1, 7.0)
  ts_q.current_fire_power = cp
  sleep()
  if ts_q.current_fire_power >= 1000 then -- 100 000!!!
    MessageBox(rtext('Вы собрали достаточно энергии огня! Вернитесь к дракону.'))
    UpdateQuest(ts_q.name, 8, Karlam)
  end
end
