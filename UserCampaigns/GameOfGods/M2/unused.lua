--  local num = 0
--  local cr_tbls = {}
--  local prize = 0
--  -- ���� 1 ������
--  if object == 'mk_shrine_01' then
--    local rune = random(4) + 1
--    -- ��������
--    if rune == 1 then
--      num = 4
--      cr_tbls =
--      {
--        {{CREATURE_CERBERI, CREATURE_FIREBREATHER_HOUND, CREATURE_HELL_RAGE}, 262},
--        {{CREATURE_BLOOD_WITCH, CREATURE_BLOOD_WITCH_2, CREATURE_BLOOD_WITCH_NCF367}, 255},
--        {{CREATURE_MASTER_GENIE, CREATURE_DJINN_VIZIER, CREATURE_GENIE_NCF342}, 53},
--        {{CREATURE_DWARF_RIDER, CREATURE_BATTLE_RIDER, CREATURE_NIGHT_GOBLIN}, 62},
--      }
--      prize = 249
--    -- ������� ����(����)
--    elseif rune == 2 then
--      num = 4
--      cr_tbls =
--      {
--        {{CREATURE_VINDICATOR}, 894},
--        {{CREATURE_ORCCHIEF_EXECUTIONER_N, CREATURE_ORCCHIEF_CHIEFTAIN_N}, 257},
--        {{CREATURE_GRAND_ELF}, 602},
--        {{CREATURE_MINOTAUR_KING}, 782}
--      }
--      prize = 250
--    -- ������
--    elseif rune == 3 then
--      num = 4
--      cr_tbls =
--      {
--        {{CREATURE_WHITE_UNICORN}, 277},
--        {{CREATURE_ELRATH_ANGEL}, 55},
--        {{CREATURE_IMP, CREATURE_QUASIT}, 2222},
--        {{CREATURE_WRAITH}, 162}
--      }
--      prize = 251
--    -- ���������
--    else
--      num = 3
--      cr_tbls =
--      {
--        {{CREATURE_PALADIN}, 104},
--        {{CREATURE_ARCH_MAGI}, 302},
--        {{CREATURE_ZEALOT, CREATURE_CHAPLAIN}, 252}
--      }
--    end
--    prize = 252
--  -- ���� 3-4 ���(����� ��������)
--  elseif object == 'mk_shrine_02' then
--    local rune = random(3) + 1
--    -- �����������������
--    if rune == 1 then
--      num = 4
--      cr_tbls =
--      {
--        {{CREATURE_FIRE_ELEMENTAL}, 234},
--        {{CREATURE_EARTH_ELEMENTAL}, 402},
--        {{CREATURE_WATER_ELEMENTAL}, 314},
--        {{CREATURE_AIR_ELEMENTAL}, 341},
--      }
--      prize = 253
--    -- �������������
--    elseif rune == 2 then
--      num = 6
--      cr_tbls =
--      {
--        {{CREATURE_GHOST, CREATURE_POLTERGEIST, CREATURE_MANES_NCF363}, 431},
--        {{CREATURE_GHOST, CREATURE_POLTERGEIST, CREATURE_MANES_NCF363}, 501},
--        {{CREATURE_GHOST, CREATURE_POLTERGEIST, CREATURE_MANES_NCF363}, 316},
--        {{CREATURE_GHOST, CREATURE_POLTERGEIST, CREATURE_MANES_NCF363}, 405},
--        {{CREATURE_GHOST, CREATURE_POLTERGEIST, CREATURE_MANES_NCF363}, 492},
--        {{CREATURE_GHOST, CREATURE_POLTERGEIST, CREATURE_MANES_NCF363}, 376},
--      }
--      prize = 256
--    -- ���������
--    else
--      num = 4
--      cr_tbls =
--      {
--        {{CREATURE_MILITIAMAN, CREATURE_SKELETON_WARRIOR}, 3564},
--        {{CREATURE_CYCLOP_UNTAMED_N}, 60},
--        {{CREATURE_BATTLE_RAGER, CREATURE_BLACKBEAR_RIDER}, 575},
--        {{CREATURE_SHARP_SHOOTER}, 549},
--      }
--      prize = 254
--    end
--  else
--    local rune = random(3) + 1
--    -- �����������
--    if rune == 1 then
--      num = 4
--      cr_tbls =
--      {
--        {{CREATURE_ARCHANGEL}, 72},
--        {{CREATURE_LICH_MASTER}, 268},
--        {{CREATURE_DRYAD}, 2548},
--        {{CREATURE_OBSIDIAN_GOLEM}, 679}
--      }
--      prize = 257
--    -- ������ ������
--    elseif rune == 2 then
--      num = 4
--      cr_tbls =
--      {
--        {{CREATURE_WARLORD, CREATURE_THUNDER_THANE, CREATURE_STONE_LORD}, 103},
--        {{CREATURE_CHAOS_HYDRA, CREATURE_ACIDIC_HYDRA, CREATURE_HELL_HYDRA}, 213},
--        {{CREATURE_WAR_DANCER, CREATURE_NIGHT_DANCER}, 1011},
--        {{CREATURE_RAKSHASA_KSHATRI}, 122}
--      }
--      prize = 255
--    -- ����. �������
--    else
--      num = 5
--      cr_tbls =
--      {
--        {{CREATURE_BLACK_DRAGON, CREATURE_RED_DRAGON, CREATURE_ACIDIC_DRAGON}, 31},
--        {{CREATURE_MAGMA_DRAGON, CREATURE_LAVA_DRAGON, CREATURE_FIERY_DRAGON}, 28},
--        {{CREATURE_SHADOW_DRAGON, CREATURE_HORROR_DRAGON, CREATURE_BLOOD_DRAGON}, 42},
--        {{CREATURE_GOLD_DRAGON, CREATURE_RAINBOW_DRAGON, CREATURE_STONE_DRAGON}, 34},
--        {{CREATURE_WYVERN_POISONOUS, CREATURE_WYVERN_PAOKAI}, 77}
--      }
--      prize = 258
--    end
--  end
--  -- ��������� ���������� ���
--  local params = {hero, nil, num}
--  local limit = 3 + num * 2
--  params[limit + 1] = nil -- ������
--  params[limit + 2] = nil -- �����
--  params[limit + 3] = nil -- ������
--  params[limit + 4] = nil -- ������� ���
--  for i = 1, num do
--    local cr = GetRandFromT_E(nil, cr_tbls[i][1])
--    local pos = 3 + (((i - 1) * 2) + 1)
--    params[pos] = cr
--    params[pos + 1] = cr_tbls[i][2]
--  end
--  if StartCombat(params[1], params[2], params[3], params[4], params[5], params[6],
--                 params[7], params[8], params[9], params[10], params[11], params[12],
--                 params[13], params[14], params[15], params[16], params[17], params[18]) then