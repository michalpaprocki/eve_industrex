defmodule EveIndustrex.Reactor do
  alias EveIndustrex.Materials
  alias EveIndustrex.Types
  def get_alchemy_recipes() do
    types = Types.get_formulas()
    bps = Types.get_bps_from_id_list(Enum.map(types, fn b -> hd(b) end))
    |> Enum.map(fn b -> Map.update(b, :activities, nil, fn prev_value ->  :erlang.binary_to_term(prev_value) end) end)
    |> Enum.map(fn b ->  Map.replace(b, :activities, Enum.map(b.activities, fn a -> extract_reaction(a) end))end)
    recipes = Enum.zip(Enum.map(types, fn t -> Enum.at(t, 1) end), bps)

    reduced_types = reduce_types(recipes)
    mats = extract_mats(reduced_types)
    reduced_types_with_mats = Enum.uniq(List.flatten([mats | reduced_types]))

    {Enum.sort_by(recipes, &(&1), :asc), reduced_types_with_mats}
  end
  def get_reactions() do
    types = Types.get_reactions()

    bps = Types.get_bps_from_id_list(Enum.map(types, fn b -> hd(b) end))
    |> Enum.map(fn b -> Map.update(b, :activities, nil, fn prev_value ->  :erlang.binary_to_term(prev_value) end) end)
    |> Enum.map(fn b ->  Map.replace(b, :activities, Enum.map(b.activities, fn a -> extract_reaction(a) end))end)
    recipes = Enum.zip(Enum.map(types, fn t -> Enum.at(t, 1) end), bps)

    reduced_types = reduce_types(recipes)
    mats = extract_mats(reduced_types)
    reduced_types_with_mats = Enum.uniq(List.flatten([mats | reduced_types]))

    {Enum.sort_by(recipes, &(&1), :asc), reduced_types_with_mats}
  end
  def reduce_types(recipies) do
    Enum.map(recipies, fn r -> Enum.map(elem(r, 1).activities, fn a -> Enum.map(elem(a, 1), fn x -> extract_type_id(elem(x, 1))  end) end)end) |> List.flatten()
    |> Enum.filter(fn x -> x != nil end)
    |> Enum.uniq()
  end
  defp extract_reaction({"reaction", list}) do
    {"reaction" ,Enum.map(list, fn l -> {elem(l, 0), handle_different_types(elem(l, 1))} end)}
  end
  defp extract_reaction({value, list}), do: {value, list}
  defp handle_different_types(value) when is_integer(value), do: value
  defp handle_different_types(value) when is_list(value) do
    Enum.map(value, fn x -> {Types.get_type_name(elem( x, 0)), elem( x,1)} end)
  end
  defp extract_type_id(value) when is_integer(value), do: nil
  defp extract_type_id(value) when is_list(value) do
      Enum.map(value, fn v -> Enum.at(elem(v, 0), 1) end)
  end

  def extract_mats(list), do: Enum.map(Materials.get_materials_from_type_id_list(list), fn m -> Enum.map(elem(m.materials, 1), fn x -> elem(x, 1) end) end)
end
