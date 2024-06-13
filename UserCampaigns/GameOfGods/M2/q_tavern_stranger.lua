--------------------------------------------------------------------------------
--

ts_q =
{
  name = 'TAVERN_STRANGER',
  path = q_path..'Sec/TavernStranger',
  
  objects_to_disable =
  {
    ['ts_grave_01'] = {name = 'ts_grave_01_n', desc = 'ts_grave_01_d'},
    ['ts_grave_02'] = {name = 'ts_grave_02_n', desc = 'ts_grave_02_d'},
    ['ts_grave_03'] = {name = 'ts_grave_03_n', desc = 'ts_grave_03_d'},
    ['ts_grave_04'] = {name = 'ts_grave_04_n', desc = 'ts_grave_04_d'},
    ['ts_grave_05'] = {name = 'ts_grave_05_n', desc = 'ts_grave_05_d'},
  },
  
  Init =
  function()
    for object, info in ts_q.objects_to_disable do
      Touch.DisableObject(object, nil, o_names_path..info.name..'.txt', o_names_path..info.desc..'.txt')
    end
  end
}

function TS_Start(hero, object)
  -- условие запуска
  if (hero ~= Karlam) or (GetProgress(MKeepersQ.sec.stranger) ~= 1) then
    return
  end
  -- логика разговоров в таверне
  if IsUnknown(ts_q.name) then
    -- диалог
    StartQuest(ts_q.name, hero)
  else
    local progress = GetProgress(ts_q.name)
    if progress == 0 then
      MessageBox(ts_q.path..'p0_temp.txt')
    else
    end
  end
end