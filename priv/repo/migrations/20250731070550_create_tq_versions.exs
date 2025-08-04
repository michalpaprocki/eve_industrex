defmodule EveIndustrex.Repo.Migrations.CreateTqVersions do
  use Ecto.Migration

  def change do
    create table("tq_versions", primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :version, :string
      timestamps()
    end
  end
end
