defmodule EveIndustrex.LoyaltyPoints.Helper do
  alias EveIndustrex.Industry

  @moduledoc """
    Small generic helper for LP.
  """
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
          Industry.Production.Helper.extract_bp_type_ids(o.blueprint)
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
end
