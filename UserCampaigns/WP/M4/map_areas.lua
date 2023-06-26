-- ������ ������� �� �����, � ������� ���� ������������� ���������� �� ������ ��������, � ����� ������� ��� ������ � ����
--
-- ������� �� �����, ������� �� ������ ����������� � ��������� ��������� ��������� - ���������/������������/������� ��������
NON_INTERACT_ACTORS =
{
  ['seraph1']       = 1,
  ['angel1']        = 1,
  ['lc_dragon1']    = 1,
  ['lc_dragon2']    = 1,
  ['lc_dragon3']    = 1,
  ['lc_dragon4']    = 1,
  ['BigLavaDragon'] = 1
}

--------------------------------------------------------------------------------
-- �������
VILLAGES = {}
RUINED_BUILDS = {}

--------------------------------------------------------------------------------
-- ������� ��������� ��������
function InitVillages()
  for i, village in {'village1', 'village2', 'village3', 'village4', 'village5', 'village6'} do
    local actors, a_n = {}, 0
    -- ��������� � ��������� �������� � �������
    for i, actor in GetObjectsInRegion(village, 'CREATURE') do
      a_n = a_n + 1
      actors[a_n] = actor
      Touch.DisableMonster(actor, DISABLED_INTERACT, 0)
      Touch.SetFunction(actor, '_talk', PeasantTalk)
    end
    -- ����� �� ��������� ����������
    AnimGroup[village] = {actors = actors, region = village}
    PlayAnims(village, {'attack00', 'attack01', 'stir00'}, COND_HERO_IN_REGION)
    local huts, h_n = {}, 0
    -- ��������� ������������ ������
    for i, hut in GetObjectsInRegion(village, 'BUILDING_PEASANT_HUT') do
      h_n = h_n + 1
      huts[h_n] = hut
    end
    local mines, m_n = {}, 0
    -- � ����� - ��� ���� ������ ����������� � ������� � ����� ���� ���������
    for i, type in {'SAWMILL', 'ORE_PIT', 'ALCHEMIST_LAB', 'CRYSTAL_CAVERN','GEM_POND', 'SULFUR_DUNE', 'GOLD_MINE'} do
      for j, mine in GetObjectsInRegion(village, 'BUILDING_'..type) do
        print('mine: ', mine)
        m_n = m_n + 1
        mines[m_n] = mine
      end
    end
    VILLAGES[village] = {visited = nil, actors = actors, huts = huts, mines = mines, dead_peasants = 0, ruined_huts = 0, ruined_mines = 0}
    Trigger(REGION_ENTER_WITHOUT_STOP_TRIGGER, village, 'EnterVillage')
  end
end

function PeasantTalk(hero, object)
  local texts =
  {
    {'��������, ��������...', '�����, �������� �������!'},
    {'����� ��� ����� � ��������!', '���� ����������...'},
    {'��, ����� ��...', '������ ��������� ��������!'},
    {'��� ���� �� �����...'},
    {'��� �������� � ������ - ����� ��� ���!!!'},
    {'� ����� ����-����...'}
  }
  local probs = {600, 400, 250, 120, 70, 10}
  local test_prob = random(1000)
  local n = 1
  for i, prob in probs do
    if test_prob < prob then
      n = i
    end
  end
  ShowFlyingSign(rtext(GetRandFromT(texts[n])), object, -1, 7.0)
end

function EnterVillage(hero, region)
  if GetProgress(plague.name) == 3 and
     HasArtefact(hero, ARTIFACT_RING_OF_UNSUMMONING, 1) and
     (not plague.first_purged_village) then
    PlagueTryToPurgeVillage(hero, region)
  end
end