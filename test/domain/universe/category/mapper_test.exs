defmodule Domain.Universe.Category.MapperTest do
  use ExUnit.Case
  alias EveIndustrex.Universe.Category.Mapper


  setup_all  do
    mock_esi_categories = [
      %{
        category_id: 2,
        groups: [
          3,
          4,
          5,
          6,
          7,
          8,
          9,
          10,
          11,
          12,
          13,
          14,
          186,
          226,
          227,
          305,
          307,
          310,
          312,
          318,
          336,
          340,
          366,
          368,
          382,
          411,
          448,
          502,
          517,
          649,
          711,
          835,
          836,
          874,
          885,
          897,
          920,
          988,
          995,
          1071,
          1165,
          1198,
          1316,
          1704,
          1882,
          1915,
          1940,
          1971,
          1973,
          1975,
          1978,
          1980,
          1981,
          1983,
          1991,
          1998,
          2020,
          4033,
          4055,
          4070,
          4079,
          4081,
          4100,
          4168,
          4430,
          4547,
          4548,
          4549,
          4579,
          4713,
          4719,
          4745,
          4825,
          4828,
          4918,
          4930,
          4935,
          4936,
          4937,
          4938
        ],
        name: "Celestial",
        published: true
      },
      %{
        category_id: 3,
        groups: [
          15,
          16
        ],
        name: "Station",
        published: false
      }

]
    mock_dump_categories = [
  %{
    "_key" => 2,
    "name" => %{
      "de" => "Interstellar",
      "en" => "Celestial",
      "es" => "Celestial",
      "fr" => "Céleste",
      "ja" => "セレスチャル",
      "ko" => "천체",
      "ru" => "Небесное тело",
      "zh" => "天体"
    },
    "published" => true
  },
  %{
    "_key" => 3,
    "name" => %{
      "de" => "Station",
      "en" => "Station",
      "es" => "Estación",
      "fr" => "Station",
      "ja" => "ステーション",
      "ko" => "정거장",
      "ru" => "Станция",
      "zh" => "空间站"
    },
    "published" => false
  }
]
{:ok, %{:dump => mock_dump_categories, :esi => mock_esi_categories}}
  end
  test "Converts jsonl entries into unified maps", context do
    jsonl = context.dump
    maps = Enum.map(jsonl, fn j -> Mapper.from_dump(j) end)
    assert(Enum.each(maps, fn m -> Map.has_key?(m, :category_id) && Map.has_key?(m, :name) && Map.has_key?(m ,:published) end), "Every map in the list has :category_id, :name and :published keys")
    assert(Enum.each(maps, fn m -> Map.keys(m) |> Enum.each(fn k -> is_atom(k) end) end), "Every key in a map is an atom")
  end
  test "Converts esi response into unified maps", context do
    data = context.esi
    maps = Enum.map(data, fn d -> Mapper.from_esi(d) end)
    assert(Enum.each(maps, fn m -> Map.has_key?(m, :category_id) && Map.has_key?(m, :name) && Map.has_key?(m ,:published) end), "Every map in the list has :category_id, :name and :published keys")
    assert(Enum.each(maps, fn m -> Map.keys(m) |> Enum.each(fn k -> is_atom(k) end) end), "Every key in a map is an atom")
  end
end
