defmodule EveIndustrex.Industry.Production.Helper do
  @moduledoc """
    Generic helper for Industry.
  """
  def extract_bp_type_ids(bp) do
    Enum.flat_map(bp.activities, fn {_k, a} ->
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
  end
end
