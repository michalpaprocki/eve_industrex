defmodule EveIndustrex.Repo.Migrations.RemoveMaterialsBpProductTypesBlueprintProduct do
  use Ecto.Migration

  def change do
    drop table(:bp_product_types)
    drop table(:materials)
    drop table(:blueprint_products)

  end
end
