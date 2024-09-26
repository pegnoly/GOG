--------------------------------------------------------------------------------
-- реализация Арены Героев
--------------------------------------------------------------------------------
function AvoWave()
  local up = arena_of_heroes.current_wave_period
  DeployReserveHero(Avo, RegionToPoint('ah_avo_point'))
  sleep()
  Touch.DisableHero(Avo)
  Touch.SetFunction(Avo, '_avo_fight',
  function(hero, object)
    if ArenaOfHeroesCombat(hero, Avo) then
      RemoveObject(Avo)
      SetGameVar('arena_of_heroes_combat', 'none')
      arena_of_heroes.current_wave = arena_of_heroes.current_wave + 1
      arena_of_heroes.current_wave_period = arena_of_heroes.current_wave_period == arena_of_heroes.wave_period_max and 1 or arena_of_heroes.current_wave_period + 1
      SetGameVar('ah_curr_up', arena_of_heroes.current_wave_period)
    else
      arena_of_heroes.Reset()
    end
  end)
end

function GoblinsWave()
  local up = arena_of_heroes.current_wave_period
  local func =
  function(hero, object)
    if ArenaOfHeroesCombat(hero, nil, 1, 925, 1000) then
      for i = 1, 4 do
        RemoveObject('ah_gob_'..i)
      end
      SetGameVar('arena_of_heroes_combat', 'none')
      arena_of_heroes.current_wave = arena_of_heroes.current_wave + 1
      arena_of_heroes.current_wave_period = arena_of_heroes.current_wave_period == arena_of_heroes.wave_period_max and 1 or arena_of_heroes.current_wave_period + 1
      SetGameVar('ah_curr_up', arena_of_heroes.current_wave_period)
    else
      arena_of_heroes.Reset()
    end
  end
  for i = 1, 4 do
    local x, y, f = RegionToPoint('ah_gob_'..i)
    CreateMonster('ah_gob_'..i, 925, 1000, x, y, f, 3, 1)
    sleep()
    Touch.DisableMonster('ah_gob_'..i)
    Touch.SetFunction('ah_gob_'..i, '_ah_fight', func)
  end
end

function ChaloPaiWave()
  local up = arena_of_heroes.current_wave_period
  DeployReserveHero(ChaloPai, RegionToPoint('ah_chalopai_point'))
  sleep()
  Touch.DisableHero(ChaloPai)
  Touch.SetFunction(ChaloPai, '_cp_fight',
  function(hero, object)
    if ArenaOfHeroesCombat(hero, ChaloPai) then
      RemoveObject(ChaloPai)
      SetGameVar('arena_of_heroes_combat', 'none')
      arena_of_heroes.current_wave = arena_of_heroes.current_wave + 1
      arena_of_heroes.current_wave_period = arena_of_heroes.current_wave_period == arena_of_heroes.wave_period_max and 1 or arena_of_heroes.current_wave_period + 1
      SetGameVar('ah_curr_up', arena_of_heroes.current_wave_period)
    else
      arena_of_heroes.Reset()
    end
  end)
end

function MEgloWave()
  local up = arena_of_heroes.current_wave_period
  DeployReserveHero(MEglo, RegionToPoint('ah_meglo_point'))
  sleep()
  Touch.DisableHero(MEglo)
  Touch.SetFunction(MEglo, '_mg_fight',
  function(hero, object)
    if ArenaOfHeroesCombat(hero, MEglo) then
      RemoveObject(MEglo)
      SetGameVar('arena_of_heroes_combat', 'none')
      arena_of_heroes.current_wave = arena_of_heroes.current_wave + 1
      arena_of_heroes.current_wave_period = arena_of_heroes.current_wave_period == arena_of_heroes.wave_period_max and 1 or arena_of_heroes.current_wave_period + 1
      SetGameVar('ah_curr_up', arena_of_heroes.current_wave_period)
    else
      arena_of_heroes.Reset()
    end
  end)
end

arena_of_heroes =
{
  start_x = 3,
  start_y = 3,
  
  current_hero = nil,
  current_wave = 1, -- текущая волна
  current_wave_period = 1, -- текущее значение счетчика периода волн
  -- current_wave_upgrade = 1, -- текущее усиление волн

  wave_period_max = 4, -- периодичность волн

  waves = {AvoWave, GoblinsWave, ChaloPaiWave, MEgloWave},

  wave_text =
  {
    [1] = {'<color=red>Постарайтесь не сильно обжечься!', '<color=red>Время сгореть... или потухнуть', '<color=red>Заскучали? Время добавить огня!'},
    [2] = {'<color=brown>Мелкие, мерзкие и злобные!', '<color=brown>Тупые, трусливые и кусачие!', '<color=brown>Мыши готовят ловушку для кошки!'},
    [3] = {'<color=blue>Поосторожнее на поворотах!', '<color=blue>Земля содрогается... Устоите ли вы?', '<color=blue>Кто встанет во главе стада?'},
    [4] = {'<color=yellow>Пора испытать эти убийственные штучки!', '<color=yellow>Орудия к бою! Все возможные орудия...', '<color=yellow>Убийственная красота и смертельная точность!'}
  },

  Init =
  function()
    SetGameVar('arena_of_heroes_combat', 'none')
    SetGameVar('ah_curr_up', 1)
    Touch.DisableObject('ah_wave_start')
    Touch.DisableObject('ah_portal', nil, DISABLED_INTERACT)
    Touch.SetFunction('ah_portal', '_ah_portal', MoveToArena)
    Touch.SetFunction('ah_wave_start', '_start_wave', StartWave)
  end,
  
  Reset =
  function()
    SetGameVar('arena_of_heroes_combat', 'none')
    SetGameVar('ah_curr_up', 1)
    MessageBox(rtext('Вы достойно сражались и продержались '..(arena_of_heroes.current_wave - 1)..' волн!'
                     ..' Но испытания на Арене не прекращаются никогда... Новые герои уже готовы принять вызов!'))
    arena_of_heroes.current_wave         = 1
    arena_of_heroes.current_wave_period  = 1
  end
}

function MoveToArena(hero, object)
  if not arena_of_heroes.current_hero then
    SetObjectPosition(hero, arena_of_heroes.start_x, arena_of_heroes.start_y, UNDERGROUND)
    arena_of_heroes.current_hero = hero
  else
    MessageBox(rtext('Доступ закрыт - другой герой проходит испытание на арене!'))
  end
end

function StartWave(hero, object)
  MessageBox(rtext(arena_of_heroes.current_wave..' волна на подходе! '..GetRandFromT(arena_of_heroes.wave_text[arena_of_heroes.current_wave_period])))
  startThread(arena_of_heroes.waves[arena_of_heroes.current_wave_period])
end

function GetWaveUpdgrade()
  local answer = arena_of_heroes.current_wave <= arena_of_heroes.wave_period_max and 1 or (arena_of_heroes.current_wave / arena_of_heroes.wave_period_max + 1)
  return answer
end

startThread(arena_of_heroes.Init)