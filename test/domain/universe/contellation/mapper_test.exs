defmodule Domain.Universe.Contellation.MapperTest do
  alias EveIndustrex.Universe.Constellation.Mapper
  use ExUnit.Case

  setup_all do
    mock_esi_constellations = [
      %{
        constellation_id: 1,
        name: "string",
        position: %{
          x: 0,
          y: 0,
          z: 0
        },
        region_id: 1,
        systems: [
          10,
          11,
          12
        ]
      },
      %{
        constellation_id: 2,
        name: "string",
        position: %{
          x: 0,
          y: 0,
          z: 0
        },
        region_id: 1,
        systems: [
          13,
          14,
          15
        ]
      }
    ]

    mock_dump_constellations = [
      %{
        "_key" => 20_000_001,
        "factionID" => 500_007,
        "name" => %{
          "de" => "San Matar",
          "en" => "San Matar",
          "es" => "San Matar",
          "fr" => "San Matar",
          "ja" => "サンマター",
          "ko" => "산마타르",
          "ru" => "San Matar",
          "zh" => "姗玛塔尔"
        },
        "position" => %{
          "x" => -9.404655970099134e16,
          "y" => 4.952015315379885e16,
          "z" => -4.273873181840197e16
        },
        "regionID" => 10_000_001,
        "solarSystemIDs" => [
          30_000_001,
          30_000_002,
          30_000_003,
          30_000_004,
          30_000_005,
          30_000_006,
          30_000_007,
          30_000_008
        ],
        "wormholeClassID" => 7
      },
      %{
        "_key" => 20_000_002,
        "factionID" => 500_007,
        "name" => %{
          "de" => "Anares",
          "en" => "Anares",
          "es" => "Anares",
          "fr" => "Anares",
          "ja" => "アナレス",
          "ko" => "애너리스",
          "ru" => "Anares",
          "zh" => "安纳勒斯"
        },
        "position" => %{
          "x" => -7.918127081731418e16,
          "y" => 5.972176602355514e16,
          "z" => -8.576756362137014e16
        },
        "regionID" => 10_000_001,
        "solarSystemIDs" => [
          30_000_009,
          30_000_010,
          30_000_011,
          30_000_012,
          30_000_013,
          30_000_014,
          30_000_015,
          30_000_016
        ],
        "wormholeClassID" => 7
      }
    ]

    {:ok, %{:dump => mock_dump_constellations, :esi => mock_esi_constellations}}
  end

  test "Converts jsonl entries into unified maps", context do
    dump = context.dump
    maps = Enum.map(dump, fn d -> Mapper.from_dump(d) end)

    assert(
      Enum.each(maps, fn m ->
        Map.has_key?(m, :constellation_id) && Map.has_key?(m, :region_id) &&
          Map.has_key?(m, :description) && Map.has_key?(m, :name)
      end),
      "Every map in the list has constellation_id, :region_id, :description and :name"
    )

    assert(
      Enum.each(maps, fn m -> Map.keys(m) |> Enum.each(fn k -> is_atom(k) end) end),
      "Every key in a map is an atom"
    )
  end

  test "Converts esi response into unified maps", context do
    data = context.esi
    maps = Enum.map(data, fn d -> Mapper.from_esi(d) end)

    assert(
      Enum.each(maps, fn m ->
        Map.has_key?(m, :constellation_id) && Map.has_key?(m, :region_id) &&
          Map.has_key?(m, :description) && Map.has_key?(m, :name)
      end),
      "Every map in the list has constellation_id, :region_id, :description and :name"
    )

    assert(
      Enum.each(maps, fn m -> Map.keys(m) |> Enum.each(fn k -> is_atom(k) end) end),
      "Every key in a map is an atom"
    )
  end
end
