angel_quest =
{
	eradication = "ERADICATION",
	destroy_temple = "DESTROY_TEMPLE",

	path = q_path.."AngelQuest/",

	allenora_arrive_date = -1, -- setup day in main quest after first stage completion
	allenora_dialog_stage = 1,

	Init =
	function()
	end,

	AllenoraArrive =
	function(day)
		if day == allenora_arrive_date then
			DeployReserveHero("Allenora", RegionToPoint("allenora_arrive_point")) -- create region + reserve Allenora
			while not IsObjectExists("Allenora") do
				sleep()
			end
			ShowObject("Allenora", 1, 1)
			sleep(20)
			MoveHeroRealTime("Allenora", RegionToPoint("allenora_raintemple_dest")) -- create region
			StartDialogScene(DIALOG_SCENES.ALLENORA_ARRIVE)
			StartQuest(angel_quest.eradication, "Karlam")
		end
	end,

	AllenoraTalk =
	function(hero, object)
		
	end,
}