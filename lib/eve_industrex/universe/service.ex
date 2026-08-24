defmodule EveIndustrex.Universe.Service do
  @moduledoc false
  alias EveIndustrex.Universe.{System, Station}

  def get_systems(query) do
    System.Store.get_all()
    |> Enum.map(fn x ->
      %{name: elem(x, 1), system_id: elem(x, 0), security_status: elem(x, 2)}
    end)
    |> Enum.filter(fn x -> String.contains?(String.downcase(x.name), String.downcase(query)) end)
  end

  def get_low_sec_systems(query) do
    System.Store.get_all()
    |> Enum.filter(fn x ->
      elem(x, 2) < 0.45
    end)
    |> Enum.map(fn x ->
      %{name: elem(x, 1), system_id: elem(x, 0), security_status: elem(x, 2)}
    end)
    |> Enum.filter(fn x -> String.contains?(String.downcase(x.name), String.downcase(query)) end)
  end

  def get_trade_hub_station_ids(),
    do: [60_003_760, 60_008_494, 60_011_866, 60_004_588, 60_005_686]

  def get_trade_hubs() do
    Enum.map(get_trade_hub_station_ids(), fn id ->
      hub = Station.Store.get_station(id)

      %{
        name: elem(hub, 1),
        station_id: elem(hub, 0)
      }
    end)
  end
end
