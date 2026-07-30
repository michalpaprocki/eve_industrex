defmodule EveIndustrex.Industry.Blueprint.Store do
  def get_blueprint(id) do
    case :ets.lookup(:blueprints, id) do
      [{id, bp}] ->
        {id, bp}

      [] ->
        []
    end
  end

  def get_all() do
    :ets.tab2list(:blueprints)
  end
end
