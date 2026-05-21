defmodule EveIndustrex.Repo.Migrations.CreateActivityProduct do
  use Ecto.Migration

  def change do
    create table(:blueprint_activity_products) do
      add :blueprint_type_id, :integer, null: false
      add :quantity, :integer, null: false
      add :type_id, :bigint, null: false
      add :probability, :float
      add :activity_type, :string, null: false
      timestamps()
    end

    create index(
             :blueprint_activity_products,
             [:type_id]
           )

    create unique_index(
             :blueprint_activity_products,
             [:blueprint_type_id, :activity_type, :type_id]
           )
  end

end
