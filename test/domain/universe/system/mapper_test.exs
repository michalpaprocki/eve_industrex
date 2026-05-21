defmodule Domain.Universe.System.MapperTest do
  alias EveIndustrex.Universe.System.Mapper
  use ExUnit.Case

  setup_all  do
    mock_esi_systems = [
    %{
      constellation_id: 0,
      name: "string",
      planets: [
        %{
          asteroid_belts: [
            0
          ],
          moons: [
            0
          ],
          planet_id: 0
        }
      ],
      position: %{
        x: 0,
        y: 0,
        z: 0
      },
      security_class: "string",
      security_status: 0,
      star_id: 0,
      stargates: [
        0
      ],
      stations: [
        0
      ],
      system_id: 0
    },
    %{
      constellation_id: 0,
      name: "string",
      planets: [
        %{
          asteroid_belts: [
            0
          ],
          moons: [
            0
          ],
          planet_id: 0
        }
      ],
      position: %{
        x: 0,
        y: 0,
        z: 0
      },
      security_class: "string",
      security_status: 0,
      star_id: 0,
      stargates: [
        0
      ],
      stations: [
        0
      ],
      system_id: 0
    }

    ]
    mock_dump_systems = [
      %{
        "_key" => 30000001,
        "border" => true,
        "constellationID" => 20000001,
        "hub" => true,
        "international" => true,
        "luminosity" => 0.01575,
        "name" => %{
          "de" => "Tanoo",
          "en" => "Tanoo",
          "es" => "Tanoo",
          "fr" => "Tanoo",
          "ja" => "タヌー",
          "ko" => "타누",
          "ru" => "Tanoo",
          "zh" => "坦欧"
        },
        "planetIDs" => [40000002, 40000005, 40000007, 40000008, 40000011, 40000017],
        "position" => %{
          "x" => -8.851079259998058e16,
          "y" => 4.236944396687888e16,
          "z" => -4.451352534647966e16
        },
        "position2D" => %{"x" => 6.985182150795389e16, "y" => -7.190628684642312e16},
        "radius" => 1323338301440.0,
        "regionID" => 10000001,
        "regional" => true,
        "securityClass" => "B",
        "securityStatus" => 0.858324,
        "starID" => 40000001,
        "stargateIDs" => [50000056, 50000057, 50000058]
      },
      %{
        "_key" => 30000002,
        "border" => true,
        "constellationID" => 20000001,
        "corridor" => true,
        "international" => true,
        "luminosity" => 0.01282,
        "name" => %{
          "de" => "Lashesih",
          "en" => "Lashesih",
          "es" => "Lashesih",
          "fr" => "Lashesih",
          "ja" => "ラシェシ",
          "ko" => "라셰시",
          "ru" => "Lashesih",
          "zh" => "拉什希亚"
        },
        "planetIDs" => [40000020, 40000022, 40000024, 40000028, 40000031, 40000033,
        40000037],
        "position" => %{
          "x" => -1.0330096826312646e17,
          "y" => 4.1707503568269944e16,
          "z" => -2.985630412979509e16
        },
        "position2D" => %{"x" => 6.779735616948466e16, "y" => -6.574289083101542e16},
        "radius" => 1018400014336.0,
        "regionID" => 10000001,
        "regional" => true,
        "securityClass" => "B",
        "securityStatus" => 0.751689,
        "starID" => 40000019,
        "stargateIDs" => [50000067, 50000068]
      }
    ]
    {:ok, %{:dump => mock_dump_systems, :esi => mock_esi_systems}}
  end
  test "Converts jsonl entries into unified maps", context do
    dump = context.dump
    maps = Enum.map(dump, fn d -> Mapper.from_dump(d) end)
    assert(Enum.each(maps, fn m -> Map.has_key?(m, :security_status) && Map.has_key?(m, :constellation_id) && Map.has_key?(m, :system_id) && Map.has_key?(m, :name) end), "Every map in the list has :security_status, :constellation_id, :system_id and :name")
    assert(Enum.each(maps, fn m -> Map.keys(m) |> Enum.each(fn k -> is_atom(k) end) end), "Every key in a map is an atom")
  end
    test "Converts esi response into unified maps", context do
    data = context.esi
    maps = Enum.map(data, fn d -> Mapper.from_esi(d) end)
    assert(Enum.each(maps, fn m -> Map.has_key?(m, :security_status) && Map.has_key?(m, :constellation_id) && Map.has_key?(m, :system_id) && Map.has_key?(m, :name) end), "Every map in the list has :security_status, :constellation_id, :system_id and :name")
    assert(Enum.each(maps, fn m -> Map.keys(m) |> Enum.each(fn k -> is_atom(k) end) end), "Every key in a map is an atom")
  end
end
