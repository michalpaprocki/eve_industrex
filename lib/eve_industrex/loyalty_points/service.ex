defmodule EveIndustrex.LoyaltyPoints.Service do
  alias EveIndustrex.Universe.Type
  alias EveIndustrex.LoyaltyPoints
  alias EveIndustrex.Industry
  # credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
  # credo:disable-for-this-file Credo.Check.Refactor.Nesting
  @moduledoc """
    This service constructs loyalty points view, updates prices based on user input and calculates offers' profitability.
  """
  def get_lp_shop_view(corp_id) do
    offer_ids = LoyaltyPoints.CorpOffer.Query.get_corp_offers(corp_id)

    offers =
      Enum.map(elem(offer_ids, 1), fn id ->
        EveIndustrex.LoyaltyPoints.LpOffer.Store.get_offer(id) |> elem(1)
      end)

    bps = get_offer_blueprints(offers)
    bps = Industry.Service.prepare_blueprints(bps)

    bp_by_type_id =
      Map.new(bps, fn bp ->
        {bp.blueprint_type_id, bp}
      end)

    Enum.map(offers, fn offer ->
      case Map.get(bp_by_type_id, offer.type_id) do
        nil ->
          offer
          |> put_in(
            [:category_id],
            Type.Store.get_type_id_details(offer.type_id).category_id
          )
          |> put_in(
            [:category],
            Type.Store.get_type_id_details(offer.type_id).category
          )
          |> put_in([:group], Type.Store.get_type_id_details(offer.type_id).group)

        bp ->
          Map.put(offer, :blueprint, bp)
          |> put_in(
            [:category_id],
            Type.Store.get_type_id_details(offer.type_id).category_id
          )
          |> put_in(
            [:category],
            Type.Store.get_type_id_details(offer.type_id).category
          )
          |> put_in([:group], Type.Store.get_type_id_details(offer.type_id).group)
      end
    end)
    |> Map.new(fn o ->
      {o.offer_id, o}
    end)
  end

  def enrich(offers, orders, order_type) do
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
          {id, Map.put(o, :isk_on_lp, maybe_calc_isk_per_lp(o))}
        end)
        |> Map.new(fn {id, o} ->
          {id, Map.put(o, :profit, calc_profit(o))}
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
          {id, Map.put(o, :isk_on_lp, maybe_calc_isk_per_lp(o))}
        end)
        |> Map.new(fn {id, o} ->
          {id, Map.put(o, :profit, calc_profit(o))}
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
          {id, Map.put(o, :isk_on_lp, maybe_calc_isk_per_lp(o))}
        end)
        |> Map.new(fn {id, o} ->
          {id, Map.put(o, :profit, calc_profit(o))}
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
          {id, Map.put(o, :isk_on_lp, maybe_calc_isk_per_lp(o))}
        end)
        |> Map.new(fn {id, o} ->
          {id, Map.put(o, :profit, calc_profit(o))}
        end)
    end
  end

  def update_offer(offer, type, price, type_id) do
    case type do
      :product ->
        offer = put_in(offer[:prices][:products][type_id], price)
        offer = put_in(offer[:isk_on_lp], maybe_calc_isk_per_lp(offer))
        put_in(offer, [:profit], calc_profit(offer))

      :req_item ->
        offer = put_in(offer[:prices][:req_items][type_id], price)
        offer = put_in(offer[:isk_on_lp], maybe_calc_isk_per_lp(offer))
        put_in(offer, [:profit], calc_profit(offer))

      :bp_materials ->
        offer = put_in(offer[:prices][:materials][type_id], price)
        offer = put_in(offer[:isk_on_lp], maybe_calc_isk_per_lp(offer))
        put_in(offer, [:profit], calc_profit(offer))
    end
  end

  defp maybe_calc_isk_per_lp(offer) do
    if offer.lp_cost == 0 do
      nil
    else
      perform_calculation(offer, true)
    end
  end

  defp calc_profit(offer) do
    perform_calculation(offer)
  end

  #  need a safer way to extract data from products
  defp perform_calculation(offer, lp? \\ false) do
    req_items_cost = calc_req_items_cost(offer.req_items, offer.prices.req_items)

    cond do
      req_items_cost == nil ->
        nil

      Map.has_key?(offer, :blueprint) and
          !String.contains?(String.downcase(offer.name), "crate") ->
        materials_cost = calc_materials_cost(offer, offer.prices.materials)

        product_price =
          offer.prices.products[hd(offer.blueprint.activities.manufacturing.products).type_id]

        if materials_cost == nil || product_price == nil do
          nil
        else
          if lp? do
            (product_price * offer.quantity *
               hd(offer.blueprint.activities.manufacturing.products).quantity -
               (offer.isk_cost + req_items_cost + materials_cost * offer.quantity)) /
              offer.lp_cost
          else
            product_price * offer.quantity *
              hd(offer.blueprint.activities.manufacturing.products).quantity -
              (offer.isk_cost + req_items_cost + materials_cost * offer.quantity)
          end
        end

      true ->
        if offer.prices.products[offer.type_id] == nil do
          nil
        else
          if lp? do
            (offer.prices.products[offer.type_id] * offer.quantity -
               (offer.isk_cost + req_items_cost)) / offer.lp_cost
          else
            offer.prices.products[offer.type_id] * offer.quantity -
              (offer.isk_cost + req_items_cost)
          end
        end
    end
  end

  defp calc_materials_cost(offer, prices) do
    materials = offer.blueprint.activities.manufacturing.materials

    if Enum.all?(materials, fn m ->
         prices[m.type_id]
       end) do
      List.foldl(materials, 0, fn m, acc ->
        prices[m.type_id] * m.quantity + acc
      end)
    else
      nil
    end
  end

  defp calc_req_items_cost(req_items, prices) do
    if Enum.all?(
         Enum.map(req_items, fn ri ->
           prices[ri.type_id]
         end)
       ) do
      List.foldl(req_items, 0, fn ri, acc ->
        prices[ri.type_id] * ri.quantity + acc
      end)
    else
      nil
    end
  end

  defp maybe_assign_materials_price(offer, orders, key) do
    if Map.has_key?(offer, :blueprint) do
      Industry.Service.assign_bp_materials_price(offer.blueprint, orders, key)
    else
      nil
    end
  end

  defp assign_product_price(offer, orders, key) do
    if String.contains?(String.downcase(offer.name), "blueprint") and
         !String.contains?(String.downcase(offer.name), "crate") do
      Industry.Service.assign_bp_product_price(offer.blueprint, orders, key)
    else
      Map.new([offer.type_id], fn type_id ->
        {type_id, Map.get(orders.prices[type_id], key)}
      end)
    end
  end

  def extract_offers_type_ids(offers) do
    offers_type_ids =
      Enum.uniq(
        Enum.map(offers, fn {_id, r} ->
          r.type_id
        end) ++
          Enum.map(offers, fn {_id, r} ->
            Enum.map(r.req_items, fn ri ->
              ri.type_id
            end)
          end)
      )

    mats_prod_type_ids =
      Enum.map(offers, fn {_id, o} ->
        if Map.has_key?(o, :blueprint) do
          Industry.Service.extract_bp_type_ids(o.blueprint)
        else
          nil
        end
      end)
      |> List.flatten()
      |> Enum.filter(fn x -> x != nil end)
      |> Enum.uniq()

    type_ids = Enum.uniq(mats_prod_type_ids ++ offers_type_ids) |> List.flatten()

    type_ids
  end

  defp get_offer_blueprints(offers) do
    Enum.filter(offers, fn o ->
      String.contains?(String.downcase(o.name), "blueprint")
    end)
    |> Enum.map(fn bp -> bp.type_id end)
    |> Industry.Blueprint.Query.get_blueprints_from_bp_ids()
  end
end
