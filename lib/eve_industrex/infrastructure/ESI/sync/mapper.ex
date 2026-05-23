defmodule EveIndustrex.Infrastructure.ESI.Sync.Mapper do

  def to_resource_type(resource_name) do
    %{
      name: resource_name,
      inserted_at: DateTime.utc_now() |> DateTime.truncate(:second),
      updated_at: DateTime.utc_now() |> DateTime.truncate(:second)
    }
  end

end
