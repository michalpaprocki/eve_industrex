defmodule EveIndustrex.Repo.Migrations.AlterSystemDropStationsArray do
  use Ecto.Migration

  def change do
    alter table(:systems) do
      remove :stations
    end
  end
end
