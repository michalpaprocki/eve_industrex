defmodule EveIndustrex.Repo.Migrations.CreateLpOffers do
  use Ecto.Migration

  def change do
    create table("lp_offers", primary_key: false) do
      add :id, :binary_id, foreign_key: true
      add :offer_id, :bigint
      add :quantity, :bigint
      add :type_id, :bigint
      add :lp_cost, :bigint
      add :isk_cost, :bigint
      add :req_items, {:array, :bigint}
    end
    create unique_index(:lp_offers, [:offer_id])
  end
end
