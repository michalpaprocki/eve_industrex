defmodule EveIndustrex.Repo.Migrations.CreateReprocessMaterials do
  use Ecto.Migration

  def change do
    create table(:reprocess_materials) do
      add :source_type_id, :bigint, null: false
      add :material_type_id, :bigint, null: false
      add :quantity, :integer
      add :quantity_max, :integer
      add :quantity_min, :integer
      timestamps()
    end
  create unique_index(
      :reprocess_materials,
      [:source_type_id, :material_type_id]
    )
  create index(
      :reprocess_materials,
      [:material_type_id]
    )
  end
end
