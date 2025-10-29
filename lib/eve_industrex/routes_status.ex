defmodule EveIndustrex.RoutesStatus do
  alias EveIndustrex.ESI.Status


  def check_routes_status(list_of_routes) when is_list(list_of_routes) do
    case Status.get_routes_status() do
      {:error, error} ->
        {:error, error}
      {:ok, routes, headers} ->
        desired_routes = Enum.filter(routes, fn r -> Enum.member?(list_of_routes, r["route"]) end)
        {desired_routes, [last_modified: headers["last-modified"], expires: headers["expires"]]}
    end
  end
  def check_routes_status(map_of_routes) when is_map(map_of_routes) do
    case Status.get_routes_status() do
      {:error, error} ->
        {:error, error}
      {:ok, routes, headers} ->

        desired_routes = Enum.map(Map.to_list(map_of_routes), fn m -> %{elem(m, 0) => hd(Enum.filter(routes, fn r -> r["route"] == elem(m, 1)["route"] end))} end)
        |> Enum.reduce(fn x, acc ->
          Map.merge(x, acc)
        end)

        {desired_routes, headers["last-modified"], headers["expires"]}
    end
  end
end
