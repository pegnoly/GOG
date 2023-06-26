AdvMapHeroesInfo =
{
  heroes_by_owners = {},
  alive_heroes = {},

  InitHeroOwner =
  ---@meta
  function(hero, player)
    print('<color=red>AdvMapHeroesInfo.InitHeroOwner: <color=green>Setting up owner for ', hero)
    AdvMapHeroesInfo.heroes_by_owners[hero] = player
    local owner = player..""
    consoleCmd("@SetGameVar('"..hero.."_owner', "..owner..")")
    startThread(Hero.Threads.StatUpdater, hero) 
  end,

  ChangeHeroOwner =
  ---@meta
  function(hero, player)
    print('<color=red>AdvMap.ChangeHeroOwner: <color=green>', hero, ' changed his owner from ', AdvMapHeroesInfo.heroes_by_owners[hero], ' to ', player)
    AdvMapHeroesInfo.heroes_by_owners[hero] = GetObjectOwner(hero)
    local owner = GetObjectOwner(hero)..""
    consoleCmd("@SetGameVar('"..hero.."_owner', "..owner..")")
  end,


}

AdvMapThreads =
{
  Exception =
  function(thread_info)
    print("<color=red>AdvMapThreads.Exception: <color=green>thread info - ", thread_info)
  end,

  AddHeroesThread =
  function()
    errorHook(
    function()
      AdvMapThreads.Exception("add hero")
    end)
    while not AddHeroEvent and RespawnHeroEvent do
      sleep()
    end
    --
    while 1 do
      for player = PLAYER_1, PLAYER_8 do
        if Player.IsActive(player) then
          for i, hero in GetPlayerHeroes(player) do
            if not AdvMapHeroesInfo.heroes_by_owners[hero] then
              startThread(AdvMapHeroesInfo.InitHeroOwner, hero, player)
            else
              if AdvMapHeroesInfo.heroes_by_owners[hero] ~= player then
                startThread(AdvMapHeroesInfo.ChangeHeroOwner, hero, player)
              end
            end
            if not AdvMapHeroesInfo.alive_heroes[hero] then
              AdvMapHeroesInfo.alive_heroes[hero] = 1
              SetHeroCombatScript(hero, '/CheckScript.xdb#xpointer(/Script)')
              -- if not mccs_custom_ability.art_custom_affected_heroes[hero] then
                -- mccs_custom_ability.art_custom_affected_heroes[hero] = {}
                -- mccs_custom_ability.hero_custom_affected_heroes[hero] = {}
                startThread(Hero.Threads.LevelUp, hero)
                startThread(Hero.Threads.XpTracker, hero)
                startThread(AddHeroEvent.Invoke, hero)
              -- else
                -- startThread(RespawnHeroEvent.Invoke, hero)
              -- end
            end
          end
        end
      end
      sleep()
    end
  end,

  RemoveHeroesThread =
  function()
    errorHook(
    function()
      AdvMapThreads.Exception("remove hero")
    end)
    while not RemoveHeroEvent do
      sleep()
    end
    --
    while 1 do
      for hero, alive in AdvMapHeroesInfo.alive_heroes do
        if alive and (not IsHeroAlive(hero)) then
          AdvMapHeroesInfo.alive_heroes[hero] = nil
          startThread(RemoveHeroEvent.Invoke, hero)
          --
        end
      end
      sleep()
    end
  end,

  NewDayThread =
  function()
    errorHook(
    function()
      AdvMapThreads.Exception("new day")
    end)
    while not NewDayEvent do
      sleep()
    end
    --
    local day = -1
    while 1 do
      --
      while GetDate(DAY) == day do
        sleep()
      end
      --
      day = GetDate(DAY)
      startThread(NewDayEvent.Invoke)
      --
      sleep()
    end
  end,

  CombatResultsThread =
  function()
    errorHook(
    function()
      AdvMapThreads.Exception("combat results")
    end)
    while not CombatResultsEvent do
      sleep()
    end
    --
    local fight_id = GetLastSavedCombatIndex()
    while 1 do
      --
      while GetLastSavedCombatIndex() == fight_id do
        sleep()
      end
      --
      fight_id = GetLastSavedCombatIndex()
      startThread(CombatResultsEvent.Invoke, fight_id)
      --
      sleep()
    end
  end
}