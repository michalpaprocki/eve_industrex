defmodule EveIndustrex.Error do
  @type t :: %{
    type: atom(),
    reason: any(),
    context: map()
  }

  def new(type, reason, context \\ %{}) do
    %{type: type, reason: reason, context: context}
  end
end
