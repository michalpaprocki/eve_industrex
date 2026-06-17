defmodule EveIndustrex.LoyaltyPoints.Service do
  alias EveIndustrex.Universe.Type
  alias EveIndustrex.LoyaltyPoints
  alias EveIndustrex.Industry

  def get_lp_shop_view(corp_id) do
    offers = LoyaltyPoints.CorpOffer.Query.get_corp_offers(corp_id)
    bps = prepare_offer_blueprints(offers)
    bp_by_type_id =
      Map.new(bps, fn bp ->
      {bp.blueprint_type_id, bp}
      end)
    Enum.map(offers, fn offer ->
      case Map.get(bp_by_type_id, offer.type.type_id) do
        nil ->
          offer
          |> put_in([:type, :category_id], Type.Store.get_type_id_details(offer.type.type_id).category_id)

        bp ->
          Map.put(offer, :blueprint, bp)
          |> put_in([:type, :category_id], Type.Store.get_type_id_details(offer.type.type_id).category_id)
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
          {id, Map.put(o, :prices, %{
            products: parse_product_price(o, orders, :min_sell),
            req_items: Map.new(o.req_items, fn %{name: _, category_id: _, type_id: type_id, quantity: _} ->
              {type_id, orders[type_id].min_sell}
            end),
            materials: maybe_parse_bp(o, orders, :min_sell),
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
          {id, Map.put(o, :prices, %{
            products: parse_product_price(o, orders, :max_buy),
            req_items: Map.new(o.req_items, fn %{name: _, category_id: _, type_id: type_id, quantity: _} ->
              {type_id, orders[type_id].max_buy}
            end),
            materials: maybe_parse_bp(o, orders, :max_buy),
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
          {id, Map.put(o, :prices, %{
            products: parse_product_price(o, orders, :max_buy),
            req_items: Map.new(o.req_items, fn %{name: _, category_id: _, type_id: type_id, quantity: _} ->
              {type_id, orders[type_id].min_sell}
            end),
            materials: maybe_parse_bp(o, orders, :min_sell),
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
          {id, Map.put(o, :prices, %{
            products: parse_product_price(o, orders, :min_sell),
            req_items: Map.new(o.req_items, fn %{name: _, category_id: _, type_id: type_id, quantity: _} ->
              {type_id, orders[type_id].max_buy}
            end),
            materials: maybe_parse_bp(o, orders, :max_buy),
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
        put_in(offer[:isk_on_lp], maybe_calc_isk_per_lp(offer))
      :req_item ->
        offer = put_in(offer[:prices][:req_items][type_id], price)
        put_in(offer[:isk_on_lp], maybe_calc_isk_per_lp(offer))
      :bp_materials ->
        offer = put_in(offer[:prices][:materials][type_id], price)
        put_in(offer[:isk_on_lp], maybe_calc_isk_per_lp(offer))
    end
  end
  defp maybe_calc_isk_per_lp(offer) do
   if  offer.lp_cost == 0 do
     nil
   else
    perform_calculation(offer, true)
   end
  end
  defp calc_profit(offer) do

      perform_calculation(offer)

  end
  defp perform_calculation(offer, lp? \\ false) do
    req_items_cost = calc_req_items_cost(offer.req_items, offer.prices.req_items)

    cond do
      req_items_cost == nil ->
        nil
      Map.has_key?(offer, :blueprint) and !String.contains?(String.downcase(offer.type.name), "crate") ->
        materials_cost = calc_materials_cost(offer, offer.prices.materials)
        product_price = offer.prices.products[hd(Enum.find(offer.blueprint.activities, fn a -> a.activity == :manufacturing end).products).type_id]

        if materials_cost == nil || product_price == nil do
          nil
        else
            if lp? do
              ((product_price * offer.quantity) - (offer.isk_cost + req_items_cost + materials_cost)) / offer.lp_cost
            else
               ((product_price * offer.quantity) - (offer.isk_cost + req_items_cost + materials_cost))
            end

        end
      true ->
        if offer.prices.products[offer.type.type_id] == nil do
          nil
        else
          if lp? do
            ((offer.prices.products[offer.type.type_id] * offer.quantity) - (offer.isk_cost + req_items_cost) ) / offer.lp_cost
          else
            ((offer.prices.products[offer.type.type_id] * offer.quantity) - (offer.isk_cost + req_items_cost) )
          end

        end
    end
  end
  defp calc_materials_cost(offer, prices) do
    materials = Enum.find(offer.blueprint.activities, fn a -> a.activity == :manufacturing end).materials
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
  defp calc_req_items_cost(req_items, prices) do

   if !Enum.all?(Enum.map(req_items, fn ri ->
    prices[ri.type_id]
   end)) do
     nil
   else
    List.foldl(req_items, 0, fn ri, acc ->
      prices[ri.type_id] * ri.quantity + acc
    end)
  end
  end
  defp maybe_parse_bp(offer, orders, key) do
     if Map.has_key?(offer, :blueprint) do
      Map.new(Enum.find(offer.blueprint.activities, fn a -> a.activity == :manufacturing end).materials, fn %{name: _, category_id: _, type_id: type_id, quantity: _} ->
        {type_id, Map.get(orders[type_id], key)}
      end)
     else
      nil
     end
  end
  defp parse_product_price(offer, orders, key) do
    if String.contains?(String.downcase(offer.type.name), "blueprint") and !String.contains?(String.downcase(offer.type.name), "crate") do
      Map.new(Enum.find(offer.blueprint.activities, fn a -> a.activity == :manufacturing end).products, fn %{name: _, category_id: _, type_id: type_id, quantity: _, probability: _} ->
      {type_id, Map.get(orders[type_id], key)}
      end)
    else
      Map.new([offer.type.type_id], fn type_id ->
        {type_id,  Map.get(orders[type_id], key)}
      end)

    end
  end
  def extract_offers_type_ids(offers) do

     offers_type_ids =
      Enum.uniq(
        Enum.map(offers, fn {_id, r} ->
          r.type.type_id
        end)
      ++
        Enum.map(offers, fn {_id, r} ->
          Enum.map(r.req_items, fn ri ->
            ri.type_id
          end)
      end)
    )




    mats_prod_type_ids = Enum.map(offers, fn {_id, o} ->
      if Map.has_key?(o, :blueprint) do
         Enum.map(o.blueprint.activities, fn a ->
        [
          Enum.map(a.materials, fn m ->
            m.type_id
          end),
          Enum.map(a.products, fn p ->
            p.type_id
          end)
        ]
      end) |> List.flatten() |> List.flatten()
      else
        nil
      end
    end) |>  List.flatten() |> Enum.filter(fn x -> x != nil end) |> Enum.uniq()

    type_ids = Enum.uniq(mats_prod_type_ids ++ offers_type_ids) |> List.flatten()

    type_ids
  end

  defp get_offer_blueprints(offers) do

    Enum.filter(offers, fn o ->
          String.contains?(String.downcase(o.type.name), "blueprint")
    end)
    |> Enum.map(fn bp -> bp.type.type_id end)
    |> Industry.Blueprint.Query.get_blueprints_from_bp_ids()

  end
  defp prepare_offer_blueprints(offers) do
    bps = get_offer_blueprints(offers)
    Enum.map(bps, fn bp ->
      %{
        blueprint_type_id: bp.blueprint_type_id,
        max_production_limit: bp.max_production_limit,
        activities: Enum.map(bp.activities, fn a ->
          %{
            time: a.time,
            materials: Enum.map(a.materials, fn m ->
              %{
                type_id: m.type_id,
                quantity: m.quantity,
                name: Type.Store.get_type_id_details(m.type_id).name,
                category_id: Type.Store.get_type_id_details(m.type_id).category_id
              }
            end),
            products: Enum.map(a.products, fn p ->
              %{
              type_id: p.type_id,
              quantity: p.quantity,
              name: Type.Store.get_type_id_details(p.type_id).name,
              probability: p.probability,
              category_id: Type.Store.get_type_id_details(p.type_id).category_id
              }
            end),
            activity: a.activity
          }
        end)
      }
    end)

  end
end
