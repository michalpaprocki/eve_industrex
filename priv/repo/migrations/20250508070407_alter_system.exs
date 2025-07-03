defmodule EveIndustrex.Repo.Migrations.AlterSystem do
  use Ecto.Migration

  def change do
    alter table("systems") do
      add :security_status, :float
    end
  end
end
