defmodule EveIndustrex.Repo.Migrations.CreatMaterial do
  use Ecto.Migration

  def change do
    create table("materials", primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :type_id, :bigint
      add :materials, :binary
    end
    create unique_index(:materials, [:type_id])
  end
end
