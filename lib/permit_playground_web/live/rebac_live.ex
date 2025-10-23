defmodule PermitPlaygroundWeb.REBACLive do
  use PermitPlaygroundWeb, :live_view

  import PermitPlaygroundWeb.AuthorizationComponents

  alias PermitPlayground.Authorization
  alias PermitPlayground.PermitGenerator

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:matrix, Authorization.get_permission_matrix())
      |> assign(:active_modal, nil)
      |> assign(:selected_permission_context, nil)
      |> assign(:selected_conditions, %{})
      |> assign(:relationships, Authorization.list_relationships())

    {:ok, socket}
  end

  @impl true
  def handle_event(
        "toggle_rebac_permission",
        %{
          "relationship_id" => relationship_id,
          "action_id" => action_id,
          "resource_id" => resource_id
        },
        socket
      ) do
    relationship_id = String.to_integer(relationship_id)
    action_id = String.to_integer(action_id)
    resource_id = String.to_integer(resource_id)

    existing_permission = nil

    relationship = Authorization.get_relationship!(relationship_id)
    action = Authorization.get_action!(action_id)
    resource = Authorization.get_resource!(resource_id, [:resource_attributes])

    selected_conditions = %{}

    permission_context = %{
      relationship_id: relationship_id,
      action_id: action_id,
      resource_id: resource_id,
      relationship: relationship,
      action: action,
      resource: resource,
      existing_permission: existing_permission
    }

    socket =
      socket
      |> show_modal(:condition)
      |> assign(:selected_permission_context, permission_context)
      |> assign(:selected_conditions, selected_conditions)
      |> assign(
        :can_function_preview,
        PermitGenerator.generate_can_preview(
          :rebac,
          relationship,
          action,
          resource,
          selected_conditions
        )
      )

    {:noreply, socket}
  end

  @impl true
  def handle_event("hide_condition_modal", _params, socket) do
    {:noreply, hide_modal(socket)}
  end

  @impl true
  def handle_event("toggle_condition", %{"attribute" => attribute}, socket) do
    conditions = socket.assigns.selected_conditions

    updated_conditions =
      if Map.has_key?(conditions, attribute) do
        Map.delete(conditions, attribute)
      else
        Map.put(conditions, attribute, "")
      end

    ctx = socket.assigns.selected_permission_context

    updated_preview =
      PermitGenerator.generate_can_preview(
        :rebac,
        ctx.relationship,
        ctx.action,
        ctx.resource,
        updated_conditions
      )

    {:noreply,
     socket
     |> assign(:selected_conditions, updated_conditions)
     |> assign(:can_function_preview, updated_preview)}
  end

  @impl true
  def handle_event("update_condition", %{"attribute" => attribute, "value" => value}, socket) do
    conditions = socket.assigns.selected_conditions

    updated_conditions =
      if value == "" do
        Map.delete(conditions, attribute)
      else
        Map.put(conditions, attribute, value)
      end

    ctx = socket.assigns.selected_permission_context

    updated_preview =
      PermitGenerator.generate_can_preview(
        :rebac,
        ctx.relationship,
        ctx.action,
        ctx.resource,
        updated_conditions
      )

    {:noreply,
     socket
     |> assign(:selected_conditions, updated_conditions)
     |> assign(:can_function_preview, updated_preview)}
  end

  @impl true
  def handle_event("select_relationship", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("save_permission", _params, socket) do
    _ctx = socket.assigns.selected_permission_context
    conditions = socket.assigns.selected_conditions

    empty_conditions =
      conditions
      |> Enum.filter(fn {_key, value} -> String.trim(value) == "" end)
      |> Enum.map(fn {key, _value} -> key end)

    if empty_conditions != [] do
      {:noreply,
       put_flash(
         socket,
         :error,
         "Condition values cannot be empty for: #{Enum.join(empty_conditions, ", ")}"
       )}
    else
      socket =
        socket
        |> assign(:matrix, Authorization.get_permission_matrix())
        |> hide_modal()
        |> put_flash(:info, "Permission added successfully")

      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("delete_permission", _params, socket) do
    socket =
      socket
      |> assign(:matrix, Authorization.get_permission_matrix())
      |> hide_modal()
      |> assign(:selected_conditions, %{})
      |> put_flash(:info, "Permission deleted successfully")

    {:noreply, socket}
  end

  defp show_modal(socket, modal_name) do
    assign(socket, :active_modal, modal_name)
  end

  defp hide_modal(socket) do
    assign(socket, :active_modal, nil)
  end
end
