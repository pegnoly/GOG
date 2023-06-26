Varis = 'Varis'
Verciz = 'Verciz'

varis_q =
{
  name = 'VARIS_QUEST',
  path = q_path..'VarisQuest/',
  start_talk = 0,
  Init =
  function()
    EnableHeroAI(Varis, nil)
    Touch.DisableHero(Varis)
    Touch.SetFunction(Varis, '_talk', VarisQ_VarisTalk)
    Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'varis_q_sawmill_info', 'VarisQ_SawmillMsg')
    Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'varis_q_show_ships', 'VarisQ_ShipMsg')
    Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'varis_q_verciz_attack', 'VarisQ_VercizAttack')
  end
}

-- логика диалога с Варис
function VarisQ_VarisTalk(hero, object)
  -- квест не взят?
  if IsUnknown(varis_q.name) then
    -- настройка диалога под героя, который коснулся Варис
    m_dialog_sets['varis_start'][2][1] = hero
    m_dialog_sets['varis_start'][2].name = GetNameAsValue(hero, 1)
    StartMiniDialog(varis_q.path..'StartDialog/', 1, 3, m_dialog_sets['varis_start'])
    StartQuest(varis_q.name, hero)
    startThread(VarisQ_Start)
  else
    local progress = GetProgress(varis_q.name)
    if progress == 0 then
      MessageBox(rtext('Грифоны становятся совсем безумными! Поскорее разберись с этим туманом...'))
    elseif progress == 1 then -- развеяли туман?
      for k, v in {2, 4, 6} do
        m_dialog_sets['varis_p1'][v][1] = hero
        m_dialog_sets['varis_p1'][v].name = GetNameAsValue(hero, 1)
      end
      StartMiniDialog(varis_q.path..'FogRevealedDialog/', 1, 7, m_dialog_sets['varis_p1'])
      startThread(VarisQ_FlyToNecroLands)
    end
  end
end

function VarisQ_Start()
  Trigger(REGION_ENTER_AND_STOP_TRIGGER, 'varis_q_elem_fight', 'VarisQ_ElemFight')
end

-- бой с элементалями в черном тумане
function VarisQ_ElemFight(hero, region)
  if StartCombat(hero, nil, 6, CREATURE_DARK_ELEMENTAL, 134, CREATURE_DARK_ELEMENTAL, 131, CREATURE_DARK_ELEMENTAL, 155,
                 CREATURE_DARK_ELEMENTAL, 124, CREATURE_AIR_ELEMENTAL, 202, CREATURE_AIR_ELEMENTAL, 303, nil, nil, nil, 1) then
    Trigger(REGION_ENTER_AND_STOP_TRIGGER, region, nil)
    startThread(VarisQ_RemoveFog)
    UpdateQuest(varis_q.name, 1, hero)
  end
end

function VarisQ_RemoveFog()
  for i = 1, 98 do
    RemoveObject('black_fog_0'..i)
  end
end

-- полет Варис в земли некромантов
function VarisQ_FlyToNecroLands()
  BlockGame()
  PlayObjectAnimation('varis_grif_01', 'specability1', ONESHOT)
  PlayObjectAnimation('varis_grif_02', 'specability1', ONESHOT)
  sleep(7)
  RemoveObjects('varis_grif_01', 'varis_grif_02')
  sleep(10)
  SetObjectPosition(Varis, RegionToPoint('varis_q_varis_start_point'))
  sleep(5)
  ShowObject(Varis, 1)
  sleep(3)
  SetObjectOwner(Varis, PLAYER_1)
  StartMiniDialog(varis_q.path..'VarisArrivedDialog/', 1, 1, m_dialog_sets['varis_arrived'])
  UpdateQuest(varis_q.name, 2, Varis)
  sleep()
  UnblockGame()
end

function VarisQ_SawmillMsg(hero, region)
  Trigger(REGION_ENTER_AND_STOP_TRIGGER, region, nil)
  StartMiniDialog(varis_q.path..'SawmillInfoDialog/', 1, 1, m_dialog_sets['varis_sawmill'])
end

function VarisQ_ShipsMsg(hero, region)
  Trigger(REGION_ENTER_AND_STOP_TRIGGER, region, nil)
  StartMiniDialog(varis_q.path..'ShowShipsDialog/', 1, 1, m_dialog_sets['varis_ships'])
end

function VarisQ_VercizAttack(hero, region)
  Trigger(REGION_ENTER_AND_STOP_TRIGGER, region, nil)
  MoveHeroRealTime(Verciz, GetObjectPosition(Varis))
end