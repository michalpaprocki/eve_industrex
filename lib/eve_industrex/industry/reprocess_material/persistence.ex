defmodule EveIndustrex.Industry.ReprocessMaterial.Persistence do
  alias EveIndustrex.Industry.ReprocessMaterial
  alias EveIndustrex.Repo

  def upsert_all(reprocess_materials, return? \\ false) when is_list(reprocess_materials) do

   {normal, randomized} = Enum.split_with(reprocess_materials, fn r_mats -> Map.has_key?(r_mats, :materials) end)
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    rows_normal = Enum.flat_map(normal, fn r_mats ->
      Enum.map(r_mats.materials, fn mats ->
          %{
              source_type_id: r_mats.source_type_id,
              material_type_id: mats.material_type_id,
              quantity: mats.quantity,
              inserted_at: now,
              updated_at: now
            }

      end)
    end)
    rows_random =  Enum.flat_map(randomized, fn r_mats ->
      Enum.map(r_mats.randomized_materials, fn mats ->

          %{
            source_type_id: r_mats.source_type_id,
            material_type_id: mats.material_type_id,
            quantity_max: mats.quantity_max,
            quantity_min: mats.quantity_min,
            inserted_at: now,
            updated_at: now
          }

      end)
    end)

Enum.chunk_every(rows_normal ++ rows_random, 1000) |> Enum.map(fn chunk ->
  Repo.insert_all(
    ReprocessMaterial,
    chunk,
    on_conflict: {:replace, [:quantity, :quantity_max, :quantity_min, :updated_at]},
    conflict_target: [:source_type_id, :material_type_id],
    returning: return?
    )

end)
  end
end
