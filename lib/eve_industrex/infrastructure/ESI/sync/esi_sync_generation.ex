defmodule EveIndustrex.Infrastructure.ESI.Sync.EsiSyncGeneration do
   alias EveIndustrex.Infrastructure.ESI.Sync.EsiSyncGenerationPage
   alias EveIndustrex.Infrastructure.ESI.Sync.{EsiSyncStrategy}
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key {:id, :id, autogenerate: true}
  schema "esi_sync_generations" do
    belongs_to :esi_sync_strategy, EsiSyncStrategy
    field :priority, :integer
    field :generation, :integer, default: 0
    field :started_at, :utc_datetime
    field :finished_at, :utc_datetime
    field :duration_ms, :integer
    field :target_id, :integer
    field :last_error, :string
    field :pages_total, :integer
    field :pages_completed, :integer, default: 0
    field :status, Ecto.Enum, values: [:running, :completed, :failed, :partial, :critical]
    has_many :generation_pages, EsiSyncGenerationPage, foreign_key: :esi_sync_generation_id
    timestamps(type: :utc_datetime)
  end
  def changeset(generation, attrs) do
    generation
    |> cast(attrs, [:priority, :generation, :pages_completed ,:pages_total,:started_at, :finished_at, :duration_ms, :target_id, :last_error, :status, :esi_sync_strategy_id])
  end
end
