defmodule PermitPlaygroundWeb.ManageResourcesLive do
  use PermitPlaygroundWeb, :live_view

  import PermitPlaygroundWeb.AuthorizationComponents

  alias PermitPlayground.Authorization
  alias PermitPlayground.Authorization.Role
  alias PermitPlayground.Authorization.Action
  alias PermitPlayground.Authorization.Resource
  alias PermitPlayground.Authorization.ResourceAttribute
  alias PermitPlayground.Authorization.UserAttribute
  alias PermitPlayground.PermitGenerator

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:matrix, Authorization.get_permission_matrix())
      |> assign(:active_modal, nil)
      |> assign(:role_form, to_form(Role.changeset(%Role{}, %{})))
      |> assign(:action_form, to_form(Action.changeset(%Action{}, %{})))
      |> assign(
        :resource_form,
        to_form(Resource.changeset(%Resource{}, %{resource_attributes_list: ""}))
      )
      |> assign(:attribute_form, to_form(ResourceAttribute.changeset(%ResourceAttribute{}, %{})))
      |> assign(:user_attribute_form, to_form(UserAttribute.changeset(%UserAttribute{}, %{})))

    {:ok, socket}
  end

  @impl true
  def handle_event("close_modal", _params, socket) do
    {:noreply,
     socket
     |> hide_modal()
     |> assign(:editing_resource, nil)}
  end

  # Roles
  @impl true
  def handle_event("show_add_role_modal", _params, socket) do
    {:noreply, show_modal(socket, :add_role)}
  end

  @impl true
  def handle_event("add_role", %{"role" => role_params}, socket) do
    name = role_params["name"]

    case Authorization.create_role(%{name: name}) do
      {:ok, _role} ->
        socket =
          socket
          |> assign(:matrix, Authorization.get_permission_matrix())
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
    with %Authorization.Role{} = role <- Authorization.get_role!(String.to_integer(role_id)),
         {:ok, %Authorization.Role{}} <- Authorization.delete_role(role) do
      {:noreply,
       socket
       |> assign(:matrix, Authorization.get_permission_matrix())
       |> put_flash(:info, "Role '#{role.name}' removed successfully")}
    else
      _error ->
        {:noreply, put_flash(socket, :error, "Failed to remove role")}
    end
  end

  @impl true
  def handle_event("show_edit_role_modal", %{"role_id" => role_id}, socket) do
    role = Authorization.get_role!(String.to_integer(role_id))
    role_form = to_form(Authorization.Role.changeset(role, %{}))

    {:noreply,
     socket
     |> show_modal(:edit_role)
     |> assign(:role_form, role_form)}
  end

  @impl true
  def handle_event("update_role", %{"role" => role_params, "role_id" => role_id}, socket) do
    name = role_params["name"]

    with %Authorization.Role{} = role <- Authorization.get_role!(String.to_integer(role_id)),
         {:ok, %Authorization.Role{}} <- Authorization.update_role(role, %{name: name}) do
      {:noreply,
       socket
       |> assign(:matrix, Authorization.get_permission_matrix())
       |> hide_modal()
       |> put_flash(:info, "Role updated successfully")}
    else
      _error ->
        {:noreply, put_flash(socket, :error, "Failed to update role")}
    end
  end

  # Actions
  @impl true
  def handle_event("show_add_action_modal", _params, socket) do
    {:noreply, show_modal(socket, :add_action)}
  end

  @impl true
  def handle_event("add_action", %{"action" => action_params}, socket) do
    name = action_params["name"]

    case Authorization.create_action(%{name: name}) do
      {:ok, _action} ->
        socket =
          socket
          |> assign(:matrix, Authorization.get_permission_matrix())
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
    with %Authorization.Action{} = action <- Authorization.get_action!(String.to_integer(action_id)),
         {:ok, %Authorization.Action{}} <- Authorization.delete_action(action) do
      {:noreply,
       socket
       |> assign(:matrix, Authorization.get_permission_matrix())
       |> put_flash(:info, "Action '#{action.name}' removed successfully")}
    else
      _error ->
        {:noreply, put_flash(socket, :error, "Failed to remove action")}
    end
  end

  @impl true
  def handle_event("show_edit_action_modal", %{"action_id" => action_id}, socket) do
    action = Authorization.get_action!(String.to_integer(action_id))
    action_form = to_form(Authorization.Action.changeset(action, %{}))

    {:noreply,
     socket
     |> show_modal(:edit_action)
     |> assign(:action_form, action_form)}
  end

  @impl true
  def handle_event("update_action", %{"action" => action_params, "action_id" => action_id}, socket) do
    name = action_params["name"]

    with %Authorization.Action{} = action <- Authorization.get_action!(String.to_integer(action_id)),
         {:ok, %Authorization.Action{}} <- Authorization.update_action(action, %{name: name}) do
      {:noreply,
       socket
       |> assign(:matrix, Authorization.get_permission_matrix())
       |> hide_modal()
       |> put_flash(:info, "Action updated successfully")}
    else
      _error ->
        {:noreply, put_flash(socket, :error, "Failed to update action")}
    end
  end

  # User attributes
  @impl true
  def handle_event("show_add_user_attribute_modal", _params, socket) do
    {:noreply, show_modal(socket, :add_user_attribute)}
  end

  @impl true
  def handle_event("add_user_attribute", %{"user_attribute" => user_attribute_params}, socket) do
    name = user_attribute_params["name"]

    case Authorization.create_user_attribute(%{name: name}) do
      {:ok, _user_attribute} ->
        socket =
          socket
          |> assign(:matrix, Authorization.get_permission_matrix())
          |> hide_modal()
          |> assign(:user_attribute_form, to_form(UserAttribute.changeset(%UserAttribute{}, %{})))
          |> put_flash(:info, "User attribute '#{name}' added successfully")

        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, put_flash(socket, :error, format_errors(changeset))}
    end
  end

  @impl true
  def handle_event("remove_user_attribute", %{"user_attribute_id" => user_attribute_id}, socket) do
    with %Authorization.UserAttribute{} = user_attribute <- Authorization.get_user_attribute!(String.to_integer(user_attribute_id)),
         {:ok, %Authorization.UserAttribute{}} <- Authorization.delete_user_attribute(user_attribute) do
      {:noreply,
       socket
       |> assign(:matrix, Authorization.get_permission_matrix())
       |> put_flash(:info, "User attribute '#{user_attribute.name}' removed successfully")}
    else
      _error ->
        {:noreply, put_flash(socket, :error, "Failed to remove user attribute")}
    end
  end

  @impl true
  def handle_event(
        "show_edit_user_attribute_modal",
        %{"user_attribute_id" => user_attribute_id},
        socket
      ) do
    user_attribute = Authorization.get_user_attribute!(String.to_integer(user_attribute_id))
    user_attribute_form = to_form(Authorization.UserAttribute.changeset(user_attribute, %{}))

    {:noreply,
     socket
     |> show_modal(:edit_user_attribute)
     |> assign(:user_attribute_form, user_attribute_form)}
  end

  @impl true
  def handle_event("update_user_attribute", %{"user_attribute" => user_attribute_params, "user_attribute_id" => user_attribute_id}, socket) do
    name = user_attribute_params["name"]

    with %Authorization.UserAttribute{} = user_attribute <- Authorization.get_user_attribute!(String.to_integer(user_attribute_id)),
         {:ok, %Authorization.UserAttribute{}} <- Authorization.update_user_attribute(user_attribute, %{name: name}) do
      {:noreply,
       socket
       |> assign(:matrix, Authorization.get_permission_matrix())
       |> hide_modal()
       |> put_flash(:info, "User attribute updated successfully")}
    else
      _error ->
        {:noreply, put_flash(socket, :error, "Failed to update user attribute")}
    end
  end

  # Resources
  @impl true
  def handle_event("show_add_resource_modal", _params, socket) do
    {:noreply, show_modal(socket, :add_resource)}
  end

  @impl true
  def handle_event("add_resource", %{"resource" => resource_params}, socket) do
    case Authorization.create_resource(resource_params) do
      {:ok, _resource} ->
        socket =
          socket
          |> assign(:matrix, Authorization.get_permission_matrix())
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
    with %Authorization.Resource{} = resource <- Authorization.get_resource!(String.to_integer(resource_id), [:resource_attributes]),
         {:ok, %Authorization.Resource{}} <- Authorization.delete_resource(resource) do
      {:noreply,
       socket
       |> assign(:matrix, Authorization.get_permission_matrix())
       |> put_flash(:info, "Resource '#{resource.name}' removed successfully")}
    else
      _error ->
        {:noreply, put_flash(socket, :error, "Failed to remove resource")}
    end
  end

  @impl true
  def handle_event("show_edit_resource_modal", %{"resource_id" => resource_id}, socket) do
    resource = Authorization.get_resource!(String.to_integer(resource_id), [:resource_attributes])

    # Create a changeset with the resource data including preloaded attributes
    resource_with_empty_list = %{resource | resource_attributes_list: ""}
    changeset = Authorization.Resource.changeset(resource_with_empty_list, %{})

    # Create form with the resource data (including preloaded attributes) as the source
    resource_form = to_form(changeset, as: "resource")

    {:noreply,
     socket
     |> show_modal(:edit_resource)
     |> assign(:resource_form, resource_form)
     |> assign(:editing_resource, resource)}
  end

  @impl true
  def handle_event("update_resource", %{"resource" => resource_params, "resource_id" => resource_id}, socket) do
    resource_id_int = String.to_integer(resource_id)

    with %Authorization.Resource{} = resource <- Authorization.get_resource!(resource_id_int, [:resource_attributes]),
         {:ok, %Authorization.Resource{}} <- Authorization.update_resource(resource, resource_params) do

      # Refresh the matrix to show updated resource with new attributes
      updated_matrix = Authorization.get_permission_matrix()

      {:noreply,
       socket
       |> assign(:matrix, updated_matrix)
       |> hide_modal()
       |> assign(:editing_resource, nil)
       |> put_flash(:info, "Resource '#{resource_params["name"]}' updated successfully")}
    else
      _error ->
        {:noreply, put_flash(socket, :error, "Failed to update resource")}
    end
  end

  @impl true
  def handle_event("remove_attribute", %{"attribute_id" => attribute_id}, socket) do
    with %Authorization.ResourceAttribute{} = attribute <- Authorization.get_resource_attribute!(String.to_integer(attribute_id)),
         {:ok, %Authorization.ResourceAttribute{}} <- Authorization.delete_resource_attribute(attribute) do

      # Refresh the editing_resource with updated attributes if we're editing a resource
      updated_editing_resource =
        if socket.assigns.editing_resource && socket.assigns.editing_resource.id == attribute.resource_id do
          Authorization.get_resource!(attribute.resource_id, [:resource_attributes])
        else
          socket.assigns.editing_resource
        end

      {:noreply,
       socket
       |> assign(:matrix, Authorization.get_permission_matrix())
       |> assign(:editing_resource, updated_editing_resource)
       |> put_flash(:info, "Attribute '#{attribute.name}' removed successfully")}
    else
      _error ->
        {:noreply, put_flash(socket, :error, "Failed to remove attribute")}
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
