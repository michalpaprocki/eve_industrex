defmodule EveIndustrex.Universe do
  import Ecto.Query
  alias EveIndustrex.Parser
  alias EveIndustrex.Schemas.{Region, Station, System, Constellation, Category, Group}
  alias EveIndustrex.Repo
  alias EveIndustrex.ESI.Universe
  @trade_hubs [60003760,60008494,60011866,60004588,60005686]
  def update_regions_from_ESI() do
      regions = Universe.fetch_regions()
      for r <- regions do
        case get_region(r["region_id"]) do
          nil ->
            %Region{}
          region -> region
        end
        |> Region.changeset(r)
        |> Repo.insert_or_update()
      end
  end

  def update_constellations_from_ESI() do
    constellations = Universe.fetch_constellations()
    for c <- constellations do
      case get_region(c["region_id"]) do
        nil -> nil
        found_region ->
          case get_constellation(c["constellation_id"]) do
            nil ->
              %Constellation{}
              |> Ecto.Changeset.change(region_id: found_region.region_id)
            constellation ->
              constellation
            end

          |> Constellation.changeset(c)
          |> Repo.insert_or_update()
      end
    end
  end

  def create_system(map) do
    %System{}
    |> System.changeset(map)
    |> Repo.insert()
  end

  def update_systems_from_ESI() do
    systems = Universe.fetch_systems()
    for s <- systems do
      case get_constellation(s["constellation_id"]) do
        nil ->
           nil
        found_constellation ->
          case get_system(s["system_id"]) do
            nil ->
              %System{}
              |> Ecto.Changeset.change(constellation_id: found_constellation.constellation_id)
            system ->
              system
          end
          |> System.changeset(s)
          |> Repo.insert_or_update()
      end
    end

  end
  def update_stations_from_ESI() do
    stations =
    get_system_stations()
    |> Enum.filter(fn {stations, _system} -> stations != nil end)

    Task.Supervisor.async_stream(EveIndustrex.TaskSupervisor, stations, fn tuple -> update_station(tuple) end) |> Stream.run()

  end
  def update_station({stations_ids, system_id}) do
    stations = Enum.map(stations_ids, fn id -> Universe.fetch_station(id) end)
    Enum.map(stations, fn station ->
      %Station{}
      |> Ecto.Changeset.change(system_id: system_id)
      |> Station.changeset(station)
      |> Repo.insert_or_update()
    end)

  end

  def get_regions(), do: Repo.all(Region)
  def get_regions_with_assoc() do
    query = from r in Region, join: c in Constellation, on: r.region_id == c.region_id, preload: [constellations: c]
    Repo.all(query)
  end
  def get_constellations(), do: Repo.all(Constellation)
  def get_constellations_with_assoc(), do: Repo.all(from c in Constellation, preload: [:region])
  def get_systems(), do: Repo.all(System)
  def get_systems_with_assoc(), do:  Repo.all(from s in System, preload: [:constellation, constellation: :region])
  def get_system_stations(), do: Repo.all(from s in System, select: {s.stations, s.system_id})
  def get_stations(), do: Repo.all(Station)
  def get_station_by_station_id(id), do: Repo.get_by(Station, station_id: id)
  def get_stations_with_assoc(), do: Repo.all(from s in Station, preload: [:system, system: :constellation, system: [constellation: :region]])
  def get_trade_hubs() do
    from(s in Station, where: s.station_id in @trade_hubs, order_by: [asc: s.name], select: %{name: s.name, station_id: s.station_id}) |> Repo.all
  end
  def get_region(name) when is_binary(name), do: Repo.get_by(Region, name: name)
  def get_region(id) when is_integer(id), do: Repo.get_by(Region, region_id: id)
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
    result =Repo.get_by(Category, category_id: attrs["category_id"])
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
  def insert_category_dump(dumped_data) do
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
  def insert_group_dump(dumped_data) do
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
    categories_ids = Universe.fetch_categories()
    Task.Supervisor.async_stream(EveIndustrex.TaskSupervisor, categories_ids, fn c ->
      insert_category(c)
    end) |> Stream.run()
  end
  def update_categories_from_dump() do
    categories = Parser.parse_categories()
    Task.Supervisor.async_stream(EveIndustrex.TaskSupervisor, categories, fn c ->
      insert_category_dump(c)
    end) |> Stream.run()
  end
  def update_groups_from_ESI() do
    groups_ids = Universe.fetch_groups()
    Task.Supervisor.async_stream(EveIndustrex.TaskSupervisor, groups_ids, fn  g ->
      insert_group(g)
    end) |> Stream.run()

  end
  def update_groups_from_dump() do
    groups = Parser.parse_groups()
    Task.Supervisor.async_stream(EveIndustrex.TaskSupervisor, groups, fn  g ->
      insert_group_dump(g)
    end) |> Stream.run()

  end
  def add_group(group_id) do
    group = Universe.fetch_group(group_id)
    insert_group(group)
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
