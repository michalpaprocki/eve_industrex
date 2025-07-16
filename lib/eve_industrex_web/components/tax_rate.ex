defmodule EveIndustrexWeb.Common.TaxRate do
  use EveIndustrexWeb, :live_component
    @form_types %{tax_rate: :float}
  def update(assigns, socket) do
    params = %{"tax_rate" => 0.00}
    changeset =
    {%{}, @form_types}
    |> Ecto.Changeset.cast(params, Map.keys(@form_types))

    {:ok, socket |> assign(assigns) |> assign(:form, to_form(changeset, as: :tax_form))}
  end

  def render(assigns) do
    ~H"""
    <div>
      <.form for={@form} id={"tax_form"} phx-target={@myself} phx-change={"validate_form"} class="p-4 flex gap-4">
            <div class={"flex gap-2 items-start"}>
              <.input class="" field={@form[:tax_rate]} value={@form[:tax_rate].value} label="Sales Tax Range:" type={"range"} min={0} max={7.5} step={0.01} maxlength={3} name="sales tax range" id={"sales_tax_range"} phx-debounce={1000}/>
              <.input class="" field={@form[:tax_rate]} value={@form[:tax_rate].value} label="Sales Tax Input:" type="number" min={0} max={7.5} step={0.01} maxlength={3} pattern="[0-9]" name="sales tax input" id={"sales_tax_input"} phx-debounce={1000}/>
            </div>
            <.button phx-disable-with="Saving..." disabled={true} class={"hidden"}>
                  submit
            </.button>
        </.form>
      </div>
    """
  end

  def handle_event("validate_form", %{"_target" => ["sales tax range"],"sales tax range" => tax} = _params, socket) do

    changeset = validate_input(tax, socket.assigns.form)
      if length(changeset.errors) == 0 do
        send(self(), {:new_tax_rate, changeset.changes.tax_rate})

      end
    {:noreply, socket |> assign(:form, to_form(changeset, as: :tax_form))}
  end
  def handle_event("validate_form", %{"_target" => ["sales tax input"],"sales tax input" => tax} = _params, socket) do

    changeset = validate_input(tax, socket.assigns.form)
      if length(changeset.errors) == 0 do
        send(self(), {:new_tax_rate, changeset.changes.tax_rate})

      end
    {:noreply, socket |> assign(:form, to_form(changeset, as: :tax_form))}
  end

  defp validate_input(tax_rate, form) do

      tax_float =
      cond do
        String.starts_with?(tax_rate, ".") ->
          "0"<>tax_rate
        String.at(tax_rate, 1) != "." ->
          String.split(tax_rate) |> List.insert_at(1, ".0") |> List.to_string()
        true ->
          tax_rate
      end

      params = %{tax_rate: tax_float, selected_corp: form[:selected_corp].value, selected_trade_hub: form[:selected_trade_hub].value}
      _changeset =
        {form, @form_types}
        |> Ecto.Changeset.cast(params, Map.keys(@form_types))
        |> Ecto.Changeset.validate_number(:tax_rate, less_than_or_equal_to: 7.50)
        |> Ecto.Changeset.validate_number(:tax_rate, greater_than_or_equal_to: 0.00)
        |> Map.put(:action, :validate)
  end
end
