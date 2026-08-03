defmodule EveIndustrex.Infrastructure.ESI.Response do
  alias EveIndustrex.Infrastructure.ESI.Headers
  @moduledoc false
  defstruct [:status, :body, :route, headers: %Headers{}]
end
