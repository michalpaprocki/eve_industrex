defmodule EveIndustrex.Infrastructure.ESI.Response do
  alias EveIndustrex.Infrastructure.ESI.Headers
  defstruct [:status, :body, :route, headers: %Headers{}]
end
