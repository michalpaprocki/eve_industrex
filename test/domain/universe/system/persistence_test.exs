defmodule Domain.Universe.System.PersistenceTest do
  alias EveIndustrex.Universe.System
  alias EveIndustrex.Universe.System.Persistence
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
  @systems [
    @system,
    %{
      :system_id => 1,
      :name => "Test name 2",
      :constellation_id => 1,
         :security_status => 0.6
    }
  ]
  setup  do
    {:ok, _} = EveIndustrex.Universe.Region.Persistence.upsert(@region)
    {:ok, _} = EveIndustrex.Universe.Constellation.Persistence.upsert(@constellation)
    {:ok, %{}}
  end
  test "inserts a single system" do
    assert {:ok, %System{} = system} = Persistence.upsert(@system)
    assert system.system_id == 0
    assert system.name == "Test name 1"
    assert system.security_status == 0.5
  end


  test "updates a single system" do
    assert {:ok, %System{} = system} = Persistence.upsert(Map.replace(@system, :name, "updated_name"))
    assert system.system_id == 0
    assert system.name == "updated_name"
    assert system.security_status == 0.5
  end

  test "inserts multiple systems" do
    assert {num_of_inserted, nil} = Persistence.upsert_all(@systems)
    assert num_of_inserted == 2
  end

  test "updates multiple systems" do
    {_num_of_inserted, nil} = Persistence.upsert_all(@systems)
    updated = Enum.map(@systems, fn c -> %{:system_id => c.system_id, :constellation_id => c.constellation_id, :name => "updated_name", :security_status => c.security_status} end)
    assert {num_of_updated, data} = Persistence.upsert_all(updated, true)
    assert num_of_updated == 2
    assert Enum.map(data, fn d -> d.name == "updated_name" end)
  end

end
