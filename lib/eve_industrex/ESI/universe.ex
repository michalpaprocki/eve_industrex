defmodule EveIndustrex.ESI.Universe do
  alias EveIndustrex.Logger.EiLogger
  alias EveIndustrex.Utils
  @regions_url "https://esi.evetech.net/latest/universe/regions/"
  @constellations_url "https://esi.evetech.net/latest/universe/constellations/"
  @systems_url "https://esi.evetech.net/latest/universe/systems/"
  @stations_url "https://esi.evetech.net/latest/universe/stations/"
  @categories_url "https://esi.evetech.net/latest/universe/categories/"
  @groups_url "https://esi.evetech.net/latest/universe/groups/"

  def fetch_regions() do
    case Utils.fetch_from_url(@regions_url) do
      {:ok, regions_ids} ->
        regions = Task.Supervisor.async_stream(EveIndustrex.TaskSupervisor, regions_ids, fn r ->
          Utils.fetch_from_url!(@regions_url<>~s"#{r}")
        end) |> Enum.map(fn x -> elem(x, 1) end)
        {:ok, regions}
      {:error, error} ->
        {:error, error}
    end
  end

  def fetch_regions!() do
    case Utils.can_fetch?(@regions_url) do
      true ->
        regions_ids = Utils.fetch_from_url!(@regions_url)
         Task.Supervisor.async_stream(EveIndustrex.TaskSupervisor, regions_ids, fn r ->
          Utils.fetch_from_url!(@regions_url<>~s"#{r}")
        end) |> Enum.map(fn x -> elem(x, 1) end)
      {false, error} ->
          EiLogger.log(:error, error)
        raise "Could not initiate fetching"
    end
  end

  def fetch_constellations() do
    case Utils.fetch_from_url(@constellations_url) do
      {:ok, constellations_ids} ->
        constellations = Task.Supervisor.async_stream(EveIndustrex.TaskSupervisor, constellations_ids, fn c ->
          Utils.fetch_from_url!(@constellations_url<>~s"#{c}") end) |> Enum.map(fn x -> elem(x, 1) end)
        {:ok, constellations}
      {:error, error} ->
        {:error, error}
      end
    end
  def fetch_constellations!() do
    case Utils.can_fetch?(@constellations_url) do
      true ->
        constellations_ids = Utils.fetch_from_url!(@constellations_url)
        Task.Supervisor.async_stream(EveIndustrex.TaskSupervisor, constellations_ids, fn c ->
          Utils.fetch_from_url!(@constellations_url<>~s"#{c}")
        end) |> Enum.map(fn x -> elem(x, 1) end) |> Enum.map(fn x -> elem(x, 1) end)
        {false, error} ->
            EiLogger.log(:error, error)
          raise "Could not initiate fetching"
    end
  end


  def fetch_systems() do
    case Utils.fetch_from_url(@systems_url) do
      {:ok, systems_ids} ->
        systems = Task.Supervisor.async_stream(EveIndustrex.TaskSupervisor, systems_ids, fn s ->
          Utils.fetch_from_url!(@systems_url<>~s"#{s}")
        end) |> Enum.map(fn x -> elem(x, 1) end)
        {:ok, systems}
      {:error, error} ->
        {:error, error}
    end
  end
  def fetch_systems!() do
    case Utils.can_fetch?(@systems_url) do
      true ->
         systems_ids = Utils.fetch_from_url!(@systems_url)
        Task.Supervisor.async_stream(EveIndustrex.TaskSupervisor, systems_ids, fn s ->
          Utils.fetch_from_url!(@systems_url<>~s"#{s}")
        end) |> Enum.map(fn x -> elem(x, 1) end) |> Enum.map(fn x -> elem(x, 1) end)
      {false, error} ->
          EiLogger.log(:error, error)
        raise "Could not initiate fetching"
    end

  end

  def fetch_station(id) do
    Utils.fetch_from_url(@stations_url<>~s"#{id}")
  end
  def fetch_categories() do
    categories_ids = Utils.fetch_from_url(@categories_url)
    Enum.map(categories_ids, fn ci -> Utils.fetch_from_url(@categories_url<>~s"#{ci}") end)
  end
  def fetch_groups() do
    current_pages = Utils.get_ESI_pages_amount(@groups_url)
    groups = Utils.fetch_ESI_pages(@groups_url, String.to_integer(current_pages))
    Enum.map(Enum.with_index(groups),fn {g, i} -> Utils.fetch_from_url(@groups_url<>~s"#{g}", i) end)
  end
  def fetch_group(group_id) do
    Utils.fetch_from_url(@groups_url<>~s"#{group_id}")
  end

end
