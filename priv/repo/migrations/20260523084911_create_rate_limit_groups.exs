defmodule EveIndustrex.Repo.Migrations.CreateRateLimitGroups do
  use Ecto.Migration

  def change do
    create table(:rate_limit_groups) do
      add :name, :string, null: false
      add :limit_capacity, :integer
      add :window_seconds, :integer
      add :estimated_cost, :integer
      add :last_observed_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end
    create unique_index(:rate_limit_groups, [:name])
  end
end
