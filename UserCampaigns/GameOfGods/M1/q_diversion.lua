--------------------------------------------------------------------------------
-- Диверсия в Хомодоре.
-- Старт - разговор с гномом - дает инфу о подземном тоннеле, который имеет выход в одной из шахт
-- оставляют войска и идут вдвоем в подземку
-- в шахтах могут быть нежить и мантикоры
-- после выхода взрываем стену
-- одним героем отвлекаем демона, другим включаем портал, через который прибывают оставленные войска

Telgar = 'Telgar'

diversion =
{
  name = 'DIVERSION',
  path = q_path..'Diversion/',
  
  --
  mine_out_chanse = 0,
  mines_entered = {},
  --
  ruined_wall = '/MapObjects/WP/DD_Wall_Ruined2.(AdvMapStaticShared).xdb#xpointer(/AdvMapStaticShared)',

  Init =
  function()
    DeployReserveHero('Deleb', RegionToPoint('deleb_start'))
    while not IsObjectExists('Deleb') do
      sleep()
    end
    EnableHeroAI('Deleb', nil)
    --
    EnableHeroAI('Telgar', nil)
    Touch.DisableHero('Telgar')
    Touch.SetFunction('Telgar', '_talk', Diversion_TelgarTalk)
    --
    for i = 1, 4 do
      Touch.DisableObject('div_mine_0'..i, DISABLED_INTERACT)
      Touch.SetFunction('div_mine_0'..i, '_enter', Diversion_MineOut)
    end
    --
    startThread(Diversion_HomodorFX)
    --
  end
}

function Diversion_HomodorFX()
  PlayObjectAnimation('test_wagon', 'death', ONESHOT_STILL)
  PlayObjectAnimation('wagon_2', 'death', ONESHOT_STILL)
  while 1 do
    PlayFX('Berserk_rune', 'hmd_bers_emitter')
    PlayFX('Revive_rune', 'hmd_rev_emitter')
    PlayFX('Charge_rune', 'hmd_charge_emitter')
    PlayFX('Dragonform_rune', 'hmd_df_emitter')
    PlayFX('Stunning_rune', 'hmd_stun_emitter')
    PlayFX('Ethereal_rune', 'hmd_eth_emitter')
    sleep(10)
  end
end

function Diversion_TelgarTalk(hero, object)
  if IsUnknown(diversion.name) then
    MessageBox(rtext('Диверсия: стартовый диалог'))
    StartQuest(diversion.name, hero)
    Touch.DisableObject('div_start_dung')
    Touch.SetFunction('div_start_dung', '_enter', Diversion_StartDungEnter)
    GiveBorderguardKey(PLAYER_1, RED_KEY)
  end
end

function Diversion_StartDungEnter(hero, object)
  if GetProgress(diversion.name) == 0 then
    local count = CalcHeroCreatures(hero)
    if count < 6 then
      if QuestionBox(diversion.path..'start_dung_enter.txt') then
        Touch.RemoveFunctions(object)
        SetObjectEnabled(object, 1)
        sleep()
        MakeHeroInteractWithObject(hero, object)
--        sleep()
--        Touch.DisableObject(object)
--        Touch.SetFunction(object, '_enter', Diversion_StartDungEnter)
        BlockGame()
        ShowObject(hero, 1)
        sleep(3)
        SetObjectPosition('Telgar', RegionToPoint('div_telgar_start'))
        sleep(10)
        ShowObject('div_dung_out', 1)
        sleep(7)
        RazeBuilding('div_dung_out')
        sleep(10)
        MessageBox(rtext('Диверсия: вход разрушен'), 'UnblockGame')
        --SetObjectOwner(Telgar, PLAYER_1)
        UpdateQuest(diversion.name, 1, hero)
      end
    else
      MessageBox(rtext('Диверсия: необходимо иметь 5 или меньше существ для старта задания'))
    end
  end
end

function Diversion_MineOut(hero, object)
  if not diversion.mines_entered[object] then
    local curr_chanse = 1 + random(99)
    if curr_chanse < diversion.mine_out_chanse then
      SetObjectPosition(hero, RegionToPoint('div_mine_out'))
      sleep(3)
      SetObjectPosition('Telgar', RegionToPoint('div_telgar_mine_out'))
      startThread(Diversion_WallDestroyStartThread)
    else
      -- файт
      diversion.mines_entered[object] = 1
      diversion.mine_out_chanse = diversion.mine_out_chanse + 25
    end
  else
    MessageBox(rtext('Диверсия: шахта уже проверена'))
  end
end

function Diversion_WallDestroyStartThread(hero, thread)
  -- для предотвращения бага с несрабатыванием перемещения после тп
--  if not thread then
--    startThread(Diversion_WallDestroyStartThread, 1)
--  end
  -- бесконечный ход для Тельгара
  local func = function() return GetProgress(diversion.name) == 1 end
  startThread(UnlimMove, Telgar, func)
  startThread(
  function()
    local x, y, z = RegionToPoint('div_telgar_wall_move')
    while 1 do
      MoveHeroRealTime('Telgar', x, y, z)
      local tx, ty, tz = GetObjectPosition(Telgar)
      if tx == x and ty == y then
        SetObjectRotation('Telgar', 133)
        sleep(7)
        MessageBox(rtext('Диверсия: подойти к Тельгару и взорвать стену'))
        Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'wall_destroy_reg', 'Diversion_WallDestroy')
        UpdateQuest(diversion.name, 2, %hero)
        break
      end
      sleep()
    end
  end)
end

function Diversion_WallDestroy(hero, region)
  Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'wall_destroy_reg', nil)
  local x, y = GetObjectPosition('wall_block_to_ruin')
  PlayFX('Fireball', 'wall_block_to_ruin')
  PlayFX('Fireball', 'wall_block_to_ruin', '', 0.7)
  sleep(2)
  RemoveObject('wall_block_to_ruin')
  sleep(5)
  CreateStatic('wall_ruins', diversion.ruined_wall, x, y - 0.5, GROUND, 296)
  --
  Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'div_imp_ambush_1', 'DiversionImpAmbush')
  Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'div_imp_ambush_2', 'DiversionImpAmbush')
  --
  Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'div_bridge_start', 'DiversionBridgeStartTalk')
  Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'div_bridge_end', 'DiversionBridgeSabotage')
  --
end

function DiversionImpAmbush(hero, region)
  Trigger(REGION_ENTER_AND_STOP_TRIGGER, region, nil)
  if region == 'div_imp_ambush_1' then
    if StartCombat(hero, nil, 3, CREATURE_IMP, 40, CREATURE_QUASIT, 33, CREATURE_QUASIT, 31, nil, nil, nil, 1) then
      PlayObjectAnimation('div_imp_ambush_1_1', 'death', ONESHOT_STILL)
      PlayObjectAnimation('div_imp_ambush_1_2', 'death', ONESHOT_STILL)
      sleep(15)
      RemoveObjects('div_imp_ambush_1_1', 'div_imp_ambush_1_2')
    end
  else
    if StartCombat(hero, nil, 5, CREATURE_IMP, 60, CREATURE_QUASIT, 43, CREATURE_QUASIT, 41, CREATURE_FAMILIAR, 36, CREATURE_FAMILIAR, 47, nil, nil, nil, 1) then
      for i = 1, 3 do
        PlayObjectAnimation('div_imp_ambush_2_'..i, 'death', ONESHOT_STILL)
      end
      sleep(15)
      RemoveObjects('div_imp_ambush_2_1', 'div_imp_ambush_2_2', 'div_imp_ambush_2_3')
    end
  end
end

function DiversionBridgeStartTalk(hero, region)
  Trigger(REGION_ENTER_AND_STOP_TRIGGER, region, nil)
  ShowObject(Deleb, 1, 1)
  sleep(15)
  MessageBox(rtext('Диверсия: армия демонов заметила нас!'))
  SetRegionBlocked('div_deleb_block', 1, PLAYER_3)
  startThread(DiversionDelebMove)
end

function DiversionDelebMove()
  while IsObjectExists(Deleb) do
    while not IsPlayerCurrent(PLAYER_3) do
      sleep()
    end
    if CanMoveHero(Deleb, GetObjectPosition(Karlam)) then
      MoveHeroRealTime(Deleb, GetObjectPosition(Karlam))
    else
      MoveHeroRealTime(Deleb, 51, 155, GROUND)
    end
    sleep()
  end
end

function DiversionBridgeSabotage(hero, region)
  BlockGame()
  local x1, y1, z1 = RegionToPoint('div_grem_point_01')
  local x2, y2, z2 = RegionToPoint('div_grem_point_02')
  CreateMonster('grem_01', CREATURE_GREMLIN_SABOTEUR, 1, x1, y1, z1, 3, 1, 282)
  CreateMonster('grem_02', CREATURE_GREMLIN_SABOTEUR, 1, x2, y2, z2, 3, 1, 282)
  while not (IsObjectExists('grem_01') and IsObjectExists('grem_02')) do
    sleep()
  end
  sleep(5)
  PlayObjectAnimation('grem_01', 'specability', ONESHOT)
  PlayObjectAnimation('grem_02', 'specability', ONESHOT)
  sleep(10)
  PlayFX('Sabotage', 'div_bridge_to_remove')
  sleep(10)
  UnblockGame()
  Trigger(REGION_ENTER_WITHOUT_STOP_TRIGGER, 'div_bridge_crash', 'DiversionBridgeCrash')
  RemoveObjects('grem_01', 'grem_02')
end

function DiversionBridgeCrash(hero, region)
  if hero == 'Deleb' then
    BlockGame()
    ShowObject(Deleb, 1)
    sleep(5)
    PlayFX('Fireball', 'div_bridge_to_remove')
    sleep(10)
    RemoveObject('div_bridge_to_remove')
    sleep(5)
    RemoveObject('Deleb')
    UnblockGame()
    Trigger(REGION_ENTER_WITHOUT_STOP_TRIGGER, region, nil)
    SetRegionBlocked(region, 1)
  end
end