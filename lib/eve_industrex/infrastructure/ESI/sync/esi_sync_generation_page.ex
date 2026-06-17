defmodule EveIndustrex.Infrastructure.ESI.Sync.EsiSyncGenerationPage do
  alias EveIndustrex.Infrastructure.ESI.Sync.EsiSyncGeneration
  import Ecto.Changeset
  use Ecto.Schema
  @primary_key {:id, :id, autogenerate: true }
  schema "esi_sync_generation_pages" do
    field :page_number, :integer
    belongs_to :generation, EsiSyncGeneration, foreign_key: :esi_sync_generation_id
    field :status, Ecto.Enum, values: [:rate_limited, :completed, :failed, :critical, :matched, :retryable]
    field :last_error, :string
    field :attempts, :integer

    timestamps(type: :utc_datetime)
  end

  def changeset(page, atttrs) do
    page
    |> cast(atttrs, [:esi_sync_generation_id, :page_number, :last_error, :attempts, :status])

  end
end
