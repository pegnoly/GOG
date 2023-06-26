consoleCmd('console_size 10000')
doFile('/scripts/3rdparty/lualib.lua')
doFile("/scripts/common/global/consts.lua")
doFile("/scripts/common/adv_map/consts.lua")
doFile("/scripts/common/random.lua")
sleep()
doFile("/scripts/entity/creature/abils.lua")
doFile("/scripts/entity/creature/consts.lua")
doFile("/scripts/entity/artifact/consts.lua")
doFile("/scripts/entity/hero/consts.lua")
doFile("/scripts/entity/spell/consts.lua")
sleep()
while not HERO_SPEC_NONE and TOWN_NO_TYPE do
	sleep()
end
doFile('/scripts/lib/creatures_table.lua')
doFile('/scripts/lib/heroes_info.lua')
doFile('/scripts/lib/spells_info.lua')
doFile("/scripts/lib/arts_info.lua")
sleep()
doFile('/scripts/common/adv_map/override.lua')
doFile('/scripts/common/adv_map/load.lua')
doFile('/scripts/event/map_common/events.lua')
while not MapLoadingEvent do 
	sleep()
end

doFile("/scripts/global_load.lua")
sleep()

MCCS_FIRST_ACTIVE_PLAYER = -1

for player = PLAYER_1, PLAYER_8 do
  if GetPlayerState(player) == PLAYER_ACTIVE then
    MCCS_FIRST_ACTIVE_PLAYER = player
    break
  end
end

Trigger(OBJECTIVE_STATE_CHANGE_TRIGGER, 'HIDDEN', MCCS_FIRST_ACTIVE_PLAYER, 'CommonStart')

--for player = PLAYER_1, PLAYER_8 do
--  if IsActivePlayer(player) and (IsAIPlayer(player) == 0) then
--    Trigger(OBJECTIVE_STATE_CHANGE_TRIGGER, 'UP_ARTS_DISTRIBUTION', player, 'UpArtsAdd')
--  end
--end

--doFile('/scripts/NAF/global_load.lua')
doFile('/scripts/event/map_common/post_combat_fix.lua')
--doFile('/scripts/NHF_global_load.lua')

function CommonStart()
	doFile('/scripts/entity/object.lua')
	doFile('/scripts/entity/resource.lua')
	doFile("/scripts/entity/load.lua")
	sleep()
	doFile('/scripts/quest/quest.lua')
	doFile('/scripts/dialog/dialog.lua')
	doFile('/scripts/dialog/mini_dialog.lua')
	doFile('/scripts/event/touch/touch.lua')
	sleep()
	doFile("/scripts/local_load.lua")
	sleep()
	startThread(CommonMapLoadingThread)
	print("<color=blue>MCCS SCRIPTS SUCCESSFULLY LOADED")
end

function CommonMapLoadingThread()
  --
  NewDayEvent.AddListener('MCCS_ai_gold_fix_event',
  function(day)
    for player = PLAYER_1, PLAYER_8 do
      if GetPlayerState(player) == PLAYER_ACTIVE and (IsAIPlayer(player) == 1) then
        SetPlayerResource(player, GOLD, 100000000)
        print("Gold fix applied to player ", player)
      end
    end
  end)
  --
  MapLoadingEvent.Invoke()
  --
  sleep(10)
  --
  startThread(AdvMapThreads.AddHeroesThread)
  startThread(AdvMapThreads.RemoveHeroesThread)
  startThread(AdvMapThreads.CombatResultsThread)
  startThread(AdvMapThreads.NewDayThread)
  startThread(PostCombatFixInit)
  --
  -- startThread(CustomAbility.EnableArtifactAbility)
  -- startThread(CustomAbility.EnableHeroAbility)
  CombatConnection.CreateCombatFunctionsList(CombatConnection.combat_scripts_paths)
  --
end

--function UpArtsAdd(player)
--  if MCCS_DEFAULT_SETTINGS.use_up_arts == 1 then
--    if GetCurrentPlayer() ~= -1 then
--      while not (GetCurrentPlayer() == player) do
--        sleep()
--      end
--    end
--    while length(GetPlayerHeroes(player)) == 0 do
--      sleep()
--    end
--    Dialog.NewDialog(art_choise_dialog, GetPlayerHeroes(player)[0], player)
--  end
--end

SetObjectiveState('HIDDEN', OBJECTIVE_ACTIVE, MCCS_FIRST_ACTIVE_PLAYER)

--for player = PLAYER_1, PLAYER_8 do
--  if IsActivePlayer(player) and (IsAIPlayer(player) == 0) then
--    StartQuest('UP_ARTS_DISTRIBUTION', nil, player)
--  end
--end