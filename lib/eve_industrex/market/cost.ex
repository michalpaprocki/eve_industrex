defmodule EveIndustrex.Market.Cost do
  alias EveIndustrex.Industry.Production.Helper
  alias EveIndustrex.Market.Calculator
  alias EveIndustrex.Market.{AveragePrice, MarketOrder}

  @moduledoc """
  Module responsible for enriching blueprints and offers with item prices.
  """
  def enrich_bps(formulas, orders, order_type) do
    # TO DO: placeholder logic, refactor when time avail for a more generic style

    case order_type do
      "sell" ->
        Map.new(formulas, fn {id, f} ->
          {id,
           Map.put(f, :prices, %{
             products: assign_bp_product_price(f, orders, :min_sell),
             materials: assign_bp_materials_price(f, orders, :min_sell)
           })}
        end)
        |> Map.new(fn {id, f} ->
          {id, Map.put(f, :profit, Calculator.calc_profit(f, f.prices))}
        end)

      "buy" ->
        Map.new(formulas, fn {id, f} ->
          {id,
           Map.put(f, :prices, %{
             products: assign_bp_product_price(f, orders, :max_buy),
             materials: assign_bp_materials_price(f, orders, :max_buy)
           })}
        end)
        |> Map.new(fn {id, f} ->
          {id, Map.put(f, :profit, Calculator.calc_profit(f, f.prices))}
        end)

      "buy_sell" ->
        Map.new(formulas, fn {id, f} ->
          {id,
           Map.put(f, :prices, %{
             products: assign_bp_product_price(f, orders, :min_sell),
             materials: assign_bp_materials_price(f, orders, :max_buy)
           })}
        end)
        |> Map.new(fn {id, f} ->
          {id, Map.put(f, :profit, Calculator.calc_profit(f, f.prices))}
        end)

      "sell_buy" ->
        Map.new(formulas, fn {id, f} ->
          {id,
           Map.put(f, :prices, %{
             products: assign_bp_product_price(f, orders, :max_buy),
             materials: assign_bp_materials_price(f, orders, :min_sell)
           })}
        end)
        |> Map.new(fn {id, f} ->
          {id, Map.put(f, :profit, Calculator.calc_profit(f, f.prices))}
        end)

      _ ->
        formulas
    end
    |> Map.new(fn {id, f} ->
      {id, Map.put(f, :adjusted_prices, assign_average_prices(f, orders))}
    end)
  end

  def enrich_offers(offers, orders, order_type) do
    case order_type do
      "sell" ->
        Map.new(offers, fn {id, o} ->
          {id,
           Map.put(o, :prices, %{
             products: assign_product_price(o, orders, :min_sell),
             req_items:
               Map.new(o.req_items, fn %{type_id: type_id, quantity: _} ->
                 {type_id, orders.prices[type_id].min_sell}
               end),
             materials: maybe_assign_materials_price(o, orders, :min_sell)
           })}
        end)
        |> Map.new(fn {id, o} ->
          {id, Map.put(o, :isk_on_lp, Calculator.maybe_calc_isk_per_lp(o))}
        end)
        |> Map.new(fn {id, o} ->
          {id, Map.put(o, :profit, Calculator.calc_profit(o))}
        end)

      "buy" ->
        Map.new(offers, fn {id, o} ->
          {id,
           Map.put(o, :prices, %{
             products: assign_product_price(o, orders, :max_buy),
             req_items:
               Map.new(o.req_items, fn %{name: _, category_id: _, type_id: type_id, quantity: _} ->
                 {type_id, orders.prices[type_id].max_buy}
               end),
             materials: maybe_assign_materials_price(o, orders, :max_buy)
           })}
        end)
        |> Map.new(fn {id, o} ->
          {id, Map.put(o, :isk_on_lp, Calculator.maybe_calc_isk_per_lp(o))}
        end)
        |> Map.new(fn {id, o} ->
          {id, Map.put(o, :profit, Calculator.calc_profit(o))}
        end)

      "sell_buy" ->
        Map.new(offers, fn {id, o} ->
          {id,
           Map.put(o, :prices, %{
             products: assign_product_price(o, orders, :max_buy),
             req_items:
               Map.new(o.req_items, fn %{name: _, category_id: _, type_id: type_id, quantity: _} ->
                 {type_id, orders.prices[type_id].min_sell}
               end),
             materials: maybe_assign_materials_price(o, orders, :min_sell)
           })}
        end)
        |> Map.new(fn {id, o} ->
          {id, Map.put(o, :isk_on_lp, Calculator.maybe_calc_isk_per_lp(o))}
        end)
        |> Map.new(fn {id, o} ->
          {id, Map.put(o, :profit, Calculator.calc_profit(o))}
        end)

      "buy_sell" ->
        Map.new(offers, fn {id, o} ->
          {id,
           Map.put(o, :prices, %{
             products: assign_product_price(o, orders, :min_sell),
             req_items:
               Map.new(o.req_items, fn %{name: _, category_id: _, type_id: type_id, quantity: _} ->
                 {type_id, orders.prices[type_id].max_buy}
               end),
             materials: maybe_assign_materials_price(o, orders, :max_buy)
           })}
        end)
        |> Map.new(fn {id, o} ->
          {id, Map.put(o, :isk_on_lp, Calculator.maybe_calc_isk_per_lp(o))}
        end)
        |> Map.new(fn {id, o} ->
          {id, Map.put(o, :profit, Calculator.calc_profit(o))}
        end)
    end
  end

  def update_blueprint_prices(bp, type, price, type_id) do
    case type do
      :product ->
        bp = put_in(bp[:prices][:products][type_id], price)
        put_in(bp, [:profit], Calculator.calc_profit(bp, bp.prices))

      :bp_materials ->
        bp = put_in(bp[:prices][:materials][type_id], price)
        put_in(bp, [:profit], Calculator.calc_profit(bp, bp.prices))
    end
  end

  def update_offer_prices(offer, type, price, type_id) do
    case type do
      :product ->
        offer = put_in(offer[:prices][:products][type_id], price)
        offer = put_in(offer[:isk_on_lp], Calculator.maybe_calc_isk_per_lp(offer))
        put_in(offer, [:profit], Calculator.calc_profit(offer))

      :req_item ->
        offer = put_in(offer[:prices][:req_items][type_id], price)
        offer = put_in(offer[:isk_on_lp], Calculator.maybe_calc_isk_per_lp(offer))
        put_in(offer, [:profit], Calculator.calc_profit(offer))

      :bp_materials ->
        offer = put_in(offer[:prices][:materials][type_id], price)
        offer = put_in(offer[:isk_on_lp], Calculator.maybe_calc_isk_per_lp(offer))
        put_in(offer, [:profit], Calculator.calc_profit(offer))
    end
  end

  def assign_average_prices(bp, orders) do
    types = Helper.extract_bp_type_ids(bp)

    Map.new(types, fn type_id ->
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

  def get_initial_prices_for_view(location_id, type_ids) do
    %{
      prices:
        Map.new(type_ids, fn type_id ->
          {type_id, MarketOrder.Store.get_ask_bid_from_hub(location_id, type_id)}
        end),
      adjusted_prices:
        Map.new(type_ids, fn type_id ->
          {type_id, AveragePrice.Store.get_average_price(type_id)}
        end)
    }
  end

  defp maybe_assign_materials_price(offer, orders, key) do
    if Map.has_key?(offer, :blueprint) do
      assign_bp_materials_price(offer.blueprint, orders, key)
    else
      nil
    end
  end

  defp assign_product_price(offer, orders, key) do
    if String.contains?(String.downcase(offer.name), "blueprint") and
         !String.contains?(String.downcase(offer.name), "crate") do
      assign_bp_product_price(offer.blueprint, orders, key)
    else
      Map.new([offer.type_id], fn type_id ->
        {type_id, Map.get(orders.prices[type_id], key)}
      end)
    end
  end
end
