defmodule Domain.Universe.Station.MapperTest do
  use ExUnit.Case
  alias EveIndustrex.Universe.Station.Mapper

  setup_all do
    mock_esi_stations = [
      %{
        max_dockable_ship_volume: 0,
        name: "string",
        office_rental_cost: 0,
        owner: 0,
        position: %{
          x: 0,
          y: 0,
          z: 0
        },
        race_id: 0,
        reprocessing_efficiency: 0,
        reprocessing_stations_take: 0,
        services: [
          "bounty-missions"
        ],
        station_id: 0,
        system_id: 0,
        type_id: 0
      },
          %{
        max_dockable_ship_volume: 0,
        name: "string",
        office_rental_cost: 0,
        owner: 0,
        position: %{
          x: 0,
          y: 0,
          z: 0
        },
        race_id: 0,
        reprocessing_efficiency: 0,
        reprocessing_stations_take: 0,
        services: [
          "bounty-missions"
        ],
        station_id: 0,
        system_id: 0,
        type_id: 0
      }
    ]
    {:ok, %{:esi => mock_esi_stations}}
  end

  test "Converts esi response into unified maps", context do
    data = context.esi
    maps = Enum.map(data, fn d -> Mapper.from_esi(d) end)
    assert(Enum.each(maps, fn m -> Map.has_key?(m, :system_id) && Map.has_key?(m, :services) && Map.has_key?(m, :reprocessing_stations_take) && Map.has_key?(m, :reprocessing_efficiency) && Map.has_key?(m, :station_id) && Map.has_key?(m, :name) end), "Every map in the list has :system_id, :station_id, :reprocessing_stations_take, :reprocessing_efficiency, :services and :name")
    assert(Enum.each(maps, fn m -> Map.keys(m) |> Enum.each(fn k -> is_atom(k) end) end), "Every key in a map is an atom")
  end

end
