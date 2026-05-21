defmodule Domain.Universe.Category.PersistenceTest do
  use EveIndustrex.DataCase
  alias EveIndustrex.Universe.Category
  alias EveIndustrex.Universe.Category.Persistence

  @category %{
      :category_id => 0,
      :published => true,
      :name => "test_name"
    }
  @categories [
    @category,
    %{
      :category_id => 1,
      :published => false,
      :name => "test_name2"
    }
  ]
  test "inserts a single category" do
    assert {:ok, %Category{} = category} = Persistence.upsert(@category)
    assert category.category_id == 0
    assert category.published == true
    assert category.name == "test_name"
  end
  setup  do
    {:ok, category} = Persistence.upsert(@category)
    {:ok, %{:category => category}}
  end

  test "updates a single category", context do
    assert {:ok, %Category{} = category} = Persistence.upsert(Map.replace(@category, :name, "updated_name"))
    assert category.category_id == 0
    assert category.published == true
    assert category.name == "updated_name"
  end

  test "inserts multiple categories" do
    assert {num_of_inserted, nil} = Persistence.upsert_all(@categories)
    assert num_of_inserted == 2
  end

  test "updates multiple categories" do
    {_num_of_inserted, nil} = Persistence.upsert_all(@categories)
    updated = Enum.map(@categories, fn c -> %{:category_id => c.category_id, :published => !c.published, :name => "updated_name"} end)
    assert {num_of_updated, data} = Persistence.upsert_all(updated, true)
    assert num_of_updated == 2
    assert Enum.map(data, fn d -> d.name == "updated_name" end)
  end
end
