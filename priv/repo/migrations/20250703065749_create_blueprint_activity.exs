defmodule EveIndustrex.Repo.Migrations.CreateBlueprintActivity do
  use Ecto.Migration

  def change do
    create table("blueprint_activities", primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :activity_type, :string
      add :time, :bigint
      add :probability, :float
      add :quantity, :bigint
      add :blueprint_type_id, :bigint
    end
  end
end
