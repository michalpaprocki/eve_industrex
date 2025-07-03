defmodule EveIndustrex.Repo.Migrations.CreateCorpsOffersJoinTable do
  use Ecto.Migration

  def change do
    create table("corps_offers", primary_key: false) do
      add :corp_id, references(:npc_corps, column: :corp_id, type: :bigint), null: false

      add :offer_id, references(:lp_offers, column: :offer_id, type: :bigint), null: false
    end
    create unique_index(:corps_offers, [:corp_id, :offer_id])
  end
end
