defmodule EveIndustrex.Repo.Migrations.CreateBlueprintProduct do
  use Ecto.Migration

  def change do
    create table("blueprint_products", primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :amount, :bigint
      add :product_type_id, :bigint
      add :blueprint_activity_id, :binary_id
    end
  end
end
