defmodule EveIndustrex.ESI.Universe do
  alias EveIndustrex.Logger.EiLogger
  alias EveIndustrex.Utils
  @regions_url "https://esi.evetech.net/latest/universe/regions/"
  @constellations_url "https://esi.evetech.net/latest/universe/constellations/"
  @systems_url "https://esi.evetech.net/latest/universe/systems/"
  @stations_url "https://esi.evetech.net/latest/universe/stations/"
  @categories_url "https://esi.evetech.net/latest/universe/categories/"
  @groups_url "https://esi.evetech.net/latest/universe/groups/"

  def get_stations_url(), do: @stations_url
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
        end) |> Enum.map(fn x -> elem(x, 1) end)
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
        end) |> Enum.map(fn x -> elem(x, 1) end)
      {false, error} ->
          EiLogger.log(:error, error)
        raise "Could not initiate fetching"
    end

  end
  def fetch_station!(id) do
    Utils.fetch_from_url!(@stations_url<>~s"#{id}")
  end
  def fetch_categories() do
    case Utils.fetch_from_url(@categories_url) do
      {:error, error} ->
        {:error, error}
      {:ok, categories_ids} ->
        categories =
        Task.Supervisor.async_stream(EveIndustrex.TaskSupervisor, categories_ids, fn ci -> Utils.fetch_from_url!(@categories_url<>~s"#{ci}") end) |> Enum.map(fn x -> elem(x, 1) end)
        {:ok, categories}
    end
  end
  def fetch_categories!() do
    case Utils.can_fetch?(@categories_url) do
      {false, error} ->
        EiLogger.log(:error, error)
        raise "Could not initiate fetching"
      true ->
          categories_ids = Utils.fetch_from_url!(@categories_url)
         Task.Supervisor.async_stream(EveIndustrex.TaskSupervisor, categories_ids, fn ci ->
            Utils.fetch_from_url!(@categories_url<>~s"#{ci}")
        end) |> Enum.map(fn x -> elem(x, 1) end)
    end
  end
  def fetch_groups() do
    case Utils.get_ESI_pages_amount(@groups_url) do
      {:error, error} ->
        {:error, error}
      {:ok, pages} ->
        groups_ids = Utils.fetch_ESI_pages(@groups_url, String.to_integer(pages))
        groups = Task.Supervisor.async_stream(EveIndustrex.TaskSupervisor, groups_ids,fn g -> Utils.fetch_from_url(@groups_url<>~s"#{g}") end) |> Enum.map(fn x -> elem(x, 1) end)
        {:ok, groups}
    end
  end
end
