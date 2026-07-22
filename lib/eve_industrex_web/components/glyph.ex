defmodule EveIndustrexWeb.Glyph do
  use Phoenix.Component

  attr :name, :string, required: true
  attr :class, :string, default: "w-5 h-5"

  def glyph(assigns) do
    path =
      Path.join(:code.priv_dir(:eve_industrex), "static/icons/#{assigns.name}.svg")

    svg =
      case File.read(path) do
        {:ok, contents} ->
          contents
        _ -> "<svg></svg>"
      end

      assigns = assign(assigns, :svg, Phoenix.HTML.raw(svg))

      ~H"""
        <span class={@class}>
          <%= @svg %>
        </span>
      """
  end
end
