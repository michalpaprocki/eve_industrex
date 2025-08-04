defmodule EveIndustrex.Parser do
  require Logger
  @blueprints_path "data_dump/blueprints.yaml"
  @type_materials_path "data_dump/typeMaterials.yaml"
  @types_path "data_dump/types.yaml"
  @categories_path "data_dump/categories.yaml"
  @groups_path "data_dump/groups.yaml"
  @market_groups_path "data_dump/marketGroups.yaml"
  def parse_bps() do
    content = yaml_simple_with_tc(@blueprints_path)
    extract_yaml_bps(content)

  end
  def parse_materials() do
    content = yaml_simple_with_tc(@type_materials_path)
    extract_yaml_materials(content)
  end
  def parse_types() do
    content = yaml_simple_with_tc(@types_path)
    extract_yaml_categories(content)
  end
  def parse_groups() do
    content = yaml_simple_with_tc(@groups_path)
    extract_yaml_categories(content)
  end
  def parse_categories() do
    content = yaml_simple_with_tc(@categories_path)
    extract_yaml_categories(content)
  end
  def parse_market_groups() do
    content = yaml_simple_with_tc(@market_groups_path)
    extract_yaml_market_groups(content)
  end
  def yaml_simple_with_tc(path) do
    {time, result} = :timer.tc(fn -> yaml_simple(path) end, :seconds)
    Logger.info("Done parsing in #{time} seconds")
    result
  end
  def yaml_simple(path)  do
    Application.start(:yamerl)
    task = Task.Supervisor.async(EveIndustrex.TaskSupervisor, fn -> :yamerl_constr.file(path) end) |> Task.await(:infinity)
    Application.stop(:yamerl)
    task
  end
  def parse_html_to_latest_patch_notes_path(html) do
    html
      |> String.split("<")
      |> Enum.filter(fn string -> String.contains?(string, "/news/view") end)
      |> hd()
      |> String.split("\"")
      |> Enum.at(1)
      |> String.split("/")
      |> Enum.at(3)
  end
  def parse_path_to_tq_version(path) do
    if String.contains?(path, "expansion") do
        path |> String.split("-") |> Enum.take(2) |> Enum.join(" ")
      else
        path |> String.split("-") |> Enum.take(-2) |> Enum.join(".")
    end

  end
  defp extract_yaml_categories(content) do
    Enum.map(List.flatten(content), fn c -> {elem(c, 0), Enum.sort(Enum.map(elem(c, 1), fn v ->  handle_value(v) end), &(&1 > &2))} end)
  end
  defp extract_yaml_materials(content) do
    Enum.map(List.flatten(content), fn c -> {elem(c, 0), hd(Enum.map(elem(c,1), fn v -> handle_value(v) end))} end)
  end
  defp extract_yaml_market_groups(content) do
    Enum.map(List.flatten(content), fn c -> {elem(c, 0), Enum.sort(Enum.map(elem(c, 1), fn v ->  handle_value(v) end), &(&1 > &2))} end)
  end
  defp extract_yaml_bps(content) do
   Enum.map(List.flatten(content), fn c -> Enum.map(elem(c,1), fn v -> handle_value(v) end) end)
  end

  defp handle_value(data) when is_tuple(data) do
    if is_integer(elem(data,0)) do
      {elem(data,0), handle_value(elem(data, 1))}
    else
      {List.to_string(elem(data,0)), handle_value(elem(data, 1))}
    end
  end
  defp handle_value(data) when is_list(data) do
    cond do
      data == [] -> []
      is_list(hd(data)) && rem(length(hd(data)), 2) != 0 ->
        Enum.map(data, fn children -> Enum.map(children, fn c -> {List.to_string(elem(c,0)), elem(c,1)} end) end)
      is_list(hd(data)) ->
        Enum.filter(Enum.map(Enum.with_index(List.flatten(data)), fn {d,i}-> if rem(i, 2) ==0, do:
        {elem(Enum.at(List.flatten(data), i + 1), 1), elem(d, 1)},
        else: nil end), fn x -> x != nil end )
      true ->
        Enum.map(data, fn d-> handle_value(d) end)
    end
  end
  defp handle_value(data) when is_number(data), do: data
  defp handle_value(data) when is_boolean(data), do: data
end
