defmodule PermitPlaygroundWeb.RBACLive do
  use PermitPlaygroundWeb, :live_view

  import PermitPlaygroundWeb.AuthorizationComponents

  alias PermitPlayground.Authorization
  alias PermitPlayground.Authorization.Role
  alias PermitPlayground.Authorization.Action
  alias PermitPlayground.Authorization.Resource
  alias PermitPlayground.Authorization.ResourceAttribute
  alias PermitPlayground.PermitGenerator

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:matrix, Authorization.get_permission_matrix())
      |> assign(:active_modal, nil)
      |> assign(:selected_resource, nil)
      |> assign(:selected_role, nil)
      |> assign(:selected_action, nil)
      |> assign(:selected_permission_context, nil)
      |> assign(:selected_conditions, %{})
      |> assign(:role_form, to_form(Role.changeset(%Role{}, %{})))
      |> assign(:action_form, to_form(Action.changeset(%Action{}, %{})))
      |> assign(
        :resource_form,
        to_form(Resource.changeset(%Resource{}, %{resource_attributes_list: ""}))
      )
      |> assign(:attribute_form, to_form(ResourceAttribute.changeset(%ResourceAttribute{}, %{})))

    {:ok, socket}
  end

  @impl true
  def handle_event(
        "toggle_permission",
        %{"role_id" => role_id, "action_id" => action_id, "resource_id" => resource_id},
        socket
      ) do
    role_id = String.to_integer(role_id)
    action_id = String.to_integer(action_id)
    resource_id = String.to_integer(resource_id)

    existing_permission =
      Authorization.get_permission_by_role_action_resource(role_id, action_id, resource_id)

    role = Authorization.get_role!(role_id)
    action = Authorization.get_action!(action_id)
    resource = Authorization.get_resource!(resource_id, [:resource_attributes])

    selected_conditions = if(existing_permission, do: existing_permission.conditions, else: %{})

    permission_context = %{
      role_id: role_id,
      action_id: action_id,
      resource_id: resource_id,
      role: role,
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
        PermitGenerator.generate_can_function_preview(role, action, resource, selected_conditions)
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
      PermitGenerator.generate_can_function_preview(
        ctx.role,
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
      PermitGenerator.generate_can_function_preview(
        ctx.role,
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
  def handle_event("save_permission", _params, socket) do
    ctx = socket.assigns.selected_permission_context
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
      result =
        if ctx.existing_permission do
          Authorization.update_permission(ctx.existing_permission, %{
            conditions: conditions
          })
        else
          Authorization.create_permission(%{
            role_id: ctx.role_id,
            action_id: ctx.action_id,
            resource_id: ctx.resource_id,
            conditions: conditions
          })
        end

      case result do
        {:ok, _permission} ->
          action = if ctx.existing_permission, do: "updated", else: "added"

          socket =
            socket
            |> assign(:matrix, Authorization.get_permission_matrix())
            |> hide_modal()
            |> assign(:selected_conditions, %{})
            |> put_flash(:info, "Permission #{action} successfully")

          {:noreply, socket}

        {:error, _changeset} ->
          {:noreply, put_flash(socket, :error, "Failed to save permission")}
      end
    end
  end

  @impl true
  def handle_event("delete_permission", _params, socket) do
    ctx = socket.assigns.selected_permission_context

    case Authorization.delete_permission(ctx.existing_permission) do
      {:ok, _permission} ->
        socket =
          socket
          |> assign(:matrix, Authorization.get_permission_matrix())
          |> hide_modal()
          |> assign(:selected_conditions, %{})
          |> put_flash(:info, "Permission deleted successfully")

        {:noreply, socket}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to delete permission")}
    end
  end

  defp show_modal(socket, modal_name) do
    assign(socket, :active_modal, modal_name)
  end

  defp hide_modal(socket) do
    assign(socket, :active_modal, nil)
  end
end
