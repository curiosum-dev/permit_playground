defmodule PermitPlaygroundWeb.RBACLive do
  use PermitPlaygroundWeb, :live_view

  import PermitPlaygroundWeb.RbacComponents

  alias PermitPlayground.RBAC
  alias PermitPlayground.RBAC.Role
  alias PermitPlayground.RBAC.Action
  alias PermitPlayground.RBAC.Resource
  alias PermitPlayground.RBAC.ResourceAttribute

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:matrix, RBAC.get_permission_matrix())
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
      RBAC.get_permission_by_role_action_resource(role_id, action_id, resource_id)

    role = RBAC.get_role!(role_id)
    action = RBAC.get_action!(action_id)
    resource = RBAC.get_resource!(resource_id, [:resource_attributes])

    socket =
      socket
      |> show_modal(:condition)
      |> assign(:selected_permission_context, %{
        role_id: role_id,
        action_id: action_id,
        resource_id: resource_id,
        role: role,
        action: action,
        resource: resource,
        existing_permission: existing_permission
      })
      |> assign(
        :selected_conditions,
        if(existing_permission, do: existing_permission.conditions, else: %{})
      )

    {:noreply, socket}
  end

  @impl true
  def handle_event("show_add_role_modal", _params, socket) do
    {:noreply, show_modal(socket, :add_role)}
  end

  @impl true
  def handle_event("close_modal", _params, socket) do
    {:noreply, hide_modal(socket)}
  end

  @impl true
  def handle_event("add_role", %{"role" => role_params}, socket) do
    name = role_params["name"]

    case RBAC.create_role(%{name: name}) do
      {:ok, _role} ->
        socket =
          socket
          |> assign(:matrix, RBAC.get_permission_matrix())
          |> hide_modal()
          |> assign(:role_form, to_form(Role.changeset(%Role{}, %{})))
          |> put_flash(:info, "Role '#{name}' added successfully")

        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, put_flash(socket, :error, format_errors(changeset))}
    end
  end

  @impl true
  def handle_event("remove_role", %{"role_id" => role_id}, socket) do
    role = RBAC.get_role!(String.to_integer(role_id))

    case RBAC.delete_role(role) do
      {:ok, _role} ->
        socket =
          socket
          |> assign(:matrix, RBAC.get_permission_matrix())
          |> put_flash(:info, "Role '#{role.name}' removed successfully")

        {:noreply, socket}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to remove role")}
    end
  end

  @impl true
  def handle_event("show_edit_role_modal", %{"role_id" => role_id}, socket) do
    role = RBAC.get_role!(String.to_integer(role_id))
    role_form = to_form(RBAC.Role.changeset(role, %{}))

    {:noreply,
     socket
     |> show_modal(:edit_role)
     |> assign(:selected_role, role)
     |> assign(:role_form, role_form)}
  end

  @impl true
  def handle_event("update_role", %{"role" => role_params}, socket) do
    name = role_params["name"]

    case RBAC.update_role(socket.assigns.selected_role, %{name: name}) do
      {:ok, _role} ->
        socket =
          socket
          |> assign(:matrix, RBAC.get_permission_matrix())
          |> hide_modal()
          |> put_flash(:info, "Role updated")

        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, put_flash(socket, :error, format_errors(changeset))}
    end
  end

  @impl true
  def handle_event("show_add_action_modal", _params, socket) do
    {:noreply, show_modal(socket, :add_action)}
  end

  @impl true
  def handle_event("add_action", %{"action" => action_params}, socket) do
    name = action_params["name"]

    case RBAC.create_action(%{name: name}) do
      {:ok, _action} ->
        socket =
          socket
          |> assign(:matrix, RBAC.get_permission_matrix())
          |> hide_modal()
          |> assign(:action_form, to_form(Action.changeset(%Action{}, %{})))
          |> put_flash(:info, "Action '#{name}' added successfully")

        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, put_flash(socket, :error, format_errors(changeset))}
    end
  end

  @impl true
  def handle_event("remove_action", %{"action_id" => action_id}, socket) do
    action = RBAC.get_action!(String.to_integer(action_id))

    case RBAC.delete_action(action) do
      {:ok, _action} ->
        socket =
          socket
          |> assign(:matrix, RBAC.get_permission_matrix())
          |> put_flash(:info, "Action '#{action.name}' removed successfully")

        {:noreply, socket}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to remove action")}
    end
  end

  @impl true
  def handle_event("show_edit_action_modal", %{"action_id" => action_id}, socket) do
    action = RBAC.get_action!(String.to_integer(action_id))
    action_form = to_form(RBAC.Action.changeset(action, %{}))

    {:noreply,
     socket
     |> show_modal(:edit_action)
     |> assign(:selected_action, action)
     |> assign(:action_form, action_form)}
  end

  @impl true
  def handle_event("update_action", %{"action" => action_params}, socket) do
    name = action_params["name"]

    case RBAC.update_action(socket.assigns.selected_action, %{name: name}) do
      {:ok, _action} ->
        socket =
          socket
          |> assign(:matrix, RBAC.get_permission_matrix())
          |> hide_modal()
          |> put_flash(:info, "Action updated")

        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, put_flash(socket, :error, format_errors(changeset))}
    end
  end

  @impl true
  def handle_event("show_add_resource_modal", _params, socket) do
    {:noreply, show_modal(socket, :add_resource)}
  end

  @impl true
  def handle_event("add_resource", %{"resource" => resource_params}, socket) do
    case RBAC.create_resource(resource_params) do
      {:ok, _resource} ->
        socket =
          socket
          |> assign(:matrix, RBAC.get_permission_matrix())
          |> hide_modal()
          |> assign(
            :resource_form,
            to_form(Resource.changeset(%Resource{}, %{resource_attributes_list: ""}))
          )
          |> put_flash(:info, "Resource '#{resource_params["name"]}' added successfully")

        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, put_flash(socket, :error, format_errors(changeset))}
    end
  end

  @impl true
  def handle_event("remove_resource", %{"resource_id" => resource_id}, socket) do
    resource = RBAC.get_resource!(String.to_integer(resource_id), [:resource_attributes])

    case RBAC.delete_resource(resource) do
      {:ok, _resource} ->
        socket =
          socket
          |> assign(:matrix, RBAC.get_permission_matrix())
          |> put_flash(:info, "Resource '#{resource.name}' removed successfully")

        {:noreply, socket}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to remove resource")}
    end
  end

  @impl true
  def handle_event("show_edit_resource_modal", %{"resource_id" => resource_id}, socket) do
    resource = RBAC.get_resource!(String.to_integer(resource_id), [:resource_attributes])

    resource_with_empty_list = %{resource | resource_attributes_list: ""}
    resource_form = to_form(RBAC.Resource.changeset(resource_with_empty_list, %{}))

    {:noreply,
     socket
     |> show_modal(:edit_resource)
     |> assign(:selected_resource, resource)
     |> assign(:resource_form, resource_form)}
  end

  @impl true
  def handle_event("update_resource", %{"resource" => resource_params}, socket) do
    case RBAC.update_resource(socket.assigns.selected_resource, resource_params) do
      {:ok, _resource} ->
        socket =
          socket
          |> assign(:matrix, RBAC.get_permission_matrix())
          |> hide_modal()
          |> put_flash(:info, "Resource '#{resource_params["name"]}' updated successfully")

        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, put_flash(socket, :error, format_errors(changeset))}
    end
  end

  @impl true
  def handle_event("show_add_attribute_modal", %{"resource_id" => resource_id}, socket) do
    resource = RBAC.get_resource!(String.to_integer(resource_id), [:resource_attributes])

    {:noreply, socket |> show_modal(:add_attribute) |> assign(:selected_resource, resource)}
  end

  @impl true
  def handle_event("add_attribute", %{"resource_attribute" => attr_params}, socket) do
    name = attr_params["name"]

    case RBAC.create_resource_attribute(%{
           name: name,
           resource_id: socket.assigns.selected_resource.id
         }) do
      {:ok, _attribute} ->
        socket =
          socket
          |> assign(:matrix, RBAC.get_permission_matrix())
          |> hide_modal()
          |> assign(:selected_resource, nil)
          |> assign(
            :attribute_form,
            to_form(ResourceAttribute.changeset(%ResourceAttribute{}, %{}))
          )
          |> put_flash(:info, "Attribute '#{name}' added successfully")

        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, put_flash(socket, :error, format_errors(changeset))}
    end
  end

  @impl true
  def handle_event("remove_attribute", %{"attribute_id" => attribute_id}, socket) do
    attribute = RBAC.get_resource_attribute!(String.to_integer(attribute_id))

    case RBAC.delete_resource_attribute(attribute) do
      {:ok, _attribute} ->
        selected_resource =
          if socket.assigns.selected_resource do
            RBAC.get_resource!(socket.assigns.selected_resource.id, [:resource_attributes])
          else
            nil
          end

        socket =
          socket
          |> assign(:matrix, RBAC.get_permission_matrix())
          |> assign(:selected_resource, selected_resource)
          |> put_flash(:info, "Attribute '#{attribute.name}' removed successfully")

        {:noreply, socket}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to remove attribute")}
    end
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

    {:noreply, assign(socket, :selected_conditions, updated_conditions)}
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

    {:noreply, assign(socket, :selected_conditions, updated_conditions)}
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
          RBAC.update_permission(ctx.existing_permission, %{
            conditions: conditions
          })
        else
          RBAC.create_permission(%{
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
            |> assign(:matrix, RBAC.get_permission_matrix())
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

    case RBAC.delete_permission(ctx.existing_permission) do
      {:ok, _permission} ->
        socket =
          socket
          |> assign(:matrix, RBAC.get_permission_matrix())
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

  defp format_errors(changeset) do
    changeset.errors
    |> Enum.map(fn {field, {message, _}} -> "#{field}: #{message}" end)
    |> Enum.join(", ")
  end
end
