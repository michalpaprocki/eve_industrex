defmodule EveIndustrex.Repo.Migrations.CreateNpcCorp do
  use Ecto.Migration

  def change do
    create table("npc_corps", primary_key: false) do
      add :name, :string
      add :description, :text
      add :corp_id, :bigint, primary_key: true
      timestamps()
    end

    create unique_index(:npc_corps, [:corp_id])
  end
end
