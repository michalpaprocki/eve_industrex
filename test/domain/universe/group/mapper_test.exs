defmodule Domain.Universe.Group.MapperTest do
  use ExUnit.Case
  alias EveIndustrex.Universe.Group.Mapper
  setup_all do
    mock_esi_groups = [
      %{
        category_id: 1,
        group_id: 2,
        name: "Corporation",
        published: false,
        types: [
          2
        ]
      },
      %{
        category_id: 2,
        group_id: 4,
        name: "Constellation",
        published: false,
        types: [
          4
        ]
      }
    ]
    mock_dump_groups = [
      %{
        "_key" => 1,
        "anchorable" => false,
        "anchored" => false,
        "categoryID" => 1,
        "fittableNonSingleton" => false,
        "name" => %{
          "de" => "Charakter",
          "en" => "Character",
          "es" => "Personame",
          "fr" => "Personnage",
          "ja" => "キャラクター",
          "ko" => "캐릭터",
          "ru" => "Персонаж",
          "zh" => "人物角色"
        },
        "published" => false,
        "useBasePrice" => false
      },
      %{
        "_key" => 4,
        "anchorable" => false,
        "anchored" => false,
        "categoryID" => 2,
        "fittableNonSingleton" => false,
        "name" => %{
          "de" => "Konstellation",
          "en" => "Constellation",
          "es" => "Constelación",
          "fr" => "Constellation",
          "ja" => "コンステレーション",
          "ko" => "성좌",
          "ru" => "Созвездие",
          "zh" => "星座"
        },
        "published" => false,
        "useBasePrice" => false
      }
    ]
    {:ok, %{:dump => mock_dump_groups, :esi => mock_esi_groups}}
  end

  test "Converts jsonl entries into unified maps", context do
    jsonl = context.dump
    maps = Enum.map(jsonl, fn j -> Mapper.from_dump(j) end)
    assert(Enum.each(maps, fn j -> Map.has_key?(j, :category_id) && Map.has_key?(j, :group_id) && Map.has_key?(j, :name) && Map.has_key?(j ,:published) end), "Every map in the list has :category_id, :group_id, :name and :published keys")
    assert(Enum.each(maps, fn m -> Map.keys(m) |> Enum.each(fn k -> is_atom(k) end) end), "Every key in a map is an atom")
  end
  test "Converts esi response into unified maps", context do
    data = context.esi
    maps = Enum.map(data, fn d -> Mapper.from_esi(d) end)
    assert(Enum.each(maps, fn m -> Map.has_key?(m, :group_id) && Map.has_key?(m, :category_id) && Map.has_key?(m, :name) && Map.has_key?(m ,:published) end), "Every map in the list has :category_id, :group_id, :name and :published keys")
    assert(Enum.each(maps, fn m -> Map.keys(m) |> Enum.each(fn k -> is_atom(k) end) end), "Every key in a map is an atom")
  end
end
