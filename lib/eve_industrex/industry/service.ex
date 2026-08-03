defmodule EveIndustrex.Industry.Service do
  alias EveIndustrex.Universe.{System, Type}
  alias EveIndustrex.Industry

  @moduledoc """
  This service deals with all the live view ralated industrial needs, liek generating reactions view, enriching said views and updating them by user inputs.
  """
  def get_reactions_view() do
    formulas = Industry.Blueprint.Query.get_reaction_formulas()

    Map.new(formulas, fn {id, f} ->
      {id, %{type: f, bp: Industry.Blueprint.Store.get_blueprint(id) |> handle_prepare()}}
    end)
  end

  def extract_reactions_type_ids(reactions) do
    Enum.map(reactions, fn {_id, r} -> extract_bp_type_ids(r.bp) end)
    |> List.flatten()
    |> Enum.uniq()
  end

  def extract_bp_type_ids(bp) do
    Enum.map(bp.activities, fn {_k, a} ->
      [
        Enum.map(a.materials, fn m ->
          m.type_id
        end),
        Enum.map(a.products, fn p ->
          p.type_id
        end)
      ]
    end)
    |> List.flatten()
    |> List.flatten()
  end

  def prepare_blueprints(bps) do
    Enum.map(bps, fn bp ->
      prepare_blueprint(bp)
    end)
  end

  def enrich(formulas, orders, order_type) do
    case order_type do
      "sell" ->
        Map.new(formulas, fn {id, f} ->
          {id,
           Map.put(f, :prices, %{
             products: assign_bp_product_price(f.bp, orders, :min_sell),
             materials: assign_bp_materials_price(f.bp, orders, :min_sell)
           })}
        end)
        |> Map.new(fn {id, f} ->
          {id, Map.put(f, :profit, calc_profit(f, f.prices))}
        end)

      "buy" ->
        Map.new(formulas, fn {id, f} ->
          {id,
           Map.put(f, :prices, %{
             products: assign_bp_product_price(f.bp, orders, :max_buy),
             materials: assign_bp_materials_price(f.bp, orders, :max_buy)
           })}
        end)
        |> Map.new(fn {id, f} ->
          {id, Map.put(f, :profit, calc_profit(f, f.prices))}
        end)

      "buy_sell" ->
        Map.new(formulas, fn {id, f} ->
          {id,
           Map.put(f, :prices, %{
             products: assign_bp_product_price(f.bp, orders, :min_sell),
             materials: assign_bp_materials_price(f.bp, orders, :max_buy)
           })}
        end)
        |> Map.new(fn {id, f} ->
          {id, Map.put(f, :profit, calc_profit(f, f.prices))}
        end)

      "sell_buy" ->
        Map.new(formulas, fn {id, f} ->
          {id,
           Map.put(f, :prices, %{
             products: assign_bp_product_price(f.bp, orders, :max_buy),
             materials: assign_bp_materials_price(f.bp, orders, :min_sell)
           })}
        end)
        |> Map.new(fn {id, f} ->
          {id, Map.put(f, :profit, calc_profit(f, f.prices))}
        end)

      _ ->
        formulas
    end
    |> Map.new(fn {id, f} ->
      {id, Map.put(f, :adjusted_prices, assign_average_prices(f, orders))}
    end)
  end

  # to do project AP

  def update_blueprint(bp, type, price, type_id) do
    case type do
      :product ->
        bp = put_in(bp[:prices][:products][type_id], price)
        put_in(bp, [:profit], calc_profit(bp, bp.prices))

      :bp_materials ->
        bp = put_in(bp[:prices][:materials][type_id], price)
        put_in(bp, [:profit], calc_profit(bp, bp.prices))
    end
  end

  def assign_average_prices(bp, orders) do
    Map.new(bp.bp.activities.reaction.materials, fn %{
                                                      name: _,
                                                      category_id: _,
                                                      type_id: type_id,
                                                      quantity: _
                                                    } ->
      {type_id, Map.get(orders.adjusted_prices, type_id)}
    end)
  end

  def assign_bp_materials_price(bp, orders, key) do
    if Map.has_key?(bp.activities, :manufacturing) do
      Map.new(bp.activities.manufacturing.materials, fn %{
                                                          name: _,
                                                          category_id: _,
                                                          type_id: type_id,
                                                          quantity: _
                                                        } ->
        {type_id, Map.get(orders.prices[type_id], key)}
      end)
    else
      Map.new(bp.activities.reaction.materials, fn %{
                                                     name: _,
                                                     category_id: _,
                                                     type_id: type_id,
                                                     quantity: _
                                                   } ->
        {type_id, Map.get(orders.prices[type_id], key)}
      end)
    end
  end

  def assign_bp_product_price(bp, orders, key) do
    if Map.has_key?(bp.activities, :manufacturing) do
      Map.new(bp.activities.manufacturing.products, fn %{
                                                         name: _,
                                                         category_id: _,
                                                         type_id: type_id,
                                                         quantity: _,
                                                         probability: _
                                                       } ->
        {type_id, Map.get(orders.prices[type_id], key)}
      end)
    else
      Map.new(bp.activities.reaction.products, fn %{
                                                    name: _,
                                                    category_id: _,
                                                    type_id: type_id,
                                                    quantity: _,
                                                    probability: _
                                                  } ->
        {type_id, Map.get(orders.prices[type_id], key)}
      end)
    end
  end

  def calc_profit(f, prices) do
    materials_total = calc_materials_price(f, prices.materials)
    products_total = calc_products_price(f, prices.products)

    if products_total == nil || materials_total == nil do
      nil
    else
      products_total - materials_total
    end
  end

  def get_systems_with_indices(query) do
    System.Query.get_systems_for_reactions()
    |> Enum.filter(fn x -> String.contains?(String.downcase(x.name), String.downcase(query)) end)
  end

  defp calc_materials_price(formula, prices) do
    materials = formula.bp.activities.reaction.materials

    if !Enum.all?(materials, fn m ->
         prices[m.type_id]
       end) do
      nil
    else
      List.foldl(materials, 0, fn m, acc ->
        prices[m.type_id] * m.quantity + acc
      end)
    end
  end

  defp calc_products_price(formula, prices) do
    products = formula.bp.activities.reaction.products

    if !Enum.all?(products, fn p ->
         prices[p.type_id]
       end) do
      nil
    else
      List.foldl(products, 0, fn p, acc ->
        prices[p.type_id] * p.quantity + acc
      end)
    end
  end

  defp handle_prepare({_id, bp}) do
    prepare_blueprint(bp)
  end

  defp prepare_blueprint(bp) do
    %{
      blueprint_type_id: bp.blueprint_type_id,
      max_production_limit: bp.max_production_limit,
      activities:
        Map.new(bp.activities, fn a ->
          {a.activity,
           %{
             time: a.time,
             materials:
               Enum.map(a.materials, fn m ->
                 %{
                   type_id: m.type_id,
                   quantity: m.quantity,
                   name: Type.Store.get_type_id_details(m.type_id).name,
                   category_id: Type.Store.get_type_id_details(m.type_id).category_id
                 }
               end)
               |> Enum.sort_by(& &1.name, :asc),
             products:
               Enum.map(a.products, fn p ->
                 %{
                   type_id: p.type_id,
                   quantity: p.quantity,
                   name: Type.Store.get_type_id_details(p.type_id).name,
                   probability: p.probability,
                   category_id: Type.Store.get_type_id_details(p.type_id).category_id
                 }
               end)
               |> Enum.sort_by(& &1.name, :asc)
           }}
        end)
    }
  end
end
