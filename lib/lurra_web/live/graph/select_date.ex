defmodule LurraWeb.Graph.SelectDateDialog do
  use Surface.LiveComponent

  alias Surface.Components.Form
  alias Surface.Components.Form.Label
  alias Surface.Components.Form.Field
  alias Surface.Components.Form.DateTimeLocalInput
  alias Surface.Components.Form.Submit

  prop from, :integer, required: true
  prop to, :integer, required: true
  prop timezone, :string, required: true


  def render(assigns) do
    ~F"""
    <div>
      <Form for={:dates} submit="apply" class="long-field">
        <Field name={:from}>
          <Label>From</Label>
          <DateTimeLocalInput value={Timex.Timezone.convert(div(@from,1000) |> Timex.from_unix(), @timezone) }/>
        </Field>
        <Field name={:to}>
          <Label>To</Label>
          <DateTimeLocalInput value={Timex.Timezone.convert(div(@to, 1000) |> Timex.from_unix(), @timezone) }/>
        </Field>
        <Submit label="Apply"/>
      </Form>
    </div>
    """
  end

  def handle_event("apply", %{"dates" => %{"from" => from, "to" => to}}, socket) do
    send(self(), {:time_window_updated, from, to})
    {:noreply, socket}
  end

end
