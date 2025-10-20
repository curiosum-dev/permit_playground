defmodule PermitPlaygroundWeb.ABACLive do
  use PermitPlaygroundWeb, :live_view

  import PermitPlaygroundWeb.AuthorizationComponents

  alias PermitPlayground.Authorization
  alias PermitPlayground.PermitGenerator

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:matrix, Authorization.get_permission_matrix(:attribute))
      |> assign(:active_modal, nil)
      |> assign(:selected_permission_context, nil)
      |> assign(:selected_conditions, %{})
      |> assign(:include_user_attr?, true)

    {:ok, socket}
  end

  @impl true
  def handle_event(
        "toggle_permission",
        %{
          "user_attribute_id" => user_attribute_id,
          "action_id" => action_id,
          "resource_id" => resource_id
        },
        socket
      ) do
    user_attribute_id = String.to_integer(user_attribute_id)
    action_id = String.to_integer(action_id)
    resource_id = String.to_integer(resource_id)

    existing_permission =
      Authorization.get_permission_by_user_attribute_action_resource(
        user_attribute_id,
        action_id,
        resource_id
      )

    user_attribute = Authorization.get_user_attribute!(user_attribute_id)
    action = Authorization.get_action!(action_id)
    resource = Authorization.get_resource!(resource_id, [:resource_attributes])

    selected_conditions = if(existing_permission, do: existing_permission.conditions, else: %{})

    permission_context = %{
      user_attribute_id: user_attribute_id,
      action_id: action_id,
      resource_id: resource_id,
      user_attribute: user_attribute,
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
          user_attribute,
          action,
          resource,
          selected_conditions,
          %{include_user_attr?: socket.assigns.include_user_attr?}
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
        ctx.user_attribute,
        ctx.action,
        ctx.resource,
        updated_conditions,
        %{include_user_attr?: socket.assigns.include_user_attr?}
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
        ctx.user_attribute,
        ctx.action,
        ctx.resource,
        updated_conditions,
        %{include_user_attr?: socket.assigns.include_user_attr?}
      )

    {:noreply,
     socket
     |> assign(:selected_conditions, updated_conditions)
     |> assign(:can_function_preview, updated_preview)}
  end

  @impl true
  def handle_event("toggle_include_user_attr", _params, socket) do
    new_value = !socket.assigns.include_user_attr?

    ctx = socket.assigns.selected_permission_context

    updated_preview =
      if ctx do
        PermitGenerator.generate_can_preview(
          ctx.user_attribute,
          ctx.action,
          ctx.resource,
          socket.assigns.selected_conditions,
          %{include_user_attr?: new_value}
        )
      else
        socket.assigns.can_function_preview
      end

    {:noreply,
     socket
     |> assign(:include_user_attr?, new_value)
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
            user_attribute_id: ctx.user_attribute_id,
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
            |> assign(:matrix, Authorization.get_permission_matrix(:attribute))
            |> hide_modal()
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
          |> assign(:matrix, Authorization.get_permission_matrix(:attribute))
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
