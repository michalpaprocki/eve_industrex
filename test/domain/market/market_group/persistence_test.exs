defmodule Domain.Market.MarketGroup.PersistenceTest do
  alias EveIndustrex.Market.MarketGroup.Persistence
  alias EveIndustrex.Market.MarketGroup
  use EveIndustrex.DataCase

  @market_group %{
    :market_group_id => 1,
    :description => "test_desc",
    :name => "test",

  }
  @market_groups [
    @market_group,
    %{
    :market_group_id => 2,
    :description => "test_desc",
    :name => "test",
    }
  ]
  test "inserts a single market_group" do
    {:ok, %MarketGroup{} = market_group} = Persistence.upsert(@market_group)
  end
  test "updates a single market_group", context do
    assert {:ok, %MarketGroup{} = market_group} = Persistence.upsert(Map.replace(@market_group, :name, "updated_name"))
    assert market_group.market_group_id == 1
    assert market_group.name == "updated_name"
    assert market_group.description == "test_desc"
  end
  test "inserts multiple market_groups" do
    assert {num_of_inserted, nil} = Persistence.upsert_all(@market_groups)
    assert num_of_inserted == 2
  end

  test "updates multiple market_groups" do
    {_num_of_inserted, nil} = Persistence.upsert_all(@market_groups)
    updated = Enum.map(@market_groups, fn c -> %{c | :name => "updated_name"} end)
    assert {num_of_updated, data} = Persistence.upsert_all(updated, true)
    assert num_of_updated == 2
    assert Enum.map(data, fn d -> d.name == "updated_name" end)
  end
end
