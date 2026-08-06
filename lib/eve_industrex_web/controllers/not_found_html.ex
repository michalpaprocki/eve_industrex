defmodule EveIndustrexWeb.NotFoundHTML do
  @moduledoc """
  This module contains pages rendered by NotFOundController.

  See the `page_html` directory for all templates available.
  """
  use EveIndustrexWeb, :html

  embed_templates "/not_found_html/*"
end
