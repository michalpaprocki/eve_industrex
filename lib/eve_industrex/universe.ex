defmodule EveIndustrex.Universe do
  import Ecto.Query
  alias EveIndustrex.Utils
  alias EveIndustrex.Parser
  alias EveIndustrex.Schemas.{Region, Station, System, Constellation, Category, Group}
  alias EveIndustrex.Repo
  alias EveIndustrex.ESI.Universe
  @trade_hubs [60003760,60008494,60011866,60004588,60005686]


  def update_regions_from_ESI() do
    case Universe.fetch_regions() do
      {:error, error} ->
        {:error, error}
      {:ok, regions} ->
        Task.Supervisor.async_stream(EveIndustrex.TaskSupervisor, regions, fn r ->
          case get_region(r["region_id"]) do
            nil ->
              %Region{}
            region ->
              region
          end
            |> Region.changeset(r)
            |> Repo.insert_or_update()
        end) |> Stream.run()
    end
  end

  def update_regions_from_ESI!() do
    regions = Universe.fetch_regions!()
    Task.Supervisor.async_stream(EveIndustrex.TaskSupervisor, regions, fn r ->
      case get_region(r["region_id"]) do
        nil ->
          %Region{}
        region ->
          region
      end
        |> Region.changeset(r)
        |> Repo.insert_or_update()
    end) |> Stream.run()
  end
  def update_constellations_from_ESI() do
    case Universe.fetch_constellations() do
      {:error, error} ->
        {:error, error}
      {:ok, constellations} ->
        Task.Supervisor.async_stream(EveIndustrex.TaskSupervisor, constellations, fn c ->
           case get_constellation(c["constellation_id"]) do
            nil ->
              %Constellation{}
            constellation ->
              constellation
           end
          |> Constellation.changeset(c)
          |> Repo.insert_or_update()
        end) |> Stream.run()
    end
  end
  def update_constellations_from_ESI!() do
    constellations = Universe.fetch_constellations!()
    Task.Supervisor.async_stream(EveIndustrex.TaskSupervisor, constellations, fn c ->
    case get_constellation(c["constellation_id"]) do
      nil ->
        %Constellation{}
      constellation ->
        constellation
    end
    |> Constellation.changeset(c)
    |> Repo.insert_or_update()
    end) |> Stream.run()
  end

  def update_systems_from_ESI() do
    case Universe.fetch_systems() do
      {:error, error} ->
        {:error, error}
      {:ok, systems} ->
      Task.Supervisor.async_stream(EveIndustrex.TaskSupervisor, systems, fn s ->
        case get_system(s["system_id"]) do
          nil ->
            %System{}
          system ->
            system
          end
          |> System.changeset(s)
          |> Repo.insert_or_update()
      end) |> Stream.run()
    end
  end
  def update_systems_from_ESI!() do
    systems = Universe.fetch_systems!()
    Task.Supervisor.async_stream(EveIndustrex.TaskSupervisor, systems, fn s ->
      case get_system(s["system_id"]) do
        nil ->
          %System{}
        system ->
          system
      end
      |> System.changeset(s)
      |> Repo.insert_or_update()
    end) |> Stream.run()
  end
  def update_stations_from_ESI() do
    stations = get_system_stations() |> List.flatten()
    case Utils.can_fetch?(Universe.get_stations_url()<>Integer.to_string(hd(stations))<>"/") do
      {false, error} ->
        {:error, error}
      true ->
        Task.Supervisor.async_stream(EveIndustrex.TaskSupervisor, stations, fn station_id -> update_station!(station_id) end) |> Stream.run()
    end
  end

  def update_station!(stations_ids) do
    stations = Enum.map(stations_ids, fn id -> Universe.fetch_station!(id) end)
    Enum.map(stations, fn station ->
      %Station{}
      |> Station.changeset(station)
      |> Repo.insert_or_update()
    end)

  end

  def get_regions(), do: Repo.all(Region)
  def get_regions_ids(), do: from(r in Region, select: r.region_id) |> Repo.all
  def get_regions_with_assoc() do
    query = from r in Region, join: c in Constellation, on: r.region_id == c.region_id, preload: [constellations: c]
    Repo.all(query)
  end
  def get_constellations(), do: Repo.all(Constellation)
  def get_constellations_with_assoc(), do: Repo.all(from c in Constellation, preload: [:region])
  def get_systems(), do: Repo.all(System)
  def get_systems_with_assoc(), do:  Repo.all(from s in System, preload: [:constellation, constellation: :region])
  def get_system_stations(), do: Repo.all(from s in System, where: not is_nil(s.stations), order_by: [asc: s.stations], select: s.stations)
  def get_stations(), do: Repo.all(Station)
  def get_station_by_station_id(id), do: Repo.get_by(Station, station_id: id)
  def get_stations_with_assoc(), do: Repo.all(from s in Station, preload: [:system, system: :constellation, system: [constellation: :region]])
  def get_trade_hubs() do
    from(s in Station, where: s.station_id in @trade_hubs, order_by: [asc: s.name], select: %{name: s.name, station_id: s.station_id}) |> Repo.all
  end
  def get_region(name) when is_binary(name), do: Repo.get_by(Region, name: name)
  def get_region(id) when is_integer(id), do: Repo.get_by(Region, region_id: id)
  def get_regions_count(), do: Repo.aggregate(Region, :count)
  def get_constellation(name) when is_binary(name), do: Repo.get_by(Constellation, name: name)
  def get_constellation(id) when is_integer(id), do: Repo.get_by(Constellation, constellation_id: id)
  def get_system(name) when is_binary(name), do: Repo.get_by(System, name: name)
  def get_system(id) when is_integer(id), do: Repo.get_by(System, system_id: id)
  def get_station(id) when is_integer(id), do: Repo.get_by(Station, station_id: id)
  def get_station(name) when is_binary(name), do: Repo.get_by(Station, name: name)
  def get_station_by_aprox(like_name) when is_binary(like_name) do
    query_string = "%#{like_name}%"
    from(s in Station, where: ilike(s.name, ^query_string)) |> Repo.all()
  end
  def insert_category(attrs) do
    result = Repo.get_by(Category, category_id: attrs["category_id"])
    case result do
      nil ->
        %Category{}
      category ->
        category
    end
    |> Category.changeset(attrs)
    |> Repo.insert_or_update()
  end
  def insert_group(attrs) do
    case Repo.get_by(Group, group_id: attrs["group_id"]) do
      nil ->
        %Group{}
      group ->
          group
    end
    |> Group.changeset(attrs)
    |> Repo.insert_or_update()
  end
  def update_category_from_dump(dumped_data) do
    case Repo.get_by(Category, category_id: elem(dumped_data, 0)) do
      nil ->
        %Category{}
      category ->
        category
    end
    |> Category.changeset(
      %{
        :published => elem(Enum.at(elem(dumped_data, 1), 0), 1),
        :name => List.to_string(elem(List.keyfind(elem(List.keyfind(elem(dumped_data, 1), "name", 0), 1), "en", 0), 1)),
        :category_id => elem(dumped_data, 0)

      }
    )
    |> Repo.insert_or_update()
  end
  def update_group_from_dump(dumped_data) do
    case Repo.get_by(Group, group_id: elem(dumped_data, 0)) do
      nil ->
        %Group{}
      group ->
          group
    end
    |> Group.changeset(
      %{
        :group_id => elem(dumped_data, 0), :name => List.to_string(elem(List.keyfind(elem(List.keyfind(elem(dumped_data, 1), "name", 0), 1), "en", 0), 1)),
        :published => elem(List.keyfind(elem(dumped_data, 1), "published", 0), 1), :category_id =>  elem(List.keyfind(elem(dumped_data, 1), "categoryID", 0), 1)
      }
    )
    |> Repo.insert_or_update()
  end
  def update_categories_from_ESI() do
    case Universe.fetch_categories() do
      {:error, error} ->
        {:error, error}
      {:ok, categories} ->
        Task.Supervisor.async_stream(EveIndustrex.TaskSupervisor, categories, fn c ->
          case get_category(c["category_id"]) do
            nil ->
              %Category{}
            category ->
              category
          end
          |> Category.changeset(c)
          |> Repo.insert_or_update()
        end) |> Stream.run()
    end
  end
  def update_categories_from_dump() do
    categories = Parser.parse_categories()
    Task.Supervisor.async_stream(EveIndustrex.TaskSupervisor, categories, fn c ->
      update_category_from_dump(c)
    end) |> Stream.run()
  end
  def update_groups_from_ESI() do
    case Universe.fetch_groups() do
      {:error, error} ->
        {:error, error}
      {:ok, groups} ->
        Task.Supervisor.async_stream(EveIndustrex.TaskSupervisor, groups, fn  g ->
          insert_group(g)
        end) |> Stream.run()
    end
  end
  def update_groups_from_dump() do
    groups = Parser.parse_groups()
    Task.Supervisor.async_stream(EveIndustrex.TaskSupervisor, groups, fn  g ->
      update_group_from_dump(g)
    end) |> Stream.run()
  end

  def get_categories() do
    from(c in Category) |> Repo.all()
  end
  def get_category(category_id), do: Repo.get_by(Category, category_id: category_id)
  def get_groups() do
    from(g in Group) |> Repo.all()
  end
  def get_group(group_id) do
    from(g in Group, where: g.group_id == ^group_id) |> Repo.all
  end
  def delete_groups(), do: from(g in Group) |> Repo.delete_all()
  def delete_categories(), do: from(c in Category) |> Repo.delete_all()
  def get_blueprints_with_groups() do
    from(g in Group, preload: [:types]) |> Repo.all
  end
end
