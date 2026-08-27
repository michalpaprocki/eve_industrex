defmodule EveIndustrex.Market.Calculator do
  @moduledoc """
    This calculator deals with offer and/or blueprint profitability.
  """
  # credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
  # credo:disable-for-this-file Credo.Check.Refactor.Nesting
  def calc_profit(f, prices) do
    materials_total = calc_materials_price(f, prices.materials)
    products_total = calc_products_price(f, prices.products)

    if products_total == nil || materials_total == nil do
      nil
    else
      products_total - materials_total
    end
  end

  defp calc_materials_price(formula, prices) do
    materials =
      cond do
        Map.has_key?(formula.activities, :reaction) ->
          formula.activities.reaction.materials

        Map.has_key?(formula.activities, :manufacturing) ->
          formula.activities.manufacturing.materials

        Map.has_key?(formula.activities, :invention) ->
          formula.activities.invention.materials
      end

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

  defp calc_products_price(formula, prices) do
    products =
      cond do
        Map.has_key?(formula.activities, :reaction) ->
          formula.activities.reaction.products

        Map.has_key?(formula.activities, :manufacturing) ->
          formula.activities.manufacturing.products

        Map.has_key?(formula.activities, :invention) ->
          formula.activities.invention.products
      end

    if Enum.all?(products, fn p ->
         prices[p.type_id]
       end) do
      List.foldl(products, 0, fn p, acc ->
        prices[p.type_id] * p.quantity + acc
      end)
    else
      nil
    end
  end

  def maybe_calc_isk_per_lp(offer) do
    if offer.lp_cost == 0 do
      nil
    else
      perform_calculation(offer, true)
    end
  end

  def calc_profit(offer) do
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

  def apply_fw_discount(job_cost, fw_upgrade_level) do
    case fw_upgrade_level do
      0 ->
        job_cost

      1 ->
        job_cost * 0.9

      2 ->
        job_cost * 0.8

      3 ->
        job_cost * 0.7

      4 ->
        job_cost * 0.6

      5 ->
        job_cost * 0.5
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
end
