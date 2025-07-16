defmodule EveIndustrex.Reactor do
  alias EveIndustrex.Blueprints
  alias EveIndustrex.Materials
  alias EveIndustrex.Types
  def get_alchemy_recipes() do
    types = Types.get_formulas()
    bps = Blueprints.get_blueprints_from_list_of_ids(Enum.map(types, fn b -> hd(b) end))
    type_ids = Enum.map(bps, fn b -> [b.blueprint_type_id, Enum.map(b.activities, fn a -> [ Enum.map(a.materials, fn m -> m.material_type_id end), Enum.map(a.products, fn p -> p.product_type_id end)] end)] end)

    product_types = Enum.map(bps, fn b -> [b.blueprint_type_id, Enum.map(b.activities, fn a -> %{:materials => Enum.map(a.materials, fn m -> m.material_type_id end), :products => Enum.map(a.products, fn p -> p.product_type_id end)} end) ] end) |> List.flatten() |> Enum.filter(fn ti -> !is_integer(ti) end) |> Enum.map(fn x -> x.products end) |> List.flatten()
    product_mats_types = Materials.get_product_materials_ids_from_type_id_list(product_types)


    recipes = Enum.zip(Enum.map(types, fn t -> Enum.at(t, 1) end), bps)

    reduced_type_ids = [type_ids | product_mats_types] |> List.flatten() |> Enum.uniq()

    {Enum.sort_by(recipes, &(elem(&1, 0)), :asc), reduced_type_ids}

  end
  def get_reactions() do
    types = Types.get_reactions()
    bps = Blueprints.get_blueprints_from_list_of_ids(Enum.map(types, fn b -> hd(b) end))
    type_ids = Enum.map(bps, fn b -> [b.blueprint_type_id, Enum.map(b.activities, fn a -> [ Enum.map(a.materials, fn m -> m.material_type_id end), Enum.map(a.products, fn p -> p.product_type_id end)] end)] end)

    product_types = Enum.map(bps, fn b -> [b.blueprint_type_id, Enum.map(b.activities, fn a -> %{:materials => Enum.map(a.materials, fn m -> m.material_type_id end), :products => Enum.map(a.products, fn p -> p.product_type_id end)} end) ] end) |> List.flatten() |> Enum.filter(fn ti -> !is_integer(ti) end) |> Enum.map(fn x -> x.products end) |> List.flatten()
    product_mats_types = Materials.get_product_materials_ids_from_type_id_list(product_types)


    recipes = Enum.zip(Enum.map(types, fn t -> Enum.at(t, 1) end), bps)

    reduced_type_ids = [type_ids | product_mats_types] |> List.flatten() |> Enum.uniq()

    {Enum.sort_by(recipes, &(elem(&1, 0)), :asc), reduced_type_ids}
  end
  def reduce_types(recipies) do
    Enum.map(recipies, fn r -> Enum.map(elem(r, 1).activities, fn a -> Enum.map(elem(a, 1), fn x -> extract_type_id(elem(x, 1))  end) end)end) |> List.flatten()
    |> Enum.filter(fn x -> x != nil end)
    |> Enum.uniq()
  end

  defp extract_type_id(value) when is_integer(value), do: nil
  defp extract_type_id(value) when is_list(value) do
      Enum.map(value, fn v -> Enum.at(elem(v, 0), 1) end)
  end

end
