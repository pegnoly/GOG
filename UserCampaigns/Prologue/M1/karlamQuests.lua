--------------------------------------------------------------------------------
-- прочие квесты Карлама

--------------------------------------------------------------------------------
-- квесты от незнакомца в таверне
-- первый - убить торговца и забрать кристалл
-- второй - достать ключи из башен элементалей, объединить их с помощью
-- усилков хаоса, попасть в сокровищницу и добыть оттуда книгу.
-- Затем достать из библиотеки Туидханы свиток с ключом от шифра, чтобы
-- прочитать книгу и узнать важную инфу о Баале
tavernQ =
{
  names =
  {
    first = 'TAVERN_QUEST1',
    sec = 'TAVERN_QUEST2'
  },
  paths =
  {
    first = qPath..'TavernQuest1/',
    sec = qPath..'TavernQuest2/'
  },
  keys = {0, 0, 0, 0; n = 0}, -- таблица состояний получения ключей для сокровищницы
  key_res = {[0] = 0; 0, 15, 15, 15, 15, 0} -- ресурсы для ключа
}

-- логика разговоров в таверне
SetObjectEnabled('tavern1', nil)
Touch.SetFunction('tavern1',
function(hero, object)
  if hero == 'Karlam' then
    if isUnknown(tavernQ.names.first) then -- первый раз зашли?
      MessageBox(tavernQ.paths.first..'tavern1_start.txt')
      MessageBox(tavernQ.paths.first..'tavern1_1.txt')
      startQuest(tavernQ.names.first, hero)
    elseif getProgress(tavernQ.names.first) == 0 then -- первый квест в процессе?
      MessageBox(tavernQ.paths.first..'tavernQ1_temp.txt')
    elseif getProgress(tavernQ.names.first) == 1 then -- первый квест завершен?
      MessageBox(tavernQ.paths.first..'tavern1_end.txt')
      finishQuest(tavernQ.names.first, hero)
      Award(hero, nil, nil,
           {ARTIFACT_EVERCOLD_ICICLE},
           {
             {SPELL_METEOR_SHOWER},
             {SPELL_BLIND},
             {SPELL_RESURRECT},
             {SPELL_SUMMON_HIVE}
           })
      startQuest(tavernQ.names.sec, hero)
    elseif getProgress(tavernQ.names.sec) == 0 or
           getProgress(tavernQ.names.sec) == 1 then -- в процессе поиска ключей?
      MessageBox(tavernQ.paths.sec..'tavernQ2_temp1.txt')
    elseif getProgress(tavernQ.names.sec) == 2 then -- готовы войти в сокровищницу?
      MessageBox(tavernQ.paths.sec..'tavernQ2_temp2.txt')
    elseif getProgress(tavernQ.names.sec) == 3 then -- принесли книгу?
      MessageBox(tavernQ.paths.sec..'tavernQ2_temp3.txt')
      updateQuest(tavernQ.names.sec, 4, hero)
      Touch.RemoveFunctions('libTui_portal')
      SetObjectEnabled('libTui_portal', not nil)
    elseif getProgress(tavernQ.names.sec) == 4 then -- пока не были в библиотеке?
      MessageBox(tavernQ.paths.sec..'tavernQ2_temp4.txt')
    elseif getProgress(tavernQ.names.sec) == 5 then -- второй квест завершен?
      MessageBox(tavernQ.paths.sec..'tavernQ2_end.txt')
      finishQuest(tavernQ.names.sec, hero)
      local func = function(hero) addArmy(hero, 0.1) end
      Award(hero, func, {[0] = 0; 2, 2, 2, 2},
           {ARTIFACT_STAFF_OF_MAGI},
           {
             {SPELL_DEEP_FREEZE},
             {SPELL_VAMPIRISM},
             {SPELL_TELEPORT},
             {SPELL_CONJURE_PHOENIX}
           })
      Touch.OverrideFunction(object, 1,
      function(hero, object)
        ShowFlyingSign(rtext('Теперь таверна совсем пуста...'), object, -1, 6.0)
      end)
    end
  end
end)

-- торговец - живет в лавке артефактов
SetObjectEnabled('seller1', nil)
Touch.SetFunction('seller1',
function(hero, object)
  if hero == 'Karlam' then
    if getProgress(tavernQ.names.first) == 0 then
      MessageBox(tavernQ.paths.first..'seller.txt')
      if StartCombat(hero, nil, 5, -- бой с наемниками торговца
                    getRandFrom(CREATURE_MARKSMAN, CREATURE_LONGBOWMAN), 105,
                    getRandFrom(CREATURE_SWORDSMAN, CREATURE_VINDICATOR), 61,
                    getRandFrom(CREATURE_ROYAL_GRIFFIN, CREATURE_BATTLE_GRIFFIN), 22,
                    getRandFrom(CREATURE_CLERIC, CREATURE_ZEALOT), 15,
                    getRandFrom(CREATURE_PALADIN, CREATURE_CHAMPION), 7) then
        MessageBox(tavernQ.paths.first..'seller_end.txt')
        Award(hero, nil, nil, {ARTIFACT_BOOTS_OF_SPEED})
        updateQuest(tavernQ.names.first, 1, hero)
        MarkObjectAsVisited(object, hero)
        Touch.OverrideFunction(object, 1,
        function()
          ShowFlyingSign(tavernQ.paths.first..'no_seller.txt', %object, -1, 6.9)
        end)
      end
    else
      ShowFlyingSign(rtext('<color=red> Сегодня не торгуем, проваливай!'), object, -1, 5.0)
    end
  end
end)

-- настройка башен элементалей
function SetupElemTowers()
  for i = 1, 4 do
    SetObjectEnabled('elem'..i, nil)
    Touch.SetFunction('elem'..i,
    function(hero, object)
      if hero == 'Karlam' then
        if isUnknown(tavernQ.names.sec) then -- если нужный квест неактивен
          MessageBox(tavernQ.paths.sec..'no_elems.txt') -- уходим ни с чем
        else
          local cnt = {6, 8, 9, 7} -- базовые коэффициенты численности элемов
          cnt[%i] = cnt[%i] * 2.5 -- элем, ключ со стихией которого добывается в этой башне имеет бОльшую численность
          if StartCombat(hero, nil, 4, -- бой с элемами
                        CREATURE_FIRE_ELEMENTAL, 25 + cnt[1] * (0.8 + tavernQ.keys.n) + random(3),
                        CREATURE_WATER_ELEMENTAL, 28 + cnt[2] * (0.8 + tavernQ.keys.n) + random(3),
                        CREATURE_EARTH_ELEMENTAL, 29 + cnt[3] * (0.8 + tavernQ.keys.n) + random(3),
                        CREATURE_AIR_ELEMENTAL, 27 + cnt[4] * (0.8 + tavernQ.keys.n) + random(3)) then
            MessageBox(tavernQ.paths.sec..'elem'..%i..'_win.txt')
            tavernQ.keys[%i] = 1 -- получение нужного ключа
            tavernQ.keys.n = tavernQ.keys.n + 1 -- обновление счетчика ключей
            addGold(6000 * tavernQ.keys.n, hero)
            sleep(5)
            Touch.RemoveFunctions(object)
            SetObjectEnabled(object, not nil) -- включаем башню обратно
            if tavernQ.keys.n == 4 then -- если посетили все башни
              updateQuest(tavernQ.names.sec, 1, hero)
              MessageBox(tavernQ.paths.sec..'resources_for_key.txt')
              startThread( -- запускаем поток проверки на наличие усилков хаоса и ресурсов
              function()
                while 1 do
                  if (HasArtefact(%hero, ARTIFACT_EVERCOLD_ICICLE) and
                      HasArtefact(%hero, ARTIFACT_PHOENIX_FEATHER_CAPE) and
                      HasArtefact(%hero, ARTIFACT_TITANS_TRIDENT) and
                      HasArtefact(%hero, ARTIFACT_EARTHSLIDERS)) and
                      HavePlayerResT(PLAYER_1, tavernQ.key_res) and
                      QuestionBox(tavernQ.paths.sec..'can_make_key.txt') then -- если собрали все
                     RemovePlayerResT(PLAYER_1, tavernQ.key_res)
                     MessageBox(tavernQ.paths.sec..'make_key.txt')
                     updateQuest(tavernQ.names.sec, 2, %hero) -- то теперь можем войти в сокровищницу
                     return
                  end
                sleep()
                end
              end)
            end
          end
        end
      end
    end)
  end
end

SetupElemTowers()

SetObjectEnabled('dwarf_treasure', nil)
Touch.SetFunction('dwarf_treasure',
function(hero, object) -- вход в сокровищницу
  if hero == 'Karlam' and isActive(tavernQ.names.sec) then
    if getProgress(tavernQ.names.sec) == 2 then
      SetObjectPosition(hero, 79, 107, 1, 0)
    else
      MessageBox(tavernQ.paths.sec..'no_keys.txt')
    end
  else
    ShowFlyingSign(rtext('Двери сокровищницы надежно запечатаны...'), object, -1, 5.0)
  end
end)

SetObjectEnabled('exit1', nil)
SetDisabledObjectMode('exit1', DISABLED_INTERACT)
Touch.SetFunction('exit1',
function(hero, object) -- выход
  SetObjectPosition(hero, 71, 112, 0, 0)
end)

-- книга в сокровищнице.
-- при касании сообщаем игроку правила боя с Хранителем и при его согласии
-- проигрываем небольшую сценку и запускаем бой
SetObjectEnabled('book1', nil)
Touch.SetFunction('book1',
function(hero, object)
  if hero == 'Karlam' and QuestionBox(tavernQ.paths.sec..'keeper_fight_rules.txt') then
    SetAmbientLight(1, 'day', nil)
    PlayVisualEffect(USED_FX.SUMMON_FIRE_FX, object, '', 3, -1)
    Play3DSound(USED_SOUNDS.SUMMON_FIRE_SOUND, 84, 91, 1)
    PlayVisualEffect(USED_FX.SUMMON_WATER_FX, object, '', -3, -1)
    Play3DSound(USED_SOUNDS.SUMMON_WATER_SOUND, 84, 94, 1)
    PlayVisualEffect(USED_FX.SUMMON_EARTH_FX, object, '', 6, -1)
    Play3DSound(USED_SOUNDS.SUMMON_EARTH_SOUND, 84, 97, 1)
    PlayVisualEffect(USED_FX.SUMMON_WIND_FX, object, '', -6, -1)
    Play3DSound(USED_SOUNDS.SUMMON_EARTH_SOUND, 83, 100, 1)
    sleep(20)
    if StartCombat(hero, 'Keeper', 1, CREATURE_RAKSHASA, 1, nil, nil, nil, not nil) then
      SetAmbientLight(1, 'darkness', nil)
      MessageBox(tavernQ.paths.sec..'book_fight.txt')
      Award(hero, nil, nil, {ARTIFACT_BOOK_OF_POWER})
      Touch.RemoveFunctions('book1')
      updateQuest(tavernQ.names.sec, 3, hero)
    end
  end
end)

-- портал в библиотеку Туидханы
SetObjectEnabled('libTui_portal', nil)
SetDisabledObjectMode('libTui_portal', DISABLED_INTERACT)
Touch.SetFunction('libTui_portal',
function(hero, object) -- пока выключен, то пройти нельзя, включается при соотв. диалоге в таверне
  MessageBox(tavernQ.paths.sec..'lib_portal.txt')
end)

-- библиотека Туидханы.
-- нужный свиток можно получить правильно ответив на загадку
SetObjectEnabled('libraryTui', nil)
Touch.SetFunction('libraryTui',
function(hero, object)
  if hero == 'Karlam' then
    MessageBox(tavernQ.paths.sec..'lib_riddle_start.txt')
    TalkBoxForPlayers(PLAYER_1,
     '/UI/H5A2/Icons/Creatures/Dungeon_second_upd/Shadow_Mistress.(Texture).xdb#xpointer(/Texture)',
     tavernQ.paths.sec..'lib_desc.txt',
     tavernQ.paths.sec..'lib_riddle.txt',
     nil,
     'libAnswer', 1,
     tavernQ.paths.sec..'lib_desc.txt', nil, 0,
     tavernQ.paths.sec..'lib_var1.txt',
     tavernQ.paths.sec..'lib_var2.txt',
     tavernQ.paths.sec..'lib_var3.txt',
     tavernQ.paths.sec..'lib_var4.txt',
     tavernQ.paths.sec..'lib_var5.txt')
  end
end)

function libAnswer(player, answer)
  if answer < 1 then -- если нажали закрыть
    MessageBox(tavernQ.paths.sec..'lib_no_answer.txt')
    StartCombat('Karlam', nil, 5, CREATURE_BLACK_DRAGON, 100,
                                  CREATURE_BLACK_DRAGON, 100,
                                  CREATURE_BLACK_DRAGON, 100,
                                  CREATURE_BLACK_DRAGON, 100,
                                  CREATURE_BLACK_DRAGON, 100,
                                  nil, nil, nil, not nil)
  else
    if answer == 3 then -- верный ответ
      MessageBox(tavernQ.paths.sec..'lib_right_answer.txt')
      updateQuest(tavernQ.names.sec, 5, 'Karlam')
    else -- неверный
      MessageBox(tavernQ.paths.sec..'lib_wrong_answer.txt')
      StartCombat('Karlam', nil, 5,
                  CREATURE_BLACK_DRAGON, 100,
                  CREATURE_BLACK_DRAGON, 100,
                  CREATURE_BLACK_DRAGON, 100,
                  CREATURE_BLACK_DRAGON, 100,
                  CREATURE_BLACK_DRAGON, 100,
                  nil, nil, nil, not nil)
    end
  end
  Touch.OverrideFunction('libraryTui', 1,
  function(hero, object)
    ShowFlyingSign(rtext('Не время для нового знания...'), object, -1, 6.0)
  end)
end

--------------------------------------------------------------------------------
-- квест друида, сын которого пропал несколько дней назад
-- собственно, нужно найти этого сына

Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'crystal1', 'crys1Check')
Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'crystal2', 'crys2Check')
Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'crystal3', 'crys3Check')

mageQ =
{
  name = 'MAGE_QUEST',
  path = qPath..'MageQuest1/',

  pr_status = {0, 0, 0}, -- статусы тюрем - открыта/закрыта

  prison_fx = -- эффекты при открытии тюрем
  {
    {USED_FX.IMPLOSION_FX, USED_SOUNDS.IMPLOSION_SOUND},
    {USED_FX.LIGHTNING_BOLT_FX, USED_SOUNDS.LIGHTNING_BOLT_SOUND},
    {USED_FX.FIREBALL_FX, USED_SOUNDS.FIREBALL_SOUND}
  },
}

-- логика разговора с друидом
SetObjectEnabled('mageTower', nil)
Touch.SetFunction('mageTower',
function(hero, object)
  if hero == 'Karlam' then
    if isUnknown(mageQ.name) then -- первый раз зашли?
      MessageBox(mageQ.path..'mageQ_start.txt')
      startQuest(mageQ.name, hero)
      Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'burnedTower1', 'showBurnedTower')
      Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'burnedTower2', 'showBurnedTower')
      Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'deadBog', 'showDeadInBog')
    elseif getProgress(mageQ.name) < 4 then -- пока не нашли сына?
      MessageBox(mageQ.path..'mageQ_temp.txt')
    elseif getProgress(mageQ.name) == 4 then -- сын убит?
      MessageBox(mageQ.path..'mageQ_end.txt')
      finishQuest(mageQ.name, hero)
      local func = function(hero) addCreaturesByTier(hero, TOWN_ACADEMY, 5, 15, TOWN_ACADEMY, 7, 2) end
      Award(hero, func, nil, nil,
           {
             {SPELL_IMPLOSION},
             {SPELL_BERSERK},
             {SPELL_ANTI_MAGIC},
             {SPELL_CELESTIAL_SHIELD}
           })
      Touch.OverrideFunction(object, 1,
      function(hero, object)
        if hero == 'Karlam' then
          ShowFlyingSign(rtext('Никто не отвечает на ваш стук в дверь...'), object, -1, 5.0)
        end
      end)
    elseif getProgress(mageQ.name) == 5 then -- сын приведен обратно?
      MessageBox(mageQ.path..'mageQ_alt_end.txt')
      finishQuest(mageQ.name, hero)
      Award(hero, nil, nil,
           {ARTIFACT_RING_OF_CELERITY},
           {
             {SPELL_IMPLOSION},
             {SPELL_BERSERK},
             {SPELL_ANTI_MAGIC},
             {SPELL_CELESTIAL_SHIELD}
           })
      Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'liddelAmbush', 'LiddelAmbush')
      Touch.RemoveFunctions(object)
      Touch.OverrideFunction(object, 1,
      function(hero, object)
        if hero == 'Karlam' then
          ShowFlyingSign(rtext('Никто не отвечает на ваш стук в дверь...'), object, -1, 5.0)
        end
      end)
    end
  end
end)

-- дошли до сгоревшей башни - показываем ее
function showBurnedTower(hero)
  if hero == 'Karlam' then
    BlockGame()
    MoveCamera(56, 76, 0, 0, 0, 0, 1, 1)
    OpenCircleFog(56, 76, 0, 5, 1)
    sleep(10)
    MessageBox(mageQ.path..'burned_tower.txt', 'UnblockGame')
    Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'burnedTower1', nil)
    Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'burnedTower2', nil)
    -- создаем выжившего в бою лучника
    CreateMonster('alive_archer', CREATURE_SHARP_SHOOTER, 1, 49, 76, 0, 1, 1, 45)
    sleep()
    PlayVisualEffect(USED_FX.GOLD_FX, 'alive_archer', 'aa_fx')
    SetObjectEnabled('alive_archer', nil)
    SetDisabledObjectMode('alive_archer', DISABLED_INTERACT)
    sleep()
    SetMonsterSelectionType('alive_archer', 0)
    Touch.SetFunction('alive_archer',
    function(hero, object) -- разговор с ним
      if hero == 'Karlam' then
        MessageBox(mageQ.path..'alive_archer.txt')
        updateQuest(mageQ.name, 1, hero)
        PlayObjectAnimation(object, 'happy', ONESHOT)
        sleep(15)
        StopVisualEffects('aa_fx')
        RemoveObject(object)
      end
    end)
  end
end

-- наткнулись на следы битвы на болоте
function showDeadInBog(hero)
  if hero == 'Karlam' then
    BlockGame()
    MoveCamera(31, 118, 0, 0, 0, 0, 1, 1)
    OpenCircleFog(31, 118, 0, 3, 1)
    sleep(15)
    Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'deadBog', nil)
    MessageBox(mageQ.path..'dead_in_bog.txt', 'UnblockGame')
  end
end

-- тюрьмы чернокнижников
SetObjectEnabled('prison1', nil)
Touch.SetFunction('prison1',
function(hero, object)
  if hero == 'Karlam' then
    if mageQ.pr_status[1] == 0 then -- если первая закрыта
      MessageBox(mageQ.path..'prison1_closed.txt')
    else -- если открыта
      MessageBox(mageQ.path..'prison1_opened.txt')
      local func = function(hero) addCreatures(hero, CREATURE_GREMLIN_SABOTEUR, 40 - 5 * DIFF, CREATURE_MASTER_GENIE, 10 - DIFF) end
      Award(hero, func)
      Touch.OverrideFunction(object, 1,
      function(hero, object)
        ShowFlyingSign(rtext('Тюрьма пуста...'), object, -1, 7.0)
      end)
    end
  end
end)

-- в основном, аналогично первой
SetObjectEnabled('prison2', nil)
Touch.SetFunction('prison2',
function(hero, object)
  if hero == 'Karlam' then
    if mageQ.pr_status[2] == 0 then
      MessageBox(mageQ.path..'prison2_closed.txt')
    else
      MessageBox(mageQ.path..'prison2_opened.txt')
      Award(hero, nil, nil, {ARTIFACT_EARTHSLIDERS})
      Touch.OverrideFunction(object, 1,
      function(hero, object)
        ShowFlyingSign(rtext('Тюрьма пуста...'), object, -1, 7.0)
      end)
    end
  end
end)

-- здесь тоже
SetObjectEnabled('prison3', nil)
Touch.SetFunction('prison3',
function(hero, object)
  if hero == 'Karlam' then
    if mageQ.pr_status[3] == 0 then
      MessageBox(mageQ.path..'prison3_closed.txt')
    else
      if isActive(mageQ.name) then
        MessageBox(mageQ.path..'prison3_opened.txt')
        updateQuest(mageQ.name, 2, hero)
      else
        MessageBox(mageQ.path..'prison3_no_quest.txt')
      end
      Touch.OverrideFunction(object, 1,
      function(hero, object)
        ShowFlyingSign(rtext('Тюрьма пуста...'), object, -1, 7.0)
      end)
    end
  end
end)

-- засады у кристаллов, открывающих тюрьмы
function crys1Check(hero)
  if hero == 'Karlam' then
    CreateMonster('ambush', CREATURE_STALKER, 1, 83, 48,  0, 1, 1)
    sleep()
    PlayObjectAnimation('ambush', 'attack00', ONESHOT)
    sleep(8)
    if StartCombat(hero, nil, 3, -- бой с засадой
                   getRandFrom(CREATURE_ASSASSIN, CREATURE_STALKER), 141,
                   getRandFrom(CREATURE_BLOOD_WITCH, CREATURE_BLOOD_WITCH_2), 103,
                   getRandFrom(CREATURE_RAVAGER, CREATURE_BLACK_RIDER), 36) then
      UnblockPrison(1)
    end
  end
end

-- аналогично тому, что выше
function crys2Check(hero)
  if hero == 'Karlam' then
    CreateMonster('ambush', CREATURE_STALKER, 1, 90, 111, 0, 3, 1, 180)
    sleep()
    PlayObjectAnimation('ambush', 'attack00', ONESHOT)
    sleep(7)
    if StartCombat(hero, nil, 5,
                  getRandFrom(CREATURE_ASSASSIN, CREATURE_STALKER), 175,
                  getRandFrom(CREATURE_BLOOD_WITCH, CREATURE_BLOOD_WITCH_2), 131,
                  getRandFrom(CREATURE_RAVAGER, CREATURE_BLACK_RIDER), 45,
                  getRandFrom(CREATURE_MATRIARCH, CREATURE_SHADOW_MISTRESS), 15,
                  getRandFrom(CREATURE_BLACK_DRAGON, CREATURE_RED_DRAGON), 6) then
      UnblockPrison(2)
    end
  end
end

function crys3Check(hero)
  if hero == 'Karlam' then
    CreateMonster('ambush', CREATURE_STALKER, 1, 45, 118, 1, 3, 1, 45)
    sleep()
    PlayObjectAnimation('ambush', 'attack00', ONESHOT)
    sleep(7)
    if StartCombat(hero, nil, 4,
                  getRandFrom(CREATURE_ASSASSIN, CREATURE_STALKER), 189,
                  getRandFrom(CREATURE_BLOOD_WITCH, CREATURE_BLOOD_WITCH_2), 114,
                  getRandFrom(CREATURE_RAVAGER, CREATURE_BLACK_RIDER), 41,
                  getRandFrom(CREATURE_MATRIARCH, CREATURE_SHADOW_MISTRESS), 16) then
      UnblockPrison(3)
    end
  end
end

-- разблокировка тюрьмы по индексу уничтоженного кристалла
function UnblockPrison(index)
  local prison = 'prison'..index
  local crys = 'crys'..index
  local armor = 'crys_armor'..index
  local x, y, z = GetObjectPosition(prison)
  PlayObjectAnimation('ambush', 'death', ONESHOT_STILL)
  PlayVisualEffect(mageQ.prison_fx[index][1], crys)
  Play3DSound(mageQ.prison_fx[index][2], GetObjectPosition(crys))
  sleep(10)
  RemoveObject('ambush')
  RemoveObject(crys)
  sleep()
  -- 3 кристалл в подземке, тюрьма - нет
  local move = index == 3 and nil or 1
  ShowObject(prison, 1, move)
  sleep(10)
  PlayVisualEffect(USED_FX.ARCANE_CRYS_DEATH_FX, prison, '', 1, 1)
  Play3DSound(USED_SOUNDS.ARCANE_CRYS_DEATH_SOUND, x - 1, y - 1, z)
  sleep(3)
  PlayVisualEffect(USED_FX.ARCANE_CRYS_DEATH_FX, prison, '', -1, 1)
  Play3DSound(USED_SOUNDS.ARCANE_CRYS_DEATH_SOUND, x + 1, y - 1, z)
  sleep(3)
  PlayVisualEffect(USED_FX.ARCANE_CRYS_DEATH_FX, prison, '', 1, -1)
  Play3DSound(USED_SOUNDS.ARCANE_CRYS_DEATH_SOUND, x - 1, y + 1, z)
  sleep(3)
  PlayVisualEffect(USED_FX.ARCANE_CRYS_DEATH_FX, prison, '', -1, -1)
  Play3DSound(USED_SOUNDS.ARCANE_CRYS_DEATH_SOUND, x + 1, y + 1, z)
  sleep(5)
  RemoveObject(armor)
  mageQ.pr_status[index] = 1
  Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'crystal'..index, nil)
  -- во второй квестовая инфа
  if index == 2 then
    MessageBox(mageQ.path..'asassin_catched.txt')
    if isActive(mageQ.name) then
      updateQuest(mageQ.name, 3, 'Karlam')
    end
  end
end
  
  
-- бои на пути к Тургалу
Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'dp1', 'darkPath1')
Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'dp2', 'darkPath2')
Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'dp3', 'darkPath3')
Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'dp4', 'darkPath4')

Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'turgalFight', 'TurgalFight')

function darkPath1(hero)
  if hero == 'Karlam' then
    PlayVisualEffect(USED_FX.ICE_BOLT_FX, 'dp_crys11')
    Play3DSound(USED_SOUNDS.ICE_BOLT_SOUND, GetObjectPosition('dp_crys11'))
    PlayVisualEffect(USED_FX.ICE_BOLT_FX, 'dp_crys12')
    Play3DSound(USED_SOUNDS.ICE_BOLT_SOUND, GetObjectPosition('dp_crys12'))
    PlayAnims(AnimGroup[10], {'attack00'}, COND_SINGLE, ONESHOT)
    sleep(10)
    if StartCombat(hero, nil, 3,
                  CREATURE_HYDRA, 92,
                  CREATURE_CHAOS_HYDRA, 81,
                  CREATURE_ACIDIC_HYDRA, 83) then
      Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'dp1', nil)
      PlayAnims(AnimGroup[10], {'death'}, COND_SINGLE, ONESHOT_STILL)
      sleep(15)
      for i = 1, 3 do
        RemoveObject('dp_hydra'..i)
      end
    end
  end
end

function darkPath2(hero)
  if hero == 'Karlam' then
    PlayVisualEffect(USED_FX.STONE_SKIN_FX, 'dp_crys21')
    Play3DSound(USED_SOUNDS.STONE_SKIN_SOUND, GetObjectPosition('dp_crys21'))
    PlayVisualEffect(USED_FX.STONE_SKIN_FX, 'dp_crys22')
    Play3DSound(USED_SOUNDS.STONE_SKIN_SOUND, GetObjectPosition('dp_crys22'))
    PlayAnims(AnimGroup[11], {'attack00'}, COND_SINGLE, ONESHOT)
    sleep(10)
    if StartCombat(hero, nil, 5,
                  CREATURE_MINOTAUR_CAPTAIN, 252,
                  CREATURE_MINOTAUR_CAPTAIN, 241,
                  CREATURE_MINOTAUR_KING, 263,
                  CREATURE_MINOTAUR_KING, 257,
                  CREATURE_MINOTAUR, 404) then
      Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'dp2', nil)
      PlayAnims(AnimGroup[11], {'death'}, COND_SINGLE, ONESHOT_STILL)
      sleep(15)
      for i = 1, 5 do
        RemoveObject('dp_mino'..i)
      end
    end
  end
end

function darkPath3(hero)
  if hero == 'Karlam' then
    PlayVisualEffect(USED_FX.FIREBALL_FX, 'dp_crys31')
    Play3DSound(USED_SOUNDS.FIREBALL_SOUND, GetObjectPosition('dp_crys31'))
    PlayVisualEffect(USED_FX.FIREBALL_FX, 'dp_crys32')
    Play3DSound(USED_SOUNDS.FIREBALL_SOUND, GetObjectPosition('dp_crys32'))
    PlayAnims(AnimGroup[12], {'attack00'}, COND_SINGLE, ONESHOT)
    sleep(10)
    if StartCombat(hero, nil, 4,
                  CREATURE_BLOOD_WITCH_2, 195,
                  CREATURE_BLOOD_WITCH_2, 187,
                  CREATURE_BLOOD_WITCH, 203,
                  CREATURE_BLOOD_WITCH, 171) then
      Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'dp3', nil)
      PlayAnims(AnimGroup[12], {'death'}, COND_SINGLE, ONESHOT_STILL)
      sleep(15)
      for i = 1, 5 do
        RemoveObject('dp_fury'..i)
      end
    end
  end
end

function darkPath4(hero)
  if hero == 'Karlam' then
    PlayVisualEffect(USED_FX.LIGHTNING_BOLT_FX, 'dp_crys41')
    Play3DSound(USED_SOUNDS.LIGHTNING_BOLT_SOUND, GetObjectPosition('dp_crys41'))
    PlayVisualEffect(USED_FX.LIGHTNING_BOLT_FX, 'dp_crys42')
    Play3DSound(USED_SOUNDS.LIGHTNING_BOLT_SOUND, GetObjectPosition('dp_crys42'))
    PlayAnims(AnimGroup[13], {'attack00'}, COND_SINGLE, ONESHOT)
    sleep(10)
    if StartCombat(hero, nil, 3,
                  CREATURE_RED_DRAGON, 17,
                  CREATURE_BLACK_DRAGON, 15,
                  CREATURE_DEEP_DRAGON, 21) then
      Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'dp4', nil)
      PlayAnims(AnimGroup[13], {'death'}, COND_SINGLE, ONESHOT_STILL)
      sleep(15)
      for i = 1, 3 do
        RemoveObject('dp_drag'..i)
      end
    end
  end
end

-- добрались до Тургала - сценка и бой
function TurgalFight(hero)
  if hero == 'Karlam' then
    Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'turgalFight', nil)
    -- в теории, можно придти сюда без взятого квеста, поэтому ролик немного меняется
    -- в зависимости от этого
    -- сам бой с Тургалом важен независимо от наличия квеста
    if isActive(mageQ.name) then
      StartDialogScene(DIALOG_SCENES.TURGAL)
    else
      StartDialogScene(DIALOG_SCENES.TURGAL2)
    end
    SetCombatLight(COMBAT_LIGHTS.UGROUND)
    MakeHeroInteractWithObject(hero, 'Inagost') -- -> см результаты боя
  end
end

-- при смерти Тургала
function TurgalDead(hero)
  SetCombatLight(COMBAT_LIGHTS.CURRENT)
  Award(hero, nil, nil, {ARTIFACT_PLATE_MAIL_OF_STABILITY}) -- выдаем доспех героя
  SetObjectEnabled('darkPath_Portal', not nil) -- открываем портал на гору
  ShowObject('darkPath_Portal', 1)
  sleep(5)
  StopVisualEffects('dpp_fx')
  sleep(5)
  Touch.RemoveFunctions('darkPath_Portal')
  if isActive(mageQ.name) then -- если квест друида взят
    if QuestionBox(mageQ.path..'Turgal_end.txt') then -- даем выбор убить/захватить шпиона
      MessageBox(mageQ.path..'liddel_dead.txt')
      updateQuest(mageQ.name, 4, hero)
    else
      MessageBox(mageQ.path..'liddel_captured.txt')
      updateQuest(mageQ.name, 5, hero)
    end
  else -- иначе убираем возможность взять этот квест
    Touch.RemoveFunctions('mageTower')
    SetObjectEnabled('mageTower', not nil)
    MessageBox(rtext('Уничтожив демонопоклонника, вы забрали его редкий доспех. Кроме того, при нем обнаружился ключ от портала из пещеры'))
  end
end

-- если выбрали захватить, то будет засада от него
function LiddelAmbush(hero)
  if hero == 'Karlam' then
    BlockGame()
    CreateMonster('lAmbush1', CREATURE_WAR_DANCER, 1, 54, 34, 0, 3, 1, 180)
    CreateMonster('lAmbush2', CREATURE_SHADOW_MISTRESS, 1, 52, 38, 0, 3, 1, 61)
    CreateMonster('lAmbush3', CREATURE_SHARP_SHOOTER, 1, 54, 39, 0, 3, 1, 0)
    sleep(5)
    PlayObjectAnimation('lAmbush1', 'specability', ONESHOT)
    PlayObjectAnimation('lAmbush2', 'stir00', ONESHOT)
    PlayObjectAnimation('lAmbush3', 'rangeattack', ONESHOT)
    sleep(15)
    MessageBox(mageQ.path..'liddel_ambush.txt', 'UnblockGame')
    Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'liddelAmbush', nil)
    if StartCombat(hero, nil, 5,
                  getRandFrom(CREATURE_ASSASSIN, CREATURE_STALKER), 251,
                  getRandFrom(CREATURE_WAR_DANCER, CREATURE_BLADE_SINGER), 219,
                  getRandFrom(CREATURE_GRAND_ELF, CREATURE_SHARP_SHOOTER), 146,
                  getRandFrom(CREATURE_RAVAGER, CREATURE_BLACK_RIDER), 68,
                  getRandFrom(CREATURE_MATRIARCH, CREATURE_SHADOW_MISTRESS), 27) then
      sleep()
      BlockGame()
      PlayObjectAnimation('lAmbush1', 'death', ONESHOT_STILL)
      PlayObjectAnimation('lAmbush2', 'death', ONESHOT_STILL)
      PlayObjectAnimation('lAmbush3', 'death', ONESHOT_STILL)
      sleep(15)
      for i = 1, 3 do
        RemoveObject('lAmbush'..i)
      end
      sleep()
      MessageBox(mageQ.path..'ambush_end.txt', 'UnblockGame')
    end
  end
end

--------------------------------------------------------------------------------
-- Тайные тропы.
-- Феи, охраняющие тайные лесные тропы готовы открыть их для героя в обмен на небольшое число опыта.
-- Баал не может пройти по тропам до наступления вечной ночи, а после сильно замедляется, проходя по ним.
-- Число троп - 21
secret_path =
{
  name = 'SECRET_PATH',
  path = qPath..'SecretPath/',
  
  pathOpened = {}, -- таблица открытых троп, чтобы знать, какие тропы нужно разблокировать для ии при наступлении вечной ночи
  pathCount = 0, -- счетчик открытых троп
}

-- Стартовая блокировка троп
function InitPaths()
  for i = 1, 21 do
    SetRegionBlocked('tropa'..i, not nil)
    -- Trigger(REGION_ENTER_WITHOUT_STOP_TRIGGER, 'tropa'..i, 'BaalRemoveMP')
  end
end

-- логика касания фей-хранительниц
function InitFaeries()
  for i = 1, 21 do
    SetObjectEnabled('fairy'..i, nil)
    SetDisabledObjectMode('fairy'..i, DISABLED_INTERACT)
    SetMonsterNames('fairy'..i, MONSTER_NAME_SINGLE, oPath..'Fairy_name.txt') -- меняем имя
    SetObjectFlashlight('fairy'..i, 'fairy_fl')
    Touch.SetFunction('fairy'..i,
    function(hero, object)
      if hero == 'Karlam' then
        if isUnknown(secret_path.name) then -- если это первый разговор
          MessageBox(secret_path.path..'path_intro.txt') -- даем инфу о тропах
          startQuest(secret_path.name, hero)
          LockMinHeroSkillsAndAttributes(hero) -- почти 100% первой открытой тропой будет собсна первая, а терять редкий навык от ведьмы не круто
        end
        if QuestionBox(secret_path.path..'give_exp_to_fairy.txt') then -- запрашиваем опыт для открытия тропы
          -- if not isFailed(mainQ.names.enight) then -- если вечная ночь еще не началась
          SetRegionBlocked('tropa'..%i, nil, PLAYER_1) -- разблокируем проход для игрока, но не ИИ
          -- else
          --  SetRegionBlocked('tropa'..%i, nil) -- иначе разблокируем для всех
          -- end
          secret_path.pathCount = secret_path.pathCount + 1 -- обновляем счетчик открытых троп
          secret_path.pathOpened[secret_path.pathCount] = 'tropa'..%i -- дополняем таблицу открытых троп
          local exp_cost = (1000 + 500 * DIFF) * secret_path.pathCount
          TakeAwayHeroExp(hero, exp_cost) -- забираем соответствующее число опыта у героя
          updateQuest(secret_path.name, secret_path.pathCount, hero) -- устанавливаем прогресс на счетчик
          ShowFlyingSign({secret_path.path..'exp_lost.txt'; exp_lost = exp_cost}, hero, -1, 5.0)
          PlayObjectAnimation('fairy'..%i, 'cast', ONESHOT)
          sleep(20)
          RemoveObject('fairy'..%i) -- убираем фею
          if getProgress(secret_path.name) == 21 then -- если все тропы открыты
            finishQuest(secret_path.name, hero) -- квест завершен
            MessageBox(secret_path.path..'path_end.txt')
            Award(hero, nil, nil, {ARTIFACT_ROBE_OF_MAGI})
          end
        end
      end
    end)
  end
end

InitPaths()
InitFaeries()

--------------------------------------------------------------------------------
-- небольшой квест изумрудного дракона - принести поножи из кости дракона,
-- чтобы получить доступ в 'священную' часть леса

dragonQ =
{
  name = 'DRAGON_QUEST',
  path = qPath..'DragonQuest/'
}

-- логика разговора с драконом
SetObjectEnabled('greenDragon1', nil)
SetDisabledObjectMode('greenDragon1', DISABLED_INTERACT)
sleep()
SetMonsterSelectionType('greenDragon1', 0)
Touch.SetFunction('greenDragon1',
function(hero, object)
  if hero == 'Karlam' then
    if isUnknown(dragonQ.name) then -- первое касание?
      MessageBox(dragonQ.path..'dragonQ_start.txt')
      startQuest(dragonQ.name, hero)
    elseif getProgress(dragonQ.name) == 0 then -- пока не были в утопии?
      if QuestionBox(dragonQ.path..'dragonQ_temp.txt') and -- можно попробовать напасть
         StartCombat(hero, nil, 1, CREATURE_GOLD_DRAGON, 1000, nil, nil, nil, not nil) then
        RemoveObject(object)
        failQuest(dragonQ.name, hero)
      end
    elseif getProgress(dragonQ.name) == 1 then -- квест завершен?
      MessageBox(dragonQ.path..'dragonQ_end.txt')
      PlayObjectAnimation(object, 'happy', ONESHOT)
      sleep(20)
      RemoveObject(object)
      finishQuest(dragonQ.name, hero)
    end
  end
end)

-- бой в утопии
SetObjectEnabled('utopia1', nil)
Touch.SetFunction('utopia1',
function(hero, object)
  if hero == 'Karlam' then
    if not isActive(dragonQ.name) then
      MessageBox(dragonQ.path..'utopia1.txt')
    elseif getProgress(dragonQ.name) == 0 then
      if StartCombat(hero, nil, 4,
                    CREATURE_SHADOW_DRAGON, 27,
                    CREATURE_GOLD_DRAGON, 21,
                    CREATURE_RED_DRAGON, 18,
                    CREATURE_LAVA_DRAGON, 19) then
        updateQuest(dragonQ.name, 1, hero)
        Award(hero, nil, nil, {ARTIFACT_DRAGON_BONE_GRAVES})
        addGold(10000, hero)
        MarkObjectAsVisited(object, hero)
        Touch.OverrideFunction(object, 1,
        function(hero, object)
          if hero == 'Karlam' then
            ShowFlyingSign(rtext('Недобрый ветер воет в пустых коридорах...'), object, -1, 5.0)
          end
        end)
      end
    end
  end
end)

--------------------------------------------------------------------------------
-- небольшой, но очень важный квест астролога.

astroQ =
{
  name = 'ASTRO_QUEST',
  path = qPath..'Other/',
  
  -- по факту, эти флаги не имеют к квесту особого отношения, но они так же,
  -- как и он завязаны на кузнице артефактов, а другого логичного места описать их нет
  
  artTown_opened = 0, -- статус кузницы - закрыта/открыта/закрыта без возможности открытия
  know_removed = -1,
  know_msg = 0,
  
  bow_parts = 0, -- собранные части лука -> см. битвы в чащах энтов
  bow_crafted = 0 -- статус крафта лука
}

Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'astro_reg', 'astroMsg')

function astroMsg(hero)
  if hero == 'Karlam' then
    Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'astro_reg', nil)
    BlockGame()
    ShowObject('qAstro', 1, 1)
    MessageBox(astroQ.path..'astro_msg.txt', 'UnblockGame')
  end
end
    
-- логика разговора с астрологом
SetObjectEnabled('qAstro', nil)
Touch.SetFunction('qAstro',
function(hero, object)
  if hero == 'Karlam' then
    if isUnknown(astroQ.name) then -- первый раз зашли?
      MessageBox(astroQ.path..'astroQ_start.txt')
      startQuest(astroQ.name, hero)
    elseif getProgress(astroQ.name) == 0 then -- пока не нашли артефакты?
      MessageBox(astroQ.path..'astroQ_temp.txt')
    elseif getProgress(astroQ.name) == 1 then -- нашли?
      MessageBox(astroQ.path..'astroQ_end.txt')
      WarpHeroExp('Linaas', LEVELS[21 + diff])
      GiveHeroBattleBonus('Linaas', HERO_BATTLE_BONUS_INITIATIVE, 25 - 5 * DIFF)
      if StartCombat(hero, 'Linaas', 3,
                    CREATURE_WOOD_ELF, 200 + random(5),
                    CREATURE_GRAND_ELF, 180 + random(4),
                    CREATURE_SHARP_SHOOTER, 175 + random(5),
                    nil, nil, nil, not nil) then
        MessageBox(astroQ.path..'cape.txt')
        Award(hero, nil, nil, {ARTIFACT_SHAWL_OF_GREAT_LICH})
        finishQuest(astroQ.name, hero)
      end
      Touch.OverrideFunction(object, 1,
      function(hero, object)
        if hero == 'Karlam' then
          ShowFlyingSign(rtext('Может, стоит захватить с собой что-нибудь из изобретений этого чудака?'), object, -1, 5.0)
        end
      end)
    end
  end
end)

function RemoveKnowledge(hero)
  if GetHeroStat(hero, STAT_KNOWLEDGE) > 25 then
    astroQ.know_removed = GetHeroStat(hero, STAT_KNOWLEDGE) - 25
    ChangeHeroStat(hero, STAT_KNOWLEDGE, -astroQ.know_removed)
  end
end

function RestoreKnowledge(hero)
  if astroQ.know_removed ~= -1 then
    ChangeHeroStat(hero, STAT_KNOWLEDGE, astroQ.know_removed)
    astroQ.know_removed = -1
  end
end

-- логика доступа в кузницу артефактов
SetObjectEnabled('enter_artTown', nil)
Touch.SetFunction('enter_artTown',
function(hero, object)
  if not (GetHeroSkillMastery(hero, 17) > 0) then -- если нет мастера артефактов
    ShowFlyingSign(rtext('Вы не владеете навыком создания артефактов...'), hero, -1, 7.0)
    return
  end
  if astroQ.artTown_opened == 0 then -- если кузница закрыта
    TalkBoxForPlayers(PLAYER_1,
                      '/UI/AcademyCreatureArtifacts/WarForgeIcon.(Texture).xdb#xpointer(/Texture)',
                      wPath..'ArtTown/art_town_desc.txt',
                      wPath..'ArtTown/art_town_enter.txt', nil,
                      'artTown_answer', 1,
                      wPath..'ArtTown/art_town_desc.txt', nil, 0,
                      wPath..'ArtTown/art_town_answer1.txt',
                      wPath..'ArtTown/art_town_answer2.txt',
                      wPath..'ArtTown/art_town_answer3.txt',
                      wPath..'ArtTown/art_town_answer4.txt',
                      wPath..'ArtTown/art_town_answer5.txt') -- спрашиваем очень несерьезный пароль
  end
  if astroQ.artTown_opened == 1 then -- если открыто
    -- SetWarfogBehaviour(0, 0)
    if astroQ.know_msg == 0 then
      MessageBox(astroQ.path..'know_removed.txt')
      astroQ.know_msg = 1
    end
    RemoveKnowledge(hero)
    MakeHeroInteractWithObject(hero, 'art_town') -- запускаем в кузницу
    sleep()
    startThread(CheckArtTown, hero) -- запускаем поток, отслеживающий нахождение героя в кузнице
  end
  if astroQ.artTown_opened == 2 then
    ShowFlyingSign(rtext('Закрыто. Проводим обновление систем защиты.'), object, -1, 7.0)
  end
end)

-- проверяем правильность пароля
function artTown_answer(player, answer)
  if answer < 1 then return end -- если нажали закрыть

  if answer == 5 then -- верный ответ
    ShowFlyingSign(rtext('Пароль принят. Можете приступать к работе.'), 'Karlam', -1, 7.0)
    astroQ.artTown_opened = 1 -- отрываем кузницу
    SetRegionBlocked('bblock1', nil, PLAYER_2) -- при открытии кузницы Баалу открывается путь на гору
    sleep(10)
  else -- неправильный ответ
    ShowFlyingSign(rtext('Ошибка. Несанкционированная попытка вторжения. Активировать защитные механизмы.'), 'Karlam', -1, 7.0)
    sleep(10)
    if StartCombat('Karlam', nil, 7,
                  CREATURE_STEEL_GOLEM, 100000,
                  CREATURE_STEEL_GOLEM, 100000,
                  CREATURE_OBSIDIAN_GOLEM, 100000,
                  CREATURE_MARBLE_GARGOYLE, 250000,
                  CREATURE_MARBLE_GARGOYLE, 250000,
                  CREATURE_OBSIDIAN_GARGOYLE, 250000,
                  CREATURE_OBSIDIAN_GARGOYLE, 250000,
                  nil, nil, nil, not nil) then
      astroQ.artTown_opened = 2
    end
  end
end

-- проверка нахождения героя в кузнице
-- есть небольшая проблема, что при выходе из города, нужно сделать шаг от
-- объекта, чтобы поток завершился. Если вообще не проверять нахождение героя во
-- внешнем гарнизоне, то он просто пропадает(герой, в смысле).
-- В общем, немного некрасиво, но некритично
function CheckArtTown(hero)
  while IsHeroInTown(hero, 'art_town', 1, 0) do sleep() end
  SetObjectOwner('art_town', PLAYER_3)
  RestoreKnowledge(hero)
  -- SetWarfogBehaviour(1, 1)
  if astroQ.bow_crafted == 0 and astroQ.bow_parts == 3 then -- если собраны части лука
    MessageBox(wPath..'Bow/craft_bow.txt')
    Award(hero, nil, nil, {ARTIFACT_UNICORN_HORN_BOW}) -- выдать лук
    astroQ.bow_crafted = 1
  end

  if getProgress(astroQ.name) == 0 then -- если квест астролога активен
   ShowFlyingSign(rtext('Образцы мини-артефактов получены'), hero, -1, 7.0)
   updateQuest(astroQ.name, 1, hero)
  end
end

--------------------------------------------------------------------------------
-- квест русалки
-- зачистить храм от нечисти в обмен на сведения о фениксах и корону льва

maidQ =
{
  name = 'MAID_QUEST',
  path = qPath..'MaidQuest/'
}

Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'maidAttract', 'showMaid')
-- чтобы игрок не упустил русалку из виду
function showMaid(hero)
  if hero == 'Karlam' then
    Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'maidAttract', nil)
    BlockGame()
    ShowObject('maid1', 1, 1)
    sleep(5)
    MessageBox(maidQ.path..'show_maid.txt', 'UnblockGame')
  end
end

-- разговор с русалкой
SetObjectEnabled('maid1', nil)
Touch.SetFunction('maid1',
function(hero, object)
  if hero == 'Karlam' then
    if isUnknown(maidQ.name) then -- первый раз зашли?
      MessageBox(maidQ.path..'maid_start.txt')
      startQuest(maidQ.name, hero)
    elseif getProgress(maidQ.name) == 1 then -- вернулись с выполненным квестом?
      finishQuest(maidQ.name, hero)
      MessageBox(maidQ.path..'maid_finish.txt')
      Award(hero, nil, nil, {ARTIFACT_CROWN_OF_COURAGE})
      updateQuest(mainQ.names.phoenix, 1, hero)
      Touch.RemoveFunctions(object)
      SetObjectEnabled(object, not nil)
    elseif getProgress(maidQ.name) == 0 then -- квест в процессе?
      MessageBox(maidQ.path..'maid_quest_active.txt')
    end
  end
end)

-- бой в храме
SetObjectEnabled('lake_temple', nil)
Touch.SetFunction('lake_temple',
function(hero, object)
  if hero == 'Karlam' then
    if StartCombat(hero, nil, 5,
                  CREATURE_DEATH_KNIGHT, 38,
                  89, 46,
                  CREATURE_MUMMY, 111,
                  CREATURE_BALOR, 25,
                  CREATURE_SHADOW_DRAGON, 16) then
      PlayVisualEffect(USED_FX.HOLY_WORD_FX, object)
      Play3DSound(USED_SOUNDS.HOLY_WORD_SOUND, GetObjectPosition(object))
      sleep(15)
      StopVisualEffects('lt_fx1')
      StopVisualEffects('lt_fx2')
      sleep(5)
      MessageBox(maidQ.path..'lake_temple_end.txt')
      updateQuest(maidQ.name, 1, hero)
      MarkObjectAsVisited(object, hero)
      Touch.OverrideFunction(object, 1,
      function(hero, object)
        if hero == 'Karlam' then
          ShowFlyingSign(rtext('Храм очищен и ждет обратно своих обитателей...'), object, -1, 5.0)
        end
      end)
    end
  end
end)

--------------------------------------------------------------------------------
-- прочее

-- ведьма в стартовой локе - выдает атаку/защиту

SetObjectEnabled('witch1', nil)
Touch.SetFunction('witch1',
function(hero, object)
  if hero == 'Karlam' then
    if QuestionBox(wPath..'Witch/witch1.txt') then
      GiveHeroSkill(hero, SKILL_OFFENCE)
      ShowFlyingSign(wPath..'Witch/wAttack.txt', object, -1, 7.0)
    else
      GiveHeroSkill(hero, SKILL_DEFENCE)
      ShowFlyingSign(wPath..'Witch/wLeader.txt', object, -1, 7.0) -- раньше была лидерка, менять тупА лень
    end
    local func = function(hero) addCreatures(hero, CREATURE_COMBAT_MAGE, 17 - DIFF) end
    Award(hero, func)
    Touch.RemoveFunctions(object)
  end
end)

--------------------------------------------------------------------------------
-- блоки на стражах границ, т.к. при получении ключа игра считает их проходимыми
-- и Баал может появиться вне досягаемости игрока

for i = 3, 5 do
  Trigger(REGION_ENTER_WITHOUT_STOP_TRIGGER, 'bblock'..i, 'baalUnblock'..i)
end

function baalUnblock3(hero)
  SetRegionBlocked('bblock3', nil)
  Trigger(REGION_ENTER_WITHOUT_STOP_TRIGGER, 'bblock3', nil)
end

function baalUnblock4(hero)
  SetRegionBlocked('bblock4', nil)
  Trigger(REGION_ENTER_WITHOUT_STOP_TRIGGER, 'bblock4', nil)
end

function baalUnblock5(hero)
  SetRegionBlocked('bblock5', nil)
  Trigger(REGION_ENTER_WITHOUT_STOP_TRIGGER, 'bblock5', nil)
end

--
--------------------------------------------------------------------------------
-- блоки на некоторых порталах

Trigger(REGION_ENTER_WITHOUT_STOP_TRIGGER, 'portalBlock2', 'unblockPortal')

function unblockPortal()
  for i = 1, 2 do SetRegionBlocked('portalBlock'..i, nil) end
  Trigger(REGION_ENTER_WITHOUT_STOP_TRIGGER, 'portalBlock2', nil)
  StopVisualEffects('portal1_fx')
  SetObjectEnabled('portal1', not nil)
  Touch.RemoveFunctions('portal1')
end

SetObjectEnabled('darkPath_Portal', nil)
SetDisabledObjectMode('darkPath_Portal', DISABLED_INTERACT)
Touch.SetFunction('darkPath_Portal',
function(hero, object)
  ShowFlyingSign(rtext('Неизвестная магия блокирует портал'), object, -1, 7.0)
end)

SetObjectEnabled('portal1', nil)
SetDisabledObjectMode('portal1', DISABLED_INTERACT)
Touch.SetFunction('portal1',
function(hero, object)
  if hero == 'Karlam' then
    ShowFlyingSign(rtext('Портал неактивен...'), object, -1, 7.0)
  end
end)

--------------------------------------------------------------------------------
-- бои в чащах энтов - получение частей лука
-- первый бой связан с главным квестом, поэтому описан там

SetObjectEnabled('elf_treasure2', nil)
Touch.SetFunction('elf_treasure2',
function(hero, object)
  if hero == 'Karlam' then
    if StartCombat(hero, nil, 5,
                  CREATURE_GRAND_ELF, 106,
                  CREATURE_SHARP_SHOOTER, 92,
                  CREATURE_WAR_UNICORN, 32,
                  CREATURE_TREANT_GUARDIAN, 16,
                  CREATURE_ANGER_TREANT, 15) then
      ShowFlyingSign(wPath..'Bow/got_wood_part.txt', hero, -1, 5.0)
      sleep(5)
      addGold(12000, hero)
      astroQ.bow_parts = astroQ.bow_parts + 1
      Touch.RemoveFunctions(object)
      SetObjectEnabled(object, not nil)
    end
  end
end)

SetObjectEnabled('elf_treasure3', nil)
Touch.SetFunction('elf_treasure3',
function(hero, object)
  if hero == 'Karlam' then
    if StartCombat(hero, nil, 6,
                  CREATURE_DRYAD, 334,
                  CREATURE_SPRITE, 361,
                  CREATURE_DRUID_ELDER, 68,
                  CREATURE_WHITE_UNICORN, 37,
                  CREATURE_ANGER_TREANT, 23,
                  CREATURE_RAINBOW_DRAGON, 7) then
      ShowFlyingSign(wPath..'Bow/got_silk_part.txt', hero, -1, 5.0)
      sleep(5)
      addGold(18000, hero)
      astroQ.bow_parts = astroQ.bow_parts + 1
      Touch.RemoveFunctions(object)
      SetObjectEnabled(object, not nil)
    end
  end
end)
--
--------------------------------------------------------------------------------
-- проклятые(и не только) двеллинги и логика работы с ними

dwells =
{
  counts = {2, 2, 2, 1}, -- число двеллингов соответствующего уровня
  currentDwell = ' ', -- имя текущего двеллинга в обработке
  cursedDwells = {}, -- таблица проклятых двеллингов
  cd_n = 0, -- их число

  -- потенциальные существа в охранах по тиру
  army =
  {
    {CREATURE_IMP, CREATURE_SKELETON_ARCHER, CREATURE_QUASIT, CREATURE_SKELETON_WARRIOR},
    {CREATURE_HORNED_DEMON, CREATURE_ZOMBIE, CREATURE_HORNED_LEAPER, CREATURE_DISEASE_ZOMBIE},
    {CREATURE_CERBERI, CREATURE_GHOST, CREATURE_FIREBREATHER_HOUND, CREATURE_POLTERGEIST},
    {CREATURE_INFERNAL_SUCCUBUS, CREATURE_VAMPIRE_LORD, CREATURE_SUCCUBUS_SEDUCER, CREATURE_NOSFERATU},
    {CREATURE_FRIGHTFUL_NIGHTMARE, CREATURE_DEMILICH, CREATURE_HELLMARE, CREATURE_LICH_MASTER},
    {CREATURE_BALOR, CREATURE_WRAITH, CREATURE_PIT_SPAWN, CREATURE_BANSHEE},
    {CREATURE_ARCHDEVIL, CREATURE_SHADOW_DRAGON, CREATURE_ARCH_DEMON, CREATURE_HORROR_DRAGON}
  },

  -- коэффициент сложности от уровня двеллинга
  dwell_coef = {3, 3.5, 4, 4.5},

  -- коэффициент численности существ по тиру
  crt_coef = {38, 25, 12, 7, 3.5, 2, 1},

  -- стоимость снятия проклятия по уровню двеллинга
  cost =
  {
    {[0] = 10; 0, 0, 5, 0, 0, 3000},
    {[0] = 10; 10, 0, 5, 0, 0, 5000},
    {[0] = 15; 12, 0, 0, 0, 10, 8000},
    {[0] = 20; 15, 7, 10, 7, 10, 15000}
  }
}

-- для стартовой сортировки и блокировки двеллингов
-- если двеллинг принадлежит 3 игроку, то взаимодействие с ним отключается,
-- однако, он влияет на число подкреплений в городе эльфов
-- если не принадлежит никому, то он проклят и заносится в соответствующую таблицу
-- проклятие может быть снято и тогда двеллинг перейдет в первую категорию
function InitDwells()
  for i, type in {'FAIRIE_TREE', 'WOOD_GUARD_QUARTERS', 'HIGH_CABINS', 'PRESERVE_MILITARY_POST'} do
    for j, dwell in GetObjectNamesByType('BUILDING_'..type) do
      SetObjectEnabled(dwell, nil)
      if GetObjectOwner(dwell) == PLAYER_NONE then
        dwells.cursedDwells[dwell] = {state = 0, rang = i}
        PlayVisualEffect(USED_FX.RUINED_TOWER_FX, dwell, dwell..'_effect')
        SetObjectFlashlight(dwell, 'curse_fl')
        Touch.SetFunction(dwell, DwellState)
      else
        SetDisabledObjectMode(dwell, DISABLED_BLOCKED)
      end
    end
  end
  -- print('dwells sorted')
end

-- при касании двеллинга, определяет его индекс в глобальной таблице,
-- далее работает в зависимости от его параметра state
function DwellState(hero, object)
  if GetObjectOwner(hero) == PLAYER_1 then
    -- еще не заходили сюда?
    if dwells.cursedDwells[object].state == 0 then
      MessageBox(wPath..'Dwells/Curse.txt')
      dwells.cursedDwells[object].state = 1
      MakeHeroInteractWithObject(hero, object)
    -- нужно проводить бой?
    elseif dwells.cursedDwells[object].state == 1 then
      if QuestionBox(wPath..'Dwells/dwell_fight.txt') then
        local count = dwells.cursedDwells[object].rang + 3 -- число стеков
        local limit = count * 2
        local args = {}
        -- заполняем пары (id - численность) стеков
        for i = 1, limit - 1, 2 do
          args[i] = getRandFromT(dwells.army[(i + 1)/2])
          args[i + 1] = dwells.dwell_coef[count - 3] * dwells.crt_coef[(i + 1)/2] + random(limit - i)
        end
        if StartCombat(hero, nil, count,
                      args[1], args[2], args[3], args[4], args[5], args[6],
                      args[7], args[8], args[9], args[10], args[11], args[12],
                      args[13], args[14]) then
          dwells.cursedDwells[object].state = 2
          -- коэффициент для некст двеллов обновить уже здесь, иначе можно абузить
          dwells.dwell_coef[dwells.cursedDwells[object].rang] = dwells.dwell_coef[dwells.cursedDwells[object].rang] + 1
          MakeHeroInteractWithObject(hero, object)
        end
      end
    -- нужно отдавать ресы?
    elseif dwells.cursedDwells[object].state == 2 then
      if QuestionBox(wPath..'Dwells/dwell_res'..dwells.cursedDwells[object].rang..'.txt') then
        if RemovePlayerResT(PLAYER_1, dwells.cost[dwells.cursedDwells[object].rang]) then
          dwells.counts[dwells.cursedDwells[object].rang] = dwells.counts[dwells.cursedDwells[object].rang] + 1
          -- эффекты/перенастройка
          ShowFlyingSign(rtext('Проклятие успешно снято!'), object, -1, 7.0)
          SetObjectOwner(object, PLAYER_3)
          PlayVisualEffect(USED_FX.HOLY_WORD_FX, object)
          Play3DSound(USED_SOUNDS.HOLY_WORD_SOUND, GetObjectPosition(object))
          sleep(15)
          StopVisualEffects(object..'_effect')
          ResetObjectFlashlight(object)
          Touch.RemoveFunctions(object)
          SetDisabledObjectMode(object, DISABLED_BLOCKED)
        else
          MessageBox(wPath..'Dwells/no_res.txt')
        end
      end
    end
  end
end

InitDwells()