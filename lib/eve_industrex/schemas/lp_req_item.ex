defmodule EveIndustrex.Schemas.LpReqItem do
  import Ecto.Changeset
  alias EveIndustrex.Schemas.{Type, LpOffer}
  use Ecto.Schema
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "lp_req_items" do
    field :quantity, :integer
    field :offer_id, :integer
    field :type_id, :integer
    belongs_to :type, Type, references: :type_id, define_field: false
    belongs_to :lp_offer, LpOffer, references: :offer_id, define_field: false
  end

  def changeset(lp_req_item, attrs) do
    lp_req_item
    |> cast(attrs, [:quantity, :type_id])
  end

end
