defmodule PermitPlaygroundWeb.RelationshipsLive do
  use PermitPlaygroundWeb, :live_view

  import PermitPlaygroundWeb.AuthorizationComponents

  alias PermitPlayground.Authorization
  alias PermitPlayground.Authorization.Relationship

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:relationships, Authorization.list_relationships())
      |> assign(:active_modal, nil)
      |> assign(:relationship_form, to_form(Relationship.changeset(%Relationship{}, %{})))

    {:ok, socket}
  end

  @impl true
  def handle_event("close_modal", _params, socket) do
    {:noreply,
     socket
     |> hide_modal()
     |> assign(:editing_relationship, nil)}
  end

  @impl true
  def handle_event("show_add_relationship_modal", _params, socket) do
    {:noreply,
     socket
     |> show_modal(:add_relationship)
     |> assign(:relationship_form, to_form(Relationship.changeset(%Relationship{}, %{})))
     |> assign(:editing_relationship, nil)}
  end

  @impl true
  def handle_event("add_relationship", %{"relationship" => relationship_params}, socket) do
    case Authorization.create_relationship(relationship_params) do
      {:ok, _relationship} ->
        socket =
          socket
          |> assign(:relationships, Authorization.list_relationships())
          |> hide_modal()
          |> assign(:relationship_form, to_form(Relationship.changeset(%Relationship{}, %{})))
          |> put_flash(:info, "Relationship '#{relationship_params["name"]}' added successfully")

        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, put_flash(socket, :error, format_errors(changeset))}
    end
  end

  @impl true
  def handle_event("remove_relationship", %{"relationship_id" => relationship_id}, socket) do
    with %Authorization.Relationship{} = relationship <-
           Authorization.get_relationship!(String.to_integer(relationship_id)),
         {:ok, %Authorization.Relationship{}} <- Authorization.delete_relationship(relationship) do
      {:noreply,
       socket
       |> assign(:relationships, Authorization.list_relationships())
       |> put_flash(:info, "Relationship '#{relationship.name}' removed successfully")}
    else
      _error ->
        {:noreply, put_flash(socket, :error, "Failed to remove relationship")}
    end
  end

  @impl true
  def handle_event(
        "show_edit_relationship_modal",
        %{"relationship_id" => relationship_id},
        socket
      ) do
    relationship = Authorization.get_relationship!(String.to_integer(relationship_id))
    relationship_form = to_form(Authorization.Relationship.changeset(relationship, %{}))

    {:noreply,
     socket
     |> show_modal(:edit_relationship)
     |> assign(:relationship_form, relationship_form)
     |> assign(:editing_relationship, relationship)}
  end

  @impl true
  def handle_event(
        "update_relationship",
        %{"relationship" => relationship_params, "relationship_id" => relationship_id},
        socket
      ) do
    with %Authorization.Relationship{} = relationship <-
           Authorization.get_relationship!(String.to_integer(relationship_id)),
         {:ok, %Authorization.Relationship{}} <-
           Authorization.update_relationship(relationship, relationship_params) do
      {:noreply,
       socket
       |> assign(:relationships, Authorization.list_relationships())
       |> hide_modal()
       |> assign(:editing_relationship, nil)
       |> put_flash(:info, "Relationship '#{relationship_params["name"]}' updated successfully")}
    else
      _error ->
        {:noreply, put_flash(socket, :error, "Failed to update relationship")}
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
