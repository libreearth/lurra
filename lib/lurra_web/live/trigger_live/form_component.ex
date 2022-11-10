defmodule LurraWeb.TriggerLive.FormComponent do
  use LurraWeb, :live_component

  alias Lurra.Triggers
  alias Lurra.Monitoring

  @impl true
  def update(%{trigger: trigger} = assigns, socket) do
    changeset = Triggers.change_trigger(trigger)
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:observers, list_observers())
     |> assign(:sensors, list_sensors(trigger.device_id))
     |> assign(:rules, list_rules())
     |> assign(:actions, list_actions())
     |> assign(:changeset, changeset)
     |> rule_assigns()}
  end

  @impl true
  def handle_event("validate", %{"trigger" => trigger_params}, socket) do
    changeset =
      socket.assigns.trigger
      |> Triggers.change_trigger(trigger_params |> Map.put("rule", build_rule(trigger_params)) |> Map.put("actions", build_actions(trigger_params)))
      |> Map.put(:action, :validate)

    {
      :noreply,
      assign(socket, :changeset, changeset)
      |> assign(:sensors, list_sensors(trigger_params["device_id"]))
      |> rule_assigns()
    }
  end

  def handle_event("save", %{"trigger" => trigger_params}, socket) do
    save_trigger(socket, socket.assigns.action, trigger_params)
  end

  def handle_event("add-action-row", _load, socket) do
    actions = actions_from_changeset(socket.assigns.changeset) ++ [%{"module" => List.first(socket.assigns.actions) |> elem(1) |> Atom.to_string()}]
    {
      :noreply,
      socket
      |> assign(:changeset, Ecto.Changeset.put_change(socket.assigns.changeset, :actions, actions |> Jason.encode!()))
    }
  end

  def handle_event("delete-action", %{"sensor" => row}, socket) do
    actions = actions_from_changeset(socket.assigns.changeset) |> List.delete_at(row |> String.to_integer())
    {
      :noreply,
      socket
      |> assign(:changeset, Ecto.Changeset.put_change(socket.assigns.changeset, :actions, actions |> Jason.encode!()))
    }
  end

  defp save_trigger(socket, :edit, trigger_params) do
    case Triggers.update_trigger(socket.assigns.trigger, trigger_params) do
      {:ok, _trigger} ->
        Lurra.Triggers.Server.update()
        {:noreply,
         socket
         |> put_flash(:info, "Trigger updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_trigger(socket, :new, trigger_params) do
    case Triggers.create_trigger(trigger_params) do
      {:ok, _trigger} ->
        Lurra.Triggers.Server.update()
        {:noreply,
         socket
         |> put_flash(:info, "Trigger created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp find_observer(device_id, observers), do: Enum.find(observers, fn observer -> observer.device_id == device_id end)

  defp list_observers(), do: Monitoring.list_observers() |> observers_to_options()

  defp observers_to_options(observer_list), do: Enum.map(observer_list, fn observer -> {observer.name, observer.device_id} end)

  defp list_sensors(nil), do: []
  defp list_sensors(""), do: []
  defp list_sensors(device_id) do
    case find_observer(device_id, Monitoring.list_observers()) do
      nil -> []
      observer -> Map.get(observer, :sensors, []) |> sensors_to_options()
    end
  end

  defp sensors_to_options(sensors_list), do: Enum.map(sensors_list, fn sensor -> {sensor.name, sensor.sensor_type} end)

  defp list_rules(), do: Lurra.Triggers.Rule.all() |> Enum.map(fn rule -> {apply(rule, :name, []), rule} end)

  defp rule_params(nil), do: []
  defp rule_params(%Ecto.Changeset{} = changeset), do: rule_params(Ecto.Changeset.get_field(changeset, :rule))
  defp rule_params(rule) when is_atom(rule), do: apply(rule, :params, [])
  defp rule_params(rule), do: apply(String.to_atom(rule |> Jason.decode!() |> Map.get("module")), :params, [])

  defp build_rule(params) do
    rule = params["rule_module"]
    if rule == "" do
      nil
    else
      pm = rule_params(String.to_atom(rule))

      for param <- pm, into: %{"module" => rule} do
        {param, Map.get(params, param)}
      end |> Jason.encode!()
    end
  end

  defp rule_assigns(socket) do
    rule =
      case extract_rule(socket) |> Jason.decode() do
        {:ok, decoded} -> decoded
        {:error, _} -> nil
      end
    if is_nil(rule) do
      socket
      |> assign(:rule_module, nil)
    else
      %{"module" => module} = rule
      params = rule_params(String.to_atom(module))
      socket |> assign(:rule_module, module) |> add_params(params, rule)
    end
  end

  defp extract_rule(socket) do
    case Ecto.Changeset.get_field(socket.assigns.changeset, :rule) do
      nil -> ""
      rule -> rule
    end
  end

  defp add_params(socket, [], _rule), do: socket
  defp add_params(socket, [param | rest_params], rule) do
    socket
    |> assign(String.to_atom(param), rule[param])
    |> add_params(rest_params, rule)
  end

  defp list_actions(), do: Lurra.Triggers.Action.all() |> Enum.map(fn action -> {apply(action, :name, []), action} end)

  defp actions_from_changeset(changeset) do
    case extract_actions(changeset) |> Jason.decode() do
      {:ok, extracted} -> extracted
      {:error, _} -> []
    end
  end

  defp extract_actions(changeset) do
    case Ecto.Changeset.get_field(changeset, :actions) do
      nil -> ""
      actions -> actions
    end
  end

  defp build_actions(params) do
    for i <- 0..20 do
      if params_have_action?(params, i) do
        to_action_map(params, i)
      else
        nil
      end
    end
    |> Enum.filter(& not is_nil(&1))
    |> Jason.encode!()
  end

  defp params_have_action?(params, i), do: Map.has_key?(params, "action_module_#{i}")


  defp to_action_map(params, i) do
    module = Map.get(params, "action_module_#{i}")
    action_params = action_params(String.to_atom(module))
    for param <- action_params, into: %{"module" => module} do
      {param, Map.get(params, "#{param}_#{i}")}
    end
  end

  defp action_params(module) when is_atom(module), do: apply(module, :params, [])
end
