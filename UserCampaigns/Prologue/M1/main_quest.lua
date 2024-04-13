--------------------------------------------------------------------------------
-- главный квест карты, который так или иначе сводится к победе над Баалом
-- здесь же описаны прочие, тесно связанные с главным, квесты

mainQ =
{
  names = {
    main = 'KILL_BAAL',
    tear = 'ASHA_TEAR',
    phoenix = 'PHOENIX',
    enight = 'ETERNAL_NIGHT',
    final = 'FINAL_QUEST',
    intro = 'INTRO_QUEST',
    alive = 'STAY_ALIVE'
    -- crypt = 'CRYPT'
    },
  paths = {
    main = qPath..'KillBaal/',
    tear = qPath..'AshaTear/',
    other = qPath..'Other/'
    },
  eNightDay = 0, -- день начала вечной ночи
  nightTime = 5,-- день наступления ночи
  BaalFirstActiveDay = 0, -- день первого появления Баала
  isBaalActive = 0, -- Баал активен/нет
  BaalSpawnDate = 0, -- день недели, в который Баал должен начать преследование
  Destination = 0, -- Баал не имеет/имеет точку назначения(для случая когда Карлам не доступен)
  BaalTP = 0, -- возможность Баала приблизиться к игроку
  SpawnPoints = {}, -- список регионов из одного тайла, в которых потенциально может появиться Баал
  
  Obelisks = 0, -- посещенные обелиски
  tear_flag = 0, -- флаг слезы
  phoenix_flag = 0, -- флаг феникса. а вот
  
  gotSvetDay = 0, -- день получения Светоча
}

-- небольшая подсказка игроку по направлению поисков
SetObjectEnabled('hut1', nil)
Touch.SetFunction('hut1',
function(hero, object)
  ShowObject('baal_point', 1)
  sleep(10)
--  startQuest(mainQ.names.crypt)
  MessageBox(mainQ.paths.other..'crypt.txt')
  sleep()
  Touch.OverrideFunction(object, 1,
  function()
    ShowObject('baal_point', 1)
  end)
end)

-- крипта Баала и его 'включение'
SetObjectEnabled('baal_point', nil)
Touch.SetFunction('baal_point',
function(hero, object)
--  if isActive(mainQ.names.crypt) then
--    finishQuest(mainQ.names.crypt)
--  else
--    Touch.RemoveFunctions('hut1')
--    SetObjectEnabled('hut1', not nil)
--  end
  StartDialogScene(DIALOG_SCENES.BAAL_SPAWN)
  BlockGame()
  MessageBox(mainQ.paths.main..'baal_spawn_message.txt')
  startQuest(mainQ.names.main, hero)
  mainQ.eNightDay = GetDate(DAY) + 81 - 3 * DIFF -- установка дня вечной ночи
  sleep()
  ShowObject('prorok1', 1, 1)
  sleep(15)
  MessageBox(mainQ.paths.main..'prorok1.txt')
  sleep()
  MarkObjectAsVisited(object, hero)
  Touch.OverrideFunction(object, 1,
  function(hero, object)
    ShowFlyingSign(rtext('Вы уже были здесь...'), object, -1, 7.0)
  end)
  local dow = GetDate(DAY_OF_WEEK)
  -- если активировали Баала днем, то он начнет преследование уже этой ночью
  -- если ночью, то он появится только в следующую ночь
  if dow == 4 then
    mainQ.BaalFirstActiveDay = GetDate(DAY) + 2
  else
    mainQ.BaalFirstActiveDay = dow < 5 and GetDate(DAY) + 5 - dow or GetDate(DAY) + 12 - dow
  end
  UnblockGame()
end)

-- разговор с пророком возле Моритона
SetObjectEnabled('prorok1', nil)
Touch.SetFunction('prorok1',
function(hero, object)
  if hero == 'Karlam' and getProgress(mainQ.names.main) == 0 then
    MessageBox(mainQ.paths.main..'prorok_msg.txt')
    updateQuest(mainQ.names.main, 1, hero)
    SetObjectEnabled('elf_treasure1', nil)
    Touch.SetFunction('elf_treasure1', -- битва в ближней чаще энтов
    function(hero, object)
      if hero == 'Karlam' then
        if StartCombat(hero, nil, 4,
                       CREATURE_DRYAD, 113,
                       CREATURE_UNICORN, 13,
                       CREATURE_WAR_DANCER, 45,
                       CREATURE_HIGH_DRUID, 16) then
          Award(hero, nil, nil,
               {ARTIFACT_RIGID_MANTLE},
               {
                 {SPELL_FIREBALL},
                 {SPELL_FORGETFULNESS},
                 {SPELL_DEFLECT_ARROWS},
                 {SPELL_PHANTOM}
               })
          ShowFlyingSign(wPath..'Bow/got_uni_part.txt', hero, -1, 7.0)
          sleep(5)
          addGold(3500, hero)
          astroQ.bow_parts = astroQ.bow_parts + 1
          Touch.RemoveFunctions(object)
          SetObjectEnabled(object, not nil)
        end
      end
    end)
  else
    ShowFlyingSign(rtext('Пророка нет на месте...'), object, -1, 7.0)
  end
end)

-- гарнизон Моритона
SetObjectEnabled('garnison1', nil)
Touch.SetFunction('garnison1',
function(hero, object)
  if hero == 'Karlam' then
    if HasArtefact('Karlam', ARTIFACT_RIGID_MANTLE, 1) then -- пропускает, если есть плащ Силанны
      MessageBox(mainQ.paths.main..'garnison1_y.txt')
      SetObjectOwner(object, PLAYER_1)
      Touch.RemoveFunctions(object)
      SetObjectEnabled(object, not nil)
      sleep()
      -- по необъяснимым причинам именно этот гарнизон отказывается нормально работать, пока не войдешь в него,
      -- а затем не выйдешь с другой стороны, поэтому решаем эту проблему напрямую
      ChangeHeroStat(hero, STAT_MOVE_POINTS, 400)
      sleep()
      MoveHeroRealTime(hero, 26, 46, 0)
      -- MakeHeroInteractWithObject(hero, object)
    else
      MessageBox(mainQ.paths.main..'garnison1_n.txt') -- иначе пройти нельзя
    end
  end
end)

-- первый вход Карлама в Моритон
function reachMoriton(hero)
  if hero == 'Karlam' then
    Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'moritonEnter', nil)
    StartDialogScene(DIALOG_SCENES.MORITON_ENTER)
    SetPlayerTeam(PLAYER_3, 1) -- мало ли кто-то решит напасть на Грету
    startQuest(mainQ.names.enight, hero)
    startQuest(mainQ.names.tear, hero)
    startQuest(mainQ.names.phoenix, hero)
    updateQuest(mainQ.names.main, 2, hero)
    updateQuest(mainQ.names.intro, 1, hero)
    sleep()
    if mainQ.Obelisks ~= 0 then -- если уже посетили хотя бы один обелиск
      updateQuest(mainQ.names.tear, 1, hero) -- дать небольшую подсказку в квесте
    end
    -- startThread(CheckMoritonBlock)
    startThread(AshaTear)
    SetHeroesExpCoef(0.5 + (0.2 - (0.05 * diff)))
--    SetRegionBlocked('townBlock1', not nil) -- блокировка всех выходов, кроме тропы.
--    SetRegionBlocked('townBlock3', not nil)
--    SetRegionBlocked('townBlock4', not nil)
--    SetRegionBlocked('townBlock5', not nil)
    Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'tropa6', 'leaveMoriton') -- триггер на выход
    MessageBox(wPath..'All_paths_blocked.txt')
    for i = 1, 3 do -- блок гарнизонов
      SetObjectEnabled('garnison'..i, nil)
      Touch.SetFunction('garnison'..i, returnTown)
      PlayVisualEffect(USED_FX.GHOST_GUARD_FX, 'garnison'..i, 'blockEffect'..i, 0, 0, 0, 0, 0)
    end
    ShowObject('Elleshar', 1)
    sleep(5)
    for i, unit in moriton.out_gar_units do -- убрать внешний гарнизон
      local og_unit = 'out_gar_'..unit
      PlayVisualEffect(USED_FX.TOWN_PORTAL_FX, og_unit)
      Play3DSound(USED_SOUNDS.TOWN_PORTAL_SOUND, GetObjectPosition(og_unit))
    end
    PlayVisualEffect(USED_FX.TOWN_PORTAL_FX, 'Elleshar')
    Play3DSound(USED_SOUNDS.TOWN_PORTAL_SOUND, GetObjectPosition('Elleshar'))
    sleep(GetSoundTimeInSleeps(USED_SOUNDS.TOWN_PORTAL_SOUND))
    RemoveObject('Elleshar')
    for i, unit in moriton.out_gar_units do
      local og_unit = 'out_gar_'..unit
      RemoveObject(og_unit)
    end
    MessageBox(wPath..'out_gar_leaved.txt')
    SetRegionBlocked('bblock2', nil, PLAYER_2)
  end
end

Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'moritonEnter', 'reachMoriton')

function GretaAlive()
  while isUnknown(mainQ.names.final) do
    if not IsHeroAlive('Greta') then
      Loose()
    end
    sleep(5)
  end
end

-- Карлам покидает город - настройка дней нападений, подкреплений, передача Греты игроку
function leaveMoriton(hero)
  if hero == 'Karlam' then
    SetPlayerTeam(PLAYER_3, 2)
    -- установка дней атак на город
    moriton.test_day = GetDate(DAY) + 1
    moriton.ainurAttack = GetDate(DAY) + 10 -- 10
    moriton.gilvaAttack = moriton.ainurAttack + 13 -- 13
    moriton.orrisAttack = moriton.gilvaAttack + 15 -- 15
    moriton.klemAttack = moriton.orrisAttack + 17 -- 18
    moriton.mordAttack = moriton.klemAttack + 19 -- 21
    moriton.reinfs = GetDate(DAY) + 7 -- установка дня подкреплений
    SetRegionBlocked('townBlock2', not nil) -- блокировка тропы
    SetRegionBlocked('undeadAttack', nil)
    Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'tropa6', nil)
    MoritonAttackEvent()
    Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'undeadAttack', 'undeadAttackFight')
    SetObjectOwner('Greta', PLAYER_1)
    startThread(GretaAlive)
    -- startThread(GretaTest, 2)
    -- unlim_move = 0
    -- игрок может передать существ Грете, переносим их обратно, если нужно
    for i = 0, 6 do
      local creature, count = GetObjectArmySlotCreature('Greta', i)
      if not (creature == 0 or count == 0) and GetCreatureTown(creature) ~= TOWN_PRESERVE then
        RemoveHeroCreatures('Greta', creature, count)
        AddHeroCreatures('Karlam', creature, count)
      end
    end
    SetObjectOwner('Moriton', PLAYER_1)
    -- по непонятным причинам, сверкающий фонтан, константа которого - 19, установить не получается,
    -- т.к. 'город не содержит здания 19'. Способа построить его скриптом я вообще не нашел.
    -- Поэтому эта функция больше не юзается, у ИИ изымается золото, чтобы тупо не мог строить
    -- SetTownBuildLimit('Moriton', {4, 3, 2, 0, 0, 1, 3, 2, 2, 2, 2, 2, 2, 2, 0, -1, 2, -1, 1, -1, 1, 1})
    UpgradeTownBuilding('Moriton', 0) -- отстройка Моритона
    UpgradeTownBuilding('Moriton', 1) -- здания существ зависят от сложности
    for i = 7, 12 - DIFF do
      UpgradeTownBuilding('Moriton', i)
    end
    SetObjectOwner('garnison1', PLAYER_3)
    startQuest(moriton.names.def, 'Greta')
    updateQuest(mainQ.names.alive, 1, 'Greta')
  end
end

-- логика тыков в гарнизоны после того, как покинули город
function returnTown(hero, object)
  if moriton.remove_def ~= -1 then -- пока не сняты защитные чары
    MessageBox(rtext('Странная магия закрывает проход...')) -- взаимодействовать, в принципе, нельзя
    return
  else -- иначе
    if hero == 'Karlam' then
      if mainQ.tear_flag == 1 and mainQ.phoenix_flag == 1 then -- есть обе части артефакта?
        StartDialogScene(DIALOG_SCENES.CREATE_SVET)
        finishQuest(mainQ.names.tear, hero)
        finishQuest(mainQ.names.phoenix, hero)
        Award(hero, nil, nil, {ARTIFACT_PRINCESS}) -- получаем Светоч
        sleep()
        MessageBox(mainQ.paths.main..'got_svetoch.txt')
        updateQuest(mainQ.names.main, 4, hero)
        mainQ.gotSvetDay = GetDate(DAY) -- запоминаем день
        startThread(ControlBaalBonus) -- запускаем поток включения/выключения бонуса Баала
        for i = 1, 3 do
          Touch.OverrideFunction('garnison'..i, 1, -- больше взаимодействовать нельзя
          function(hero, object)
            if hero == 'Karlam' then
              MessageBox(rtext('Еще не время возвращаться...'))
            elseif hero == 'Greta' then
              MessageBox(rtext('Хранительница должна остаться до конца со своим городом...'))
            end
          end)
        end
      else
        MessageBox(rtext('Возвращаться пока рано...'))
      end
    elseif hero == 'Greta' then
      MessageBox(rtext('Хранительница должна остаться до конца со своим городом...')) -- Грета выйти не может в любом случае
    end
  end
end

-- Светоч нестабилен и разрушается через день(неделю по геройски)...
function CheckSvetDestroy(day)
  if day == mainQ.gotSvetDay + 7 then
    MessageBox(mainQ.paths.main..'svet_destroyed.txt')
    RemoveArtefact('Karlam', ARTIFACT_PRINCESS)
    sleep()
    MakeHeroInteractWithObject('Baal', 'Karlam')
  end
end
--------------------------------------------------------------------------------
-- все связанное с респавнами Баала и его преследованием

-- дает ночные(по факту постоянные) бонусы Баалу. Намеренно завышены, чтобы кто - нибудь случайно не убил раньше времени)
function GiveBaalNightBonus()
  GiveHeroBattleBonus('Baal', HERO_BATTLE_BONUS_ATTACK, 30)
  GiveHeroBattleBonus('Baal', HERO_BATTLE_BONUS_DEFENCE, 30)
  GiveHeroBattleBonus('Baal', HERO_BATTLE_BONUS_INITIATIVE, 50)
  GiveHeroBattleBonus('Baal', HERO_BATTLE_BONUS_SPEED, 7)
  GiveHeroBattleBonus('Baal', HERO_BATTLE_BONUS_HITPOINTS, 1000)
end

function InitBaalSpawnPoints()
  for i = 1, 36 do
    mainQ.SpawnPoints[i] = 'sp'..i -- инициализация точек респавна Баала
  end
end

InitBaalSpawnPoints()

-- находит точку из числа возможных, которая будет удовлетворять всем условиям
-- с параметром 0 находит проходимую точку, наиболее близкую к Карламу, но не ближе 8 клеток
-- с параметром 1 находит наиболее удаленную проходимую точку для Баала
-- c параметром 2 находит точку, наиболее подходящую для сокращения расстояния, если Баал сильно отстал
function FindOptimalSpawnPoint(param)
  if param == 0 then
    -- сначала устанавливаем случайные возвращаемые координаты - если не получится найти подходящую точку, Баал появится в базовой
    local xTile, yTile, zTile = RegionToPoint(mainQ.SpawnPoints[1])
    local nPath = math.huge -- текущий минимальный путь
    -- local iDebug = 0 -- для отладки
    for i, point in mainQ.SpawnPoints do -- проверяем все точки из таблицы
      local testPath = CalcHeroMoveCost('Karlam', RegionToPoint(point)) -- считаем путь героя до точки
      if testPath ~= -1 and -- если путь есть
         testPath < nPath and -- и он меньше текущего минимального
         testPath > 800 then -- но не меньше 8 клеток
        nPath = testPath -- то обновляем минимальный путь
        xTile, yTile, zTile = RegionToPoint(point) -- устанавливаем временные возвращаемые координаты
      end
    end
    return xTile, yTile, zTile
  elseif param == 1 then -- аналогично тому, что выше, только ищем самую дальнюю проходимую точку
    local xTile, yTile, zTile = RegionToPoint(mainQ.SpawnPoints[1])
    local nPath = 0
    for i, point in mainQ.SpawnPoints do
      local testPath = CalcHeroMoveCost('Baal', RegionToPoint(point))
      if testPath ~= -1 and
         testPath > nPath then
        nPath = testPath
        xTile, yTile, zTile = RegionToPoint(point)
      end
    end
    return xTile, yTile, zTile
  -- здесь мы должны найти точку, удовлетворяющую следующим условиям:
  -- проходима и для Карлама и для Баала;
  -- путь Карлама до нее - минимально возможный, но не меньше 800;
  -- сумма путей Карлама и Баала до нее должна быть больше или равна фактическому расстоянию от Баал -> Карлам, т.к.
  -- нужно учитывать, что путь Карлам -> Баал может быть гораздо меньше засчет троп
  elseif param == 2 then
    local xTile, yTile, zTile = GetObjectPosition('Baal')
    local nPath = math.huge
    for i, point in mainQ.SpawnPoints do
      local bPath = CalcHeroMoveCost('Baal', RegionToPoint(point)) -- путь Баала до точки
      if bPath ~= - 1 then -- если его нет дальше проверять нет смысла
        local kPath = CalcHeroMoveCost('Karlam', RegionToPoint(point)) -- путь Карлама до точки
        if kPath ~= -1 and kPath >= 800 then -- так же отсекаем лишние вычисления
          local dist = CalcHeroMoveCost('Baal', GetObjectPosition('Karlam')) -- расстояние Баал -> Карлам
          if kPath < nPath and -- путь Карлама минимален?
             kPath + bPath >= dist then -- сумма путей >= расстоянию Баал -> Карлам?
            nPath = kPath
            xTile, yTile, zTile = RegionToPoint(point)
          end
        end
      end
    end
    return xTile, yTile, zTile
  end
end

-- логика перемещений Баала
function BaalRun()
  while 1 do
    if mainQ.isBaalActive == 0 then return end -- выход из функции при отступлении Баала утром
    if GetCurrentPlayer() == PLAYER_2 then -- если ход 2 игрока
      pX, pY, pZ = GetObjectPosition('Karlam')
      if CanMoveHero('Baal', pX, pY, pZ) then -- и Баал может добежать до Карлама
        local cost = CalcHeroMoveCost('Baal', pX, pY, pZ)
        print('Расстояние до цели: ', cost)
        if cost >= 10000 and mainQ.BaalTP == 0 then -- если игрок ушел слишком далеко, Баал сокращает расстояние
          local cX, cY, cZ = FindOptimalSpawnPoint(2)
          SetObjectPosition('Baal', cX, cY, cZ, 3)
          mainQ.BaalTP = 1
          print('Игрок ушел слишком далеко, сокращаем расстояние')
          ChangeHeroStat('Baal', 7, -(GetHeroStat('Baal', 7) - 300)) -- но догнать в тот же момент он не сможет
          sleep()
        end
        MoveHero('Baal', pX, pY, pZ) -- бежать в эту точку
        print('Все нормально, бежим за игроком')
      elseif mainQ.Destination == 0 then -- если не добежать и нет точки назначения
        print('Нельзя добежать до игрока, поэтому ищем другую цель')
        bX, bY, bZ = FindOptimalSpawnPoint(1) -- определяем максимально удаленную проходимую точку для Баала
        MoveHero('Baal', bX, bY, bZ) -- бежим туда
        mainQ.Destination = 1
      else
        print('Нельзя добежать до игрока, но есть другая цель')
        MoveHero('Baal', bX, bY, bZ)
      end
    end
    sleep(2)
  end
end

-- ускорение Баала
function BaalAddMP()
  if mainQ.isBaalActive == 1 then
    MakeHeroInteractWithObject('Baal', 'stables')
    print('baal mp added')
  end
end

-- замедление Баала -> см. квест с тайными тропами
--function BaalRemoveMP(hero)
--  if hero == 'Baal' then
--    local mp = GetHeroStat('Baal', STAT_MOVE_POINTS)
--    if mp <= 1000 then
--      ChangeHeroStat('Baal', STAT_MOVE_POINTS, -10000)
--    else
--      ChangeHeroStat('Baal', STAT_MOVE_POINTS, -mp/2)
--    end
--    print('baal mp removed')
--  end
--end

-- первый респавн Баала
function CheckBaalFirstSpawn(day)
  if day == mainQ.BaalFirstActiveDay then
    BlockGame()
    MoveCamera(32, 26, 0, 0, 0, 0, 1, 1)
    sleep(20)
    SetObjectPosition('Baal', 32, 26, 0, 3)
    GiveBaalNightBonus()
    sleep(10)
    MessageBox(mainQ.paths.main..'Baal_first_spawn.txt', 'UnblockGame')
    mainQ.isBaalActive = 1
    mainQ.BaalSpawnDate = 5
    startThread(BaalRun)
  end
end

-- логика респавна Баала до начала вечной ночи
function NormalSpawnRules(weekday)
  if weekday == 1 then -- в 1 день недели
    if mainQ.isBaalActive == 1 then -- Баал активен?
      ShowFlyingSign(mainQ.paths.main..'retreatBaal.txt', 'Baal', -1, 5.0)
      sleep(5)
      SetObjectPosition('Baal', 3, 8, 1, 3)
      mainQ.isBaalActive = 0 -- убрать
    end
  elseif weekday == mainQ.BaalSpawnDate then -- день респавна?
    if mainQ.isBaalActive == 0 and
       IsHeroAlive('Baal') and
       isActive(mainQ.names.main) then
      local x, y, z = FindOptimalSpawnPoint(0) -- определяем оптимальную точку
      SetObjectPosition('Baal', x, y, z, 3) -- спавним
      sleep()
      ShowFlyingSign(mainQ.paths.main..'herecomesBaal.txt', 'Baal', -1, 5.0)
      mainQ.isBaalActive = 1
      startThread(BaalRun) -- запускаем поток перемещения
    end
  end
end

-- действия Баала в день наступления вечной ночи
function eNightSpawnRules(weekday)
  -- прежде всего разблокируются открытые Карламом тайные тропы
--  for i, path in secret_path.pathOpened do
--    SetRegionBlocked(path, nil, PLAYER_2)
--  end
  -- в зависимости от времени дня события немного меняются
  if mainQ.isBaalActive == 0 then
    local x, y, z = FindOptimalSpawnPoint(0)
    SetObjectPosition('Baal', x, y, z, 3)
    ShowFlyingSign(mainQ.paths.main..'eternalBaal.txt', 'Baal', -1, 5.0)
    mainQ.isBaalActive = 1
    BaalAddMP()
    startThread(BaalRun)
  else
    ShowFlyingSign(mainQ.paths.main..'eternalBaal.txt', 'Baal', -1, 5.0)
    BaalAddMP()
  end
end

-- ежедневная проверка на респавн Баала -> для триггера нового дня
function CheckBaalSpawnRules(day)
  if isActive(mainQ.names.enight) or isUnknown(mainQ.names.enight) then
    if day < mainQ.eNightDay then
      NormalSpawnRules(GetDate(DAY_OF_WEEK))
    end
    if mainQ.eNightDay - day == mainQ.eNightDay/2 then -- половина времени до вечной ночи прошла
      MessageBox(rtext('Чары Вечной Ночи проявляются все сильнее...'))
      mainQ.nightTime = 4 -- ночь наступает раньше
      mainQ.BaalSpawnDate = 4
      if mainQ.isBaalActive == 0 then -- проверить случай, если события как раз происходят в 4 день недели
        NormalSpawnRules(GetDate(DAY_OF_WEEK))
      end
    end
    if day == mainQ.eNightDay then
      MessageBox(mainQ.paths.main..'enight_becomes.txt')
      failQuest(mainQ.names.enight)
      SetAmbientLight(GROUND, 'deepnight', not nil, 1)
      SetCombatLight(COMBAT_LIGHTS.NIGHT)
      COMBAT_LIGHTS.CURRENT = COMBAT_LIGHTS.NIGHT
      eNightSpawnRules(GetDate(DAY_OF_WEEK))
    end
  else
    return
  end
end

-- контролирует выдачу/удаление бонуса в зависимости от наличия Светоча
-- способ тупой, но более логичного придумать не смог
function ControlBaalBonus()
  local bonus_removed = 0
  while 1 do
    if (GetGameVar('svetoch') + 0) == 1 and bonus_removed == 0 then
      local x, y, z = GetObjectPosition('brb')
      MakeHeroInteractWithObject('Baal', 'brb')
      repeat sleep() until not IsObjectExists('brb')
      CreateMonster('brb', CREATURE_PEASANT, 1, x, y, z, 3, 1, 0)
      repeat sleep() until IsObjectExists('brb')
      bonus_removed = 1
    end
    if (GetGameVar('svetoch') + 0) == 0 and bonus_removed == 1 then
      GiveBaalNightBonus()
      bonus_removed = 0
    end
    sleep(2)
  end
end

--------------------------------------------------------------------------------
-- получение Слезы

-- определяет наличие слезы
function AshaTear()
  while 1 do
    if GetCurrentPlayer() == PLAYER_1 then
      if isActive(mainQ.names.tear) then
        if HasArtefact('Karlam', ARTIFACT_GRAAL) then
          mainQ.tear_flag = 1
          CheckPartsCollected()
          updateQuest(mainQ.names.tear, 4, 'Karlam')
          return
        end
      end
    end
    sleep(2)
  end
end

-- стартовая настройка обелисков
function InitObelisks()
  for i = 1, 15 do
    SetObjectEnabled('obelisk'..i, nil)
    SetObjectFlashlight('obelisk'..i, 'obelisk_fl')
    Touch.SetFunction('obelisk'..i,
    function(hero, object)
      if hero == 'Karlam' then
        MessageBox(mainQ.paths.tear..'obelisk_text'..(random(2) + 1)..'.txt') -- выводим случайное сообщение
        mainQ.Obelisks = mainQ.Obelisks + 1 -- увеличиваем счетчик обелисков
        ResetObjectFlashlight(object)
        if getProgress(mainQ.names.tear) == 0 then
          updateQuest(mainQ.names.tear, 1, hero)
        end
        Touch.OverrideFunction(object, 1,
        function(hero, object)
          ShowFlyingSign(rtext('Вы уже осмотрели этот обелиск...'), object, -1, 7.0)
        end)
        MarkObjectAsVisited(object, hero)
      end
    end)
  end
end

InitObelisks()

-- отслеживает число посещенных обелисков
function CheckObelisks()
  while 1 do
    if mainQ.Obelisks == 15 then
      updateQuest(mainQ.names.tear, 3, 'Karlam')
      MessageBox(mainQ.paths.tear..'all_obelisks.txt')
      return
    end
    sleep(2)
  end
end

-- логика разговора с древом Силанны
SetObjectEnabled('sylanna_tree', nil)
Touch.SetFunction('sylanna_tree',
function(hero, object)
  if hero == 'Karlam' then
    if getProgress(mainQ.names.tear) == 1 then -- первый раз зашли?
      MessageBox(mainQ.paths.tear..'tree_talk_start.txt')
      updateQuest(mainQ.names.tear, 2, hero)
      startThread(CheckObelisks)
    elseif getProgress(mainQ.names.tear) == 3 then -- посетили все обелиски?
      MessageBox(mainQ.paths.tear..'tree_talk_end.txt')
      OpenPuzzleMap(PLAYER_1, 15) -- открываем карту
      sleep()
      LevelUpHero(hero)
      Touch.OverrideFunction(object, 1,
      function(hero, object)
        ShowFlyingSign(rtext('Мои корни и ветви с тобой, юный маг...'), object, -1, 7.0)
      end)
      MarkObjectAsVisited(object, hero)
    end
  end
end)

-- феникс
SetObjectEnabled('qPhoenix', nil)
SetDisabledObjectMode('qPhoenix', DISABLED_INTERACT)
sleep()
SetMonsterSelectionType('qPhoenix', 0)
Touch.SetFunction('qPhoenix',
function(hero, object)
  if hero == 'Karlam' then
    MessageBox(mainQ.paths.other..'phoenix_add.txt')
    updateQuest(mainQ.names.phoenix, 2, hero)
    PlayObjectAnimation(object, 'specability', ONESHOT_STILL)
    sleep(20)
    RemoveObject(object)
    mainQ.phoenix_flag = 1
    CheckPartsCollected()
  end
end)

function CheckPartsCollected()
  if mainQ.tear_flag == 1 and mainQ.phoenix_flag == 1 then
    MessageBox(mainQ.paths.main..'have_2_svet_parts.txt')
  else
    return
  end
end

--------------------------------------------------------------------------------
-- настройки после победы над Баалом

function SetupFinalQuest()
  local x, y, z = GetObjectPosition('art_town')
  local x1, y1, z1 = GetObjectPosition('Karlam')
  DeployReserveHero('Baal_copy', 5, 6, 1)
  EnableHeroAI('Baal_copy', nil)
  WarpHeroExp('Baal_copy', LEVELS[40])
  SetHeroesExpCoef(0.001)
  SetRegionBlocked('final_block1', not nil)
  SetRegionBlocked('final_block2', not nil)
  BlockGame()
  -- ?????? ??????? ?? ??????
  ShowObject('Karlam', 1)
  PlayVisualEffect(USED_FX.IMPLOSION_FX, 'Karlam')
  Play3DSound(USED_SOUNDS.IMPLOSION_SOUND, GetObjectPosition('Karlam'))
  sleep(20)
  SetObjectPosition('Baal_copy', x1, y1, z1, 0)
  sleep()
  SetObjectOwner('Baal_copy', PLAYER_1)
  SetObjectOwner('Karlam', PLAYER_3)
  sleep()
  EnableHeroAI('Karlam', nil)
  SetObjectPosition('Karlam', x, y, z, 0)
  if not isFailed(mainQ.names.enight) then
    failQuest(mainQ.names.enight)
    SetAmbientLight(GROUND, 'deepnight', not nil, 1)
    SetCombatLight(COMBAT_LIGHTS.NIGHT)
    COMBAT_LIGHTS.CURRENT = COMBAT_LIGHTS.NIGHT
  end
  if IsObjectExists('Mordrakar') then
    RemoveObject('Mordrakar')
  end
  finishQuest(mainQ.names.main, 'Baal_copy')
  finishQuest(moriton.names.def, 'Baal_copy')
  finishQuest(mainQ.names.intro, 'Baal_copy')
  finishQuest(mainQ.names.alive)
  startQuest(mainQ.names.final, 'Baal_copy')
  sleep()
  local object = GetTownHero('Moriton') or 'Greta'
  SetObjectPosition(object, 21, 69, 0)
  sleep()
  SetObjectOwner(object, PLAYER_3)
  sleep()
  EnableHeroAI(object, nil)
  sleep()
  SetObjectOwner('Moriton', PLAYER_3)
  sleep()
  for i = 1, 3 do
    SetObjectOwner('garnison'..i, PLAYER_3)
    SetObjectEnabled('garnison'..i, not nil)
    local k, j, coef = 44, 145, 30
    while k <= 56 and j <= 151 do
      AddObjectCreatures('garnison'..i, getRandFrom(k, j), (45 + diff) * coef)
      k, j, coef = k + 2, j + 1, coef * 0.75
    end
  end
  sleep()
  local temp_creature
  for i = 0, 6 do
    creature, count = GetObjectArmySlotCreature(object, i)
    if creature ~= 0 and count ~= 0 then
      RemoveObjectCreatures(object, creature, count)
    end
    if not temp_creature then
      AddObjectCreatures(object, CREATURE_PEASANT, 1)
      temp_creature = 1
    end
  end
  sleep()
  AddObjectCreatures(object, getRandFrom(CREATURE_SPRITE, CREATURE_DRYAD), 254 * diff)
  sleep()
  RemoveObjectCreatures(object, CREATURE_PEASANT, 1)
  sleep()
  AddObjectCreatures(object, getRandFrom(CREATURE_WAR_DANCER, CREATURE_BLADE_SINGER), 164 * diff)
  AddObjectCreatures(object, getRandFrom(CREATURE_GRAND_ELF, CREATURE_SHARP_SHOOTER), 96 * diff)
  AddObjectCreatures(object, CREATURE_HIGH_DRUID, 55 * diff)
  AddObjectCreatures(object, getRandFrom(CREATURE_WAR_UNICORN, CREATURE_WHITE_UNICORN), 31 * diff)
  AddObjectCreatures(object, getRandFrom(CREATURE_TREANT_GUARDIAN, CREATURE_ANGER_TREANT), 18 * diff)
  AddObjectCreatures(object, getRandFrom(CREATURE_GOLD_DRAGON, CREATURE_RAINBOW_DRAGON), 8 * diff)
  sleep()
  SetObjectPosition(object, 18, 69, 0)
  if IsObjectExists('reinfs') then
    SetMonsterCourageAndMood('reinfs', PLAYER_1, 1, 3)
  end
  -- RemoveObject('boat')
  sleep()
  SetObjectEnabled('Moriton', nil)
  sleep()
  Touch.SetFunction('Moriton',
  function(hero, object)
    if hero == 'Baal_copy' then
      local index = GetLastSavedCombatIndex()
      SiegeTown(hero, object)
      while GetLastSavedCombatIndex() == index do sleep() end
      if IsHeroAlive('Baal_copy') then
        StartDialogSceneInt(DIALOG_SCENES.MIND_CONTROL, 'FinalBattle')
        DeployReserveHero('Karlam_copy', 3, 3, 1)
        sleep()
        EnableHeroAI('Karlam_copy', nil)
        AddHeroCreatures('Karlam_copy', CREATURE_MASTER_GREMLIN, 1200 - 100 * DIFF + random(8))
        AddHeroCreatures('Karlam_copy', CREATURE_OBSIDIAN_GARGOYLE, 800 - 75 * DIFF + random(7))
        AddHeroCreatures('Karlam_copy', CREATURE_STEEL_GOLEM, 400 - 42 * DIFF + random(6))
        AddHeroCreatures('Karlam_copy', CREATURE_COMBAT_MAGE, 200 - 27 * DIFF + random(5))
        AddHeroCreatures('Karlam_copy', CREATURE_MASTER_GENIE, 120 - 16 * DIFF + random(4))
        AddHeroCreatures('Karlam_copy', CREATURE_RAKSHASA_RUKH, 55 - 6 * DIFF + random(3))
        AddHeroCreatures('Karlam_copy', CREATURE_TITAN, 25 - 3 * DIFF + random(2))
        sleep()
        SetObjectOwner('Karlam_copy', PLAYER_1)
        SetObjectOwner('Baal_copy', PLAYER_3)
        SetObjectPosition('Karlam_copy', 18, 69, 0, 0)
        SetObjectPosition('Baal_copy', %x, %y, %z, 0)
      else
        Loose()
      end
    end
  end)
  sleep()
  SetObjectPosition('Karlam', 3, 8, 1, 0)
  MessageBox(mainQ.paths.main..'baal_lost_fight.txt', 'UnblockGame')
  PlayVisualEffect(USED_FX.SUMMON_BALOR_FX, 'Baal_copy')
  sleep(10)
  SetObjectPosition('Baal_copy', 32, 41, 0, 0)
  SetObjectRotation('Baal_copy', 243)
end

-- финальная битва с Баалом - боссом и завершение карты
function FinalBattle()
  SetAmbientLight(0, 'full_darkness', not nil, 2)
  sleep(5)
  GiveHeroBattleBonus('Baal_copy', HERO_BATTLE_BONUS_LUCK, 3)
  GiveHeroBattleBonus('Baal_copy', HERO_BATTLE_BONUS_MORALE, 3)
  sleep()
  Save('true final')
  local index = GetLastSavedCombatIndex()
  SetCombatLight(COMBAT_LIGHTS.FINAL)
  SiegeTown('Karlam_copy', 'art_town', ARENAS.MIND_FIGHT)
  while GetLastSavedCombatIndex() == index do sleep() end
  if IsHeroAlive('Karlam_copy') then
    StartDialogSceneInt(DIALOG_SCENES.FINAL, 'End')
    SetObjectOwner('art_town', PLAYER_3)
  else
    Loose()
  end
end

function End()
  BlockGame()
  SetAmbientLight(0, 'day', not nil, 6)
  sleep(25)
  Win()
end

--print('main quest loaded')