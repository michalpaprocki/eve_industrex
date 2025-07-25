defmodule EveIndustrex.Parser do
  @blueprints_path "data_dump/blueprints.yaml"
  @type_materials_path "data_dump/typeMaterials.yaml"


  def parse_bps() do
    content = yaml_simple(@blueprints_path)
    extract_yaml(content)

  end
  def parse_materials() do
    content = yaml_simple(@type_materials_path)
    extract_yaml_materials(content)
  end

  def yaml_simple(path)  do
    Application.start(:yamerl)
    content = :yamerl_constr.file(path)
    Application.stop(:yamerl)
   content
  end

  defp extract_yaml_materials(content) do
    Enum.map(List.flatten(content), fn c -> {elem(c, 0), hd(Enum.map(elem(c,1), fn v -> handle_value(v) end))} end)
  end

  defp extract_yaml(content) do
   Enum.map(List.flatten(content), fn c -> Enum.map(elem(c,1), fn v -> handle_value(v) end) end)
  end

  defp handle_value(data) when is_tuple(data) do
    {List.to_string(elem(data,0)), handle_value(elem(data, 1))}
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
end
