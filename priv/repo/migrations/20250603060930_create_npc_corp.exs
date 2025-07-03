defmodule EveIndustrex.Repo.Migrations.CreateNpcCorp do
  use Ecto.Migration

  def change do
    create table("npc_corps", primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :corp_id, :bigint
    end

    create unique_index(:npc_corps, [:corp_id])
  end
end
