defmodule Domain.Universe.Contellation.PersistenceTest do
  alias EveIndustrex.Universe.Constellation
  alias EveIndustrex.Universe.Constellation.Persistence
  use EveIndustrex.DataCase

  @region %{
    :region_id => 0,
    :name => "test region",
    :description => "test desc"
  }
   @constellation %{
      :region_id => 0,
      :name => "Test name 1",
      :constellation_id => 1

    }
  @constellations [
    @constellation,
    %{
      :region_id => 0,
      :name => "Test name2",
      :constellation_id => 2
    }
  ]

  setup do
    {:ok, region} = EveIndustrex.Universe.Region.Persistence.upsert(@region)
    {:ok, %{:region => region}}
  end
  test "inserts a single constellation" do
    assert {:ok, %Constellation{} = constellation} = Persistence.upsert(@constellation)
    assert constellation.constellation_id == 1
    assert constellation.name == "Test name 1"
  end


  test "updates a single constellation" do
    assert {:ok, %Constellation{} = constellation} = Persistence.upsert(Map.replace(@constellation, :name, "updated_name"))
    assert constellation.constellation_id == 1
    assert constellation.name == "updated_name"

  end

  test "inserts multiple constellations" do
    assert {num_of_inserted, nil} = Persistence.upsert_all(@constellations)
    assert num_of_inserted == 2
  end

  test "updates multiple constellations" do
    {_num_of_inserted, nil} = Persistence.upsert_all(@constellations)
    updated = Enum.map(@constellations, fn c -> %{c | :region_id => c.region_id, :name => "updated_name"} end)
    assert {num_of_updated, data} = Persistence.upsert_all(updated, true)
    assert num_of_updated == 2
    assert Enum.map(data, fn d -> d.name == "updated_name" end)
  end
end
