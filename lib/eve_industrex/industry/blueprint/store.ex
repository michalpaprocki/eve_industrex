defmodule EveIndustrex.Industry.Blueprint.Store do
  def get_blueprint(id) do
    :ets.lookup(:blueprints, id)
  end
end
