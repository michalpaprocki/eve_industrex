defmodule EveIndustrex.Blueprints do

  alias EveIndustrex.Schemas.{BlueprintActivity, Blueprint, BlueprintProduct,Type}
  alias EveIndustrex.Parser
  alias EveIndustrex.Repo
  import Ecto.Query

  def get_blueprints() do
    Repo.all(Blueprint) |> Repo.preload(:activities)
  end
  def get_blueprint(id), do: Repo.get_by(Blueprint, blueprint_type_id: id) |> Repo.preload([:activities, activities: [:materials, :products, products: [:product]]])
  def get_blueprints_from_list_of_ids(list_of_ids) do
    from(b in Blueprint, where: b.blueprint_type_id in ^list_of_ids) |> Repo.all |> Repo.preload([:activities, activities: [:products, :materials, products: [:product, product: [:products, products: [:material_type]]], materials: [:material_type]]])
  end
  def get_blueprint_products_and_materials_type_ids(list_of_ids) do
    from(b in Blueprint, where: b.blueprint_type_id in ^list_of_ids,
    preload: [activities: [:products, :materials, products: [:product, product: [:product]]]]
    ) |> Repo.all
  end
  def get_blueprint_products_type_ids(list_of_bp_ids) do
    from(b in Blueprint, where: b.blueprint_type_id in ^list_of_bp_ids) |> Repo.all |> Repo.preload([activities: [:materials]])  |> Enum.map(fn b -> Enum.map(b.activities, fn a -> Enum.map(a.materials, fn p -> p.product_type_id end) end) end) |> List.flatten()
  end



  def insert_bps_from_dump() do
    Repo.delete_all(Blueprint)
    Repo.delete_all(BlueprintActivity)
    Repo.delete_all(BlueprintProduct)
    bps = Parser.parse_bps()

    Task.Supervisor.async_stream(EveIndustrex.TaskSupervisor, bps, fn bp ->
      %Blueprint{} |> Blueprint.changeset(
        %{
          blueprint_type_id:  elem(Enum.at(bp, 1), 1),
          max_production_limit: elem(Enum.at(bp, 2),1),
          activities: populate_activities(elem(hd(bp), 1), elem(Enum.at(bp, 1), 1)),
          product_type_id: elem(Enum.at(bp, 1), 1)
          }
      ) |> Repo.insert()
        end)
        |> Stream.run()

  end

  defp populate_activities(activities, bp_id) do

    Enum.map(activities, fn a ->

      case elem(a, 0) do
        "copying" ->
        %{activity_type: :copying, blueprint_type_id: bp_id, time: get_time(a)}

        "manufacturing" ->
         %{
            activity_type: :manufacturing,
            blueprint_type_id: bp_id,
            time: get_time(a),
            products: extract_manufacturing_products(List.keyfind(elem(a, 1), "products", 0), bp_id),
            materials: extract_manufacturing_materials(List.keyfind(elem(a, 1), "materials", 0), bp_id)
          }

        "research_material" ->
          %{
            activity_type: :research_material,
            blueprint_type_id: bp_id,
            time: get_time(a)
          }

        "research_time" ->

          %{
            activity_type: :research_time,
            blueprint_type_id: bp_id,
            time: get_time(a)
          }
        "reaction" ->

          %{
            activity_type: :reaction,
            time: get_time(a),
            products: extract_manufacturing_products(List.keyfind(elem(a, 1), "products", 0), bp_id),
            materials: extract_manufacturing_materials(List.keyfind(elem(a, 1), "materials", 0), bp_id)
          }
          _-> nil

        end
      end) |>  Enum.filter(fn a -> a != nil end)
  end

  defp extract_manufacturing_products({"products", values}, bp_id) do
    Enum.map(values, fn {id, amount} ->
      bp_product = Repo.get_by(Type, type_id: id)
      bp = Repo.get_by(Type, type_id: bp_id) |> Repo.preload(:bp_products)
      Type.changeset(bp, %{})|> Ecto.Changeset.put_assoc(:bp_products, [bp_product]) |> Repo.update()
      %{amount: amount, product_type_id: id, }
    end)
  end
  defp extract_manufacturing_products(nil, _bp_id), do: nil

  defp extract_manufacturing_materials({"materials", values}, bp_id) do
    Enum.map(values, fn {id, amount} ->
      %{product_type_id: bp_id, material_type_id: id, amount: amount}
    end)
  end
  defp extract_manufacturing_materials(nil, _bp_id), do: nil
  defp get_time(tuple) do
    elem(List.keyfind(elem(tuple, 1), "time", 0), 1)
  end
end
