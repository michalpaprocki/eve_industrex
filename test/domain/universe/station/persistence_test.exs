defmodule Domain.Universe.Station.PersistenceTest do
  alias EveIndustrex.Universe.Station
  alias EveIndustrex.Universe.Station.Persistence
  use EveIndustrex.DataCase

   @region %{
    :region_id => 0,
    :name => "test region",
    :description => "test desc"
  }
  @constellation %{
    :region_id => 0,
    :name => "test constellation",
    :constellation_id => 1

  }
  @system %{
      :system_id => 0,
      :name => "Test name 1",
      :constellation_id => 1,
      :security_status => 0.5
  }
  @station %{
    :station_id => 1,
    :system_id => 0,
    :name => "test_name1",
    :reprocessing_stations_take => 0.5,
    :reprocessing_efficiency => 0.1,
    :services => ["bounty_missions"]
  }
  @stations [
    @station,
    %{
      :station_id => 2,
      :system_id => 0,
      :name => "test_name2",
      :reprocessing_stations_take => 0.6,
      :reprocessing_efficiency => 0.2,
      :services => ["bounty_missions"]
    }
  ]
  setup  do
    {:ok, _} = EveIndustrex.Universe.Region.Persistence.upsert(@region)
    {:ok, _} = EveIndustrex.Universe.Constellation.Persistence.upsert(@constellation)
    {:ok, _} = EveIndustrex.Universe.System.Persistence.upsert(@system)
    {:ok, %{}}
  end
  test "inserts a single station" do
    assert {:ok, %Station{} = station} = Persistence.upsert(@station)
    assert station.system_id == 0
    assert station.name == "test_name1"
    assert station.system_id == 0
    assert station.services == ["bounty_missions"]
    assert station.reprocessing_stations_take == 0.5
    assert station.reprocessing_efficiency == 0.1
  end


  test "updates a single station", context do
    assert {:ok, %Station{} = system} = Persistence.upsert(Map.replace(@station, :name, "updated_name"))
    assert system.station_id == 1
    assert system.name == "updated_name"
  end

  test "inserts multiple stations" do
    assert {num_of_inserted, nil} = Persistence.upsert_all(@stations)
    assert num_of_inserted == 2
  end

  test "updates multiple stations" do
    {_num_of_inserted, nil} = Persistence.upsert_all(@stations)
    updated = Enum.map(@stations, fn c -> %{c | :system_id => c.system_id, :services => c.services, :name => "updated_name", :reprocessing_stations_take => c.reprocessing_stations_take, :reprocessing_efficiency => c.reprocessing_efficiency } end)
    assert {num_of_updated, data} = Persistence.upsert_all(updated, true)
    assert num_of_updated == 2
    assert Enum.map(data, fn d -> d.name == "updated_name" end)
  end
end
