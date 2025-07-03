defmodule EveIndustrex.Repo.Migrations.CreateLpReqItems do
  use Ecto.Migration

  def change do
    create table("lp_req_items", primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :quantity, :bigint
      add :type_id, references(:types, column: :type_id, type: :bigint)
      add :offer_id, references(:lp_offers, column: :offer_id, type: :bigint)
    end
    create unique_index(:lp_req_items, [:id])
  end
end
