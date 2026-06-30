defmodule Domain.Universe.Region.PersistenceTest do
  alias EveIndustrex.Universe.Region
  alias EveIndustrex.Universe.Region.Persistence
  use EveIndustrex.DataCase

  @region %{
      :region_id => 0,
      :description => "Test description1",
      :name => "Test name 1"
    }
  @regions [
    @region,
    %{
      :region_id => 1,
      :description => "Test description1",
      :name => "Test name2"
    }
  ]
  test "inserts a single region" do
    assert {:ok, %Region{} = region} = Persistence.upsert(@region)
    assert region.region_id == 0
    assert region.description == "Test description1"
    assert region.name == "Test name 1"
  end


  test "updates a single region" do
    assert {:ok, %Region{} = region} = Persistence.upsert(Map.replace(@region, :name, "updated_name"))
    assert region.region_id == 0
    assert region.description == "Test description1"
    assert region.name == "updated_name"

  end

  test "inserts multiple regions" do
    assert {num_of_inserted, nil} = Persistence.upsert_all(@regions)
    assert num_of_inserted == 2
  end

  test "updates multiple regions" do
    {_num_of_inserted, nil} = Persistence.upsert_all(@regions)
    updated = Enum.map(@regions, fn c -> %{:region_id => c.region_id, :description => "updated_description", :name => "updated_name"} end)
    assert {num_of_updated, data} = Persistence.upsert_all(updated, true)
    assert num_of_updated == 2
    assert Enum.map(data, fn d -> d.name == "updated_name" end)
  end
end
