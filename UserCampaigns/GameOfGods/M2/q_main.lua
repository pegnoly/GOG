-----------
-- Базовый квест, связывающий все остальныею

-- диалоги для данного квеста
m_dialog_sets["mq_st_d"] = {['1'] = 'Karlam',['2'] = 'Noellie',['3'] = 'Karlam',}
m_dialog_sets["mq_aft_st_d"] = {['1'] = 'Karlam',['2'] = 'Noellie',['3'] = 'Karlam',['4'] = 'Noellie',}

MainQ = 
{
	name = "MAIN_QUEST",
	path = q_path.."Prim/Main/",
	dialog_path = q_path.."Prim/Main/Dialogs/",

	Init =
	function()
	end,
	--
	StartFight =
	function()
		StartMiniDialog(MainQ.dialog_path.."StartDialog/", 1, 3, m_dialog_sets["mq_st_d"])
		if MCCS_StartCombat("Karlam", nil, 4, CREATURE_TOUR_RIDER, 38 + random(7),
										GetRandFrom(CREATURE_TOUR_CHAMPION, CREATURE_TOUR_EQUESTRIAN), 25 + random(4),
										CREATURE_SHOOTER, 102 + random(15),
										GetRandFrom(CREATURE_HUNTER, CREATURE_GRENADIER), 79 + random(10)) then
			-- сохранить оставшуюся армию Карлама
			local karlam_saved_army = {}
			for slot = 0, 6 do
				local creature, count = GetObjectArmySlotCreature("Karlam", slot)
				if not (creature == 0 and count == 0) then
					if not karlam_saved_army[creature] then
						karlam_saved_army[creature] = 0
					end
					karlam_saved_army[creature] += count
				end
			end
			-- передать Ноэлли
			for creature, count in karlam_saved_army do
				AddHeroCreatures("Noellie", creature, count)
			end
			--
			if MCCS_StartCombat("Noellie", nil, 6, GetRandFrom(CREATURE_CHTONIC, CREATURE_INFERNAL_TROGLODYTE), 145 + random(30),
												GetRandFrom(CREATURE_DWARWEN_GOLEM, CREATURE_TITAN_GENERATOR), 4 + random(2),
												GetRandFrom(CREATURE_HUNTER, CREATURE_GRENADIER), 103 + random(9),
												GetRandFrom(CREATURE_HUNTER, CREATURE_GRENADIER), 109 + random(11),
												CREATURE_PIKEMAN, 178,
												GetRandFrom(CREATURE_DWARF_ADEPT, CREATURE_WARLOCK), 18 + random(3)) then
				for creature, count in karlam_saved_army do
					if GetHeroCreatures("Noellie", creature) > 0 then
						RemoveHeroCreatures("Noellie", creature, 999)
						RemoveHeroCreatures("Karlam", creature, count - GetHeroCreatures("Noellie", creature))
					end
				end
			end
			StartMiniDialog(MainQ.dialog_path.."AfterStartFightDialog/", 1, 4, m_dialog_sets["mq_aft_st_d"])
		end
		StartQuest(MainQ.name, "Karlam")
	end,
	--
	
}
