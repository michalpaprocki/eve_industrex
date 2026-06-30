defmodule Domain.Universe.Group.PersistenceTest do
  use EveIndustrex.DataCase
  alias EveIndustrex.Universe.{Category, Group}
  alias EveIndustrex.Universe.Group.Persistence
  @category %{
      :category_id => 0,
      :published => true,
      :name => "category_name"
    }
  @group %{
      :group_id => 0,
      :published => true,
      :category_id => 0,
      :name => "test_name1"
    }
  @groups [
    @group,
    %{
      :group_id => 1,
      :published => false,
      :category_id => 0,
      :name => "test_name2"
    }
  ]
  setup  do
    {:ok, category} = Category.Persistence.upsert(@category)
    {:ok, %{:category => category}}
  end
  test "inserts a single group" do
    assert {:ok, %Group{} = group} = Persistence.upsert(@group)
    group = group |> EveIndustrex.Repo.preload(:category)
    assert group.group_id == 0
    assert group.published == true
    assert group.name == "test_name1"
    assert group.category_id == 0
  end


  test "updates a single group" do
    assert {:ok, %Group{} = group} = Persistence.upsert(Map.replace(@group, :name, "updated_name"))
    assert group.category_id == 0
    assert group.published == true
    assert group.name == "updated_name"
    assert group.group_id == 0
  end

  test "inserts multiple groups" do
    assert {num_of_inserted, nil} = Persistence.upsert_all(@groups)
    assert num_of_inserted == 2
  end

  test "updates multiple categories" do
    {_num_of_inserted, nil} = Persistence.upsert_all(@groups)
    updated = Enum.map(@groups, fn c -> %{:group_id => c.group_id, :published => !c.published, :name => "updated_name", :category_id => c.category_id} end)
    assert {num_of_updated, data} = Persistence.upsert_all(updated, true)
    assert num_of_updated == 2
    assert Enum.map(data, fn d -> d.name == "updated_name" end)
  end
  test "raises foregin key constraint when category doesn't exist" do
     assert_raise(Ecto.ConstraintError, fn -> Persistence.upsert(Map.replace(@group, :category_id, 1337)) end)
  end
end
