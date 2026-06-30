defmodule Domain.Universe.Type.PersistenceTest do
alias EveIndustrex.Universe.Type.Persistence
alias EveIndustrex.Universe.Type
use EveIndustrex.DataCase
@category %{
    :category_id => 0,
    :published => true,
    :name => "category_name"
  }
@market_group %{
  :market_group_id => 1,
  :description => "test_desc",
  :name => "test",

}
@group %{
  :group_id => 1,
  :published => true,
  :category_id => 0,
  :name => "test_name1"
}
@single_type %{
  :capacity => 30.0,
  :description => "test_desc",
  :icon_id => 1,
  :mass => 20.0,
  :name => "test_name",
  :packaged_volume => 10.0,
  :portion_size => 1,
  :published => true,
  :radius => 50.0,
  :type_id => 1,
  :volume => 10000.0,
  :group_id => 1,
  :market_group_id => 1
}

@types [
  @single_type,
  %{
  :capacity => 30.0,
  :description => "test_desc",
  :icon_id => 1,
  :mass => 20.0,
  :name => "test_name",
  :packaged_volume => 10.0,
  :portion_size => 1,
  :published => true,
  :radius => 50.0,
  :type_id => 2,
  :volume => 10000.0,
  :group_id => 1,
  :market_group_id => 1
}
]
  setup do
    {:ok, _} = EveIndustrex.Universe.Category.Persistence.upsert(@category)
    {:ok, _} = EveIndustrex.Universe.Group.Persistence.upsert(@group)
    {:ok, _} = EveIndustrex.Universe.MarketGroup.Persistence.upsert(@market_group)
    {:ok, %{}}
  end
  test "inserts a single type" do
    {:ok, %Type{} = _type} = Persistence.upsert(@single_type)
  end
  test "updates a single type" do
    assert {:ok, %Type{} = type} = Persistence.upsert(Map.replace(@single_type, :name, "updated_name"))
    assert type.type_id == 1
    assert type.name == "updated_name"
    assert type.mass == 20.0
  end
  test "inserts multiple types" do
    assert {num_of_inserted, nil} = Persistence.upsert_all(@types)
    assert num_of_inserted == 2
  end

  test "updates multiple types" do
    {_num_of_inserted, nil} = Persistence.upsert_all(@types)
    updated = Enum.map(@types, fn c -> %{c | :name => "updated_name"} end)
    assert {num_of_updated, data} = Persistence.upsert_all(updated, true)
    assert num_of_updated == 2
    assert Enum.map(data, fn d -> d.name == "updated_name" end)
  end
end
