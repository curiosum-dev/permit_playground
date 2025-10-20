defmodule PermitPlaygroundWeb.AuthorizationComponents do
  @moduledoc false
  use Phoenix.Component

  import PermitPlaygroundWeb.CoreComponents

  @doc """
  Renders the management section for Roles, Actions, User attributes and Resources.

  ## Examples

      <.management_section matrix={@matrix} />
  """
  attr :matrix, :map, required: true

  def management_section(assigns) do
    ~H"""
    <div class="mb-8 bg-white shadow rounded-lg p-6">
      <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
        <.entity_list
          title="Roles"
          items={@matrix.roles}
          add_event="show_add_role_modal"
          edit_event="show_edit_role_modal"
          remove_event="remove_role"
          id_key="role_id"
        />

        <.entity_list
          title="Actions"
          items={@matrix.actions}
          add_event="show_add_action_modal"
          edit_event="show_edit_action_modal"
          remove_event="remove_action"
          id_key="action_id"
        />

        <.entity_list
          title="User Attributes"
          items={@matrix.user_attributes}
          add_event="show_add_user_attribute_modal"
          edit_event="show_edit_user_attribute_modal"
          remove_event="remove_user_attribute"
          id_key="user_attribute_id"
        />

        <.resource_list resources={@matrix.resources} />
      </div>
    </div>
    """
  end

  @doc """
  Renders a list of entities (roles or actions).
  """
  attr :title, :string, required: true
  attr :items, :list, required: true
  attr :add_event, :string, required: true
  attr :edit_event, :string, required: true
  attr :remove_event, :string, required: true
  attr :id_key, :string, required: true

  def entity_list(assigns) do
    ~H"""
    <div class="border border-gray-200 rounded-lg p-4 flex flex-col h-80">
      <div class="flex items-center justify-between mb-3 flex-shrink-0">
        <h3 class="text-md font-semibold text-gray-800">{@title}</h3>
        <button
          phx-click={@add_event}
          class="inline-flex items-center px-3 py-1 border border-transparent text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700 cursor-pointer"
        >
          <.icon name="hero-plus" class="w-4 h-4 mr-1" /> Add
        </button>
      </div>
      <div class="space-y-2 overflow-y-auto flex-1">
        <%= for item <- @items do %>
          <div class="flex items-center justify-between bg-gray-50 px-3 py-2 rounded">
            <div class="flex-1">
              <div class="text-sm font-medium text-gray-700">
                {":" <> item.name}
              </div>
            </div>
            <div class="flex items-center gap-2">
              <button
                phx-click={@edit_event}
                phx-value-role_id={if @id_key == "role_id", do: item.id}
                phx-value-action_id={if @id_key == "action_id", do: item.id}
                phx-value-user_attribute_id={if @id_key == "user_attribute_id", do: item.id}
                class="text-gray-600 hover:text-gray-800 cursor-pointer"
                title="Edit"
              >
                <.icon name="hero-pencil-square" class="w-4 h-4" />
              </button>
              <button
                phx-click={@remove_event}
                phx-value-role_id={if @id_key == "role_id", do: item.id}
                phx-value-action_id={if @id_key == "action_id", do: item.id}
                phx-value-user_attribute_id={if @id_key == "user_attribute_id", do: item.id}
                data-confirm={"Are you sure you want to delete this #{String.downcase(@title |> String.trim_trailing("s"))}?"}
                class="text-red-600 hover:text-red-800 cursor-pointer"
                title="Delete"
              >
                <.icon name="hero-trash" class="w-4 h-4" />
              </button>
            </div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  @doc """
  Renders a list of resources with their attributes.
  """
  attr :resources, :list, required: true

  def resource_list(assigns) do
    ~H"""
    <div class="border border-gray-200 rounded-lg p-4 flex flex-col h-80">
      <div class="flex items-center justify-between mb-3 flex-shrink-0">
        <h3 class="text-md font-semibold text-gray-800">Resources</h3>
        <button
          phx-click="show_add_resource_modal"
          class="inline-flex items-center px-3 py-1 border border-transparent text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700 cursor-pointer"
        >
          <.icon name="hero-plus" class="w-4 h-4 mr-1" /> Add
        </button>
      </div>
      <div class="space-y-2 overflow-y-auto flex-1">
        <%= for resource <- @resources do %>
          <div class="bg-gray-50 px-3 py-2 rounded">
            <div class="flex items-center justify-between mb-2">
              <div class="flex-1">
                <div class="text-sm font-medium text-gray-700">{resource.name}</div>
              </div>
              <div class="flex items-center gap-2 ml-2">
                <button
                  phx-click="show_edit_resource_modal"
                  phx-value-resource_id={resource.id}
                  class="text-gray-600 hover:text-gray-800 cursor-pointer"
                  title="Edit"
                >
                  <.icon name="hero-pencil-square" class="w-4 h-4" />
                </button>
                <button
                  phx-click="remove_resource"
                  phx-value-resource_id={resource.id}
                  data-confirm="Are you sure you want to delete this resource?"
                  class="text-red-600 hover:text-red-800 cursor-pointer"
                  title="Delete"
                >
                  <.icon name="hero-trash" class="w-4 h-4" />
                </button>
              </div>
            </div>

            <div :if={resource.resource_attributes != []} class="ml-2 mt-2">
              <div class="flex flex-wrap gap-1">
                <%= for attribute <- resource.resource_attributes do %>
                  <span class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
                    {attribute.name}
                  </span>
                <% end %>
              </div>
            </div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  @doc """
  Renders a generic modal with customizable content.

  Use the inner_block slot to provide custom form fields.
  """
  attr :show, :boolean, required: true
  attr :title, :string, required: true
  attr :form, :any, required: true
  attr :submit_event, :string, required: true
  attr :cancel_event, :string, required: true
  attr :submit_label, :string, default: "Save"

  slot :inner_block, required: true

  def modal(assigns) do
    ~H"""
    <div :if={@show}>
      <div class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
        <div class="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white">
          <div class="mt-3">
            <h3 class="text-lg font-medium text-gray-900 mb-4">{@title}</h3>
            <.form for={@form} phx-submit={@submit_event}>
              {render_slot(@inner_block)}

              <div class="flex justify-end space-x-3 mt-4">
                <button
                  type="button"
                  phx-click={@cancel_event}
                  class="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-200 rounded-md hover:bg-gray-300 cursor-pointer"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  class="px-4 py-2 text-sm font-medium text-white bg-blue-600 rounded-md hover:bg-blue-700 cursor-pointer"
                >
                  {@submit_label}
                </button>
              </div>
            </.form>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Renders the permissions matrix section.
  """
  attr :matrix, :map, required: true

  def permissions_section(assigns) do
    ~H"""
    <div class="bg-white shadow rounded-lg">
      <div class="px-6 py-4 border-b border-gray-200">
        <h2 class="text-lg font-medium text-gray-900">Permissions</h2>
        <p class="text-sm text-gray-500">
          Click to toggle permissions
        </p>
      </div>

      <div class="p-6 max-h-150 overflow-y-auto">
        <.permissions_empty_state :if={is_matrix_empty?(@matrix)} />
        <.permissions_matrix :if={!is_matrix_empty?(@matrix)} matrix={@matrix} />
      </div>
    </div>
    """
  end

  @doc """
  Renders empty state when matrix has no data.
  """
  def permissions_empty_state(assigns) do
    ~H"""
    <div class="text-center py-12">
      <.icon name="hero-exclamation-triangle" class="w-12 h-12 text-gray-400 mx-auto mb-4" />
      <p class="text-gray-500">
        Add at least one role, action, and resource to configure permissions
      </p>
    </div>
    """
  end

  @doc """
  Renders the permissions matrix with roles or user attributes, actions, and resources.
  """
  attr :matrix, :map, required: true

  def permissions_matrix(assigns) do
    ~H"""
    <div class="space-y-6">
      <%= if @matrix.type == :role do %>
        <%= for role <- @matrix.roles do %>
          <.entity_permissions_table entity={role} matrix={@matrix} entity_type={:role} />
        <% end %>
      <% else %>
        <%= for user_attribute <- @matrix.user_attributes do %>
          <.entity_permissions_table
            entity={user_attribute}
            matrix={@matrix}
            entity_type={:attribute}
          />
        <% end %>
      <% end %>
    </div>
    """
  end

  @doc """
  Renders a permissions table for a single entity (role or user attribute).
  """
  attr :entity, :map, required: true
  attr :matrix, :map, required: true
  attr :entity_type, :atom, required: true

  def entity_permissions_table(assigns) do
    assigns =
      assign(
        assigns,
        :title,
        if(assigns.entity_type == :role, do: "Role", else: "User attribute")
      )

    ~H"""
    <div class="border border-gray-200 rounded-lg p-4">
      <h3 class="text-md font-semibold text-gray-800 mb-4">
        {@title}: <span class="text-blue-600">{":" <> @entity.name}</span>
      </h3>

      <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-50">
            <tr>
              <th class="px-3 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Resource
              </th>
              <%= for action <- @matrix.actions do %>
                <th class="px-3 py-2 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">
                  {":" <> action.name}
                </th>
              <% end %>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            <%= for resource <- @matrix.resources do %>
              <tr>
                <td class="px-3 py-2 text-sm font-medium text-gray-900">
                  {resource.name}
                </td>
                <%= for action <- @matrix.actions do %>
                  <td class="px-3 py-2 text-center">
                    <.permission_toggle
                      entity_type={@entity_type}
                      entity_id={@entity.id}
                      action_id={action.id}
                      resource_id={resource.id}
                      matrix={@matrix}
                    />
                  </td>
                <% end %>
              </tr>
            <% end %>
          </tbody>
        </table>
      </div>
    </div>
    """
  end

  @doc """
  Renders a permission toggle button with condition indicator.
  """
  attr :entity_type, :atom, required: true, doc: "Either :role or :attribute"
  attr :entity_id, :integer, required: true, doc: "ID of the role or user attribute"
  attr :action_id, :integer, required: true
  attr :resource_id, :integer, required: true
  attr :matrix, :map, required: true

  def permission_toggle(assigns) do
    permission =
      get_permission(assigns.matrix, assigns.entity_id, assigns.action_id, assigns.resource_id)

    assigns =
      assigns
      |> assign(:permission, permission)
      |> assign(:has_permission, !!permission)
      |> assign(:has_conditions, has_conditions?(permission))

    ~H"""
    <div class="relative inline-block">
      <button
        phx-click="toggle_permission"
        phx-value-role_id={if @entity_type == :role, do: @entity_id}
        phx-value-user_attribute_id={if @entity_type == :attribute, do: @entity_id}
        phx-value-action_id={@action_id}
        phx-value-resource_id={@resource_id}
        class={[
          "w-8 h-8 rounded-full border-2 transition-colors duration-200 cursor-pointer",
          if(@has_permission,
            do: "bg-green-500 border-green-500 text-white hover:bg-green-600 hover:border-green-600",
            else: "bg-white border-gray-300 text-gray-300 hover:border-gray-400 hover:text-gray-400"
          )
        ]}
      >
        <.icon :if={@has_permission} name="hero-check" class="w-5 h-5 font-bold" />
        <.icon :if={!@has_permission} name="hero-x-mark" class="w-5 h-5 font-bold" />
      </button>
      <span
        :if={@has_conditions}
        class="absolute -top-1 -right-1 w-3 h-3 bg-blue-500 rounded-full border-2 border-white"
      >
      </span>
    </div>
    """
  end

  defp get_permission(matrix, entity_id, action_id, resource_id) do
    permission_key = {entity_id, action_id, resource_id}
    Map.get(matrix.permissions, permission_key)
  end

  defp has_conditions?(nil), do: false

  defp has_conditions?(permission) do
    conditions = Map.get(permission, :conditions, %{})
    map_size(conditions) > 0
  end

  @doc """
  Renders the permission conditions modal.
  """
  attr :show, :boolean, required: true
  attr :permission_context, :any, required: true
  attr :selected_conditions, :map, required: true
  attr :can_function_preview, :string, required: true

  attr :include_user_attr?, :boolean, default: true

  def permission_conditions_modal(assigns) do
    ~H"""
    <div :if={@show}>
      <div class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
        <div class="relative top-10 mx-auto p-6 max-w-6xl shadow-xl rounded-xl bg-white">
          <h3 class="text-xl font-bold text-gray-900 mb-6">
            {if @permission_context.existing_permission, do: "Edit Permission", else: "Add Permission"}
          </h3>

          <.permission_context_badge permission_context={@permission_context} />

          <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
            <div class="lg:col-span-1">
              <div :if={Map.has_key?(@permission_context, :user_attribute)} class="mb-6">
                <label class="flex items-center space-x-2 bg-gray-50 p-4 rounded-lg border">
                  <input
                    type="checkbox"
                    checked={@include_user_attr?}
                    phx-click="toggle_include_user_attr"
                    class="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                  />
                  <span class="text-sm text-gray-700">Use pattern matched attr in rule</span>
                </label>
              </div>

              <div :if={@permission_context.resource.resource_attributes != []} class="mb-6">
                <.condition_help_text />
                <.condition_attributes_list
                  attributes={@permission_context.resource.resource_attributes}
                  selected_conditions={@selected_conditions}
                />
              </div>
            </div>

            <div class="lg:col-span-2">
              <.can_function_preview can_function_preview={@can_function_preview} />
            </div>
          </div>

          <.permission_modal_footer existing_permission={@permission_context.existing_permission} />
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Renders the permission context badge (role → action → resource).
  """
  attr :permission_context, :any, required: true

  def permission_context_badge(assigns) do
    ~H"""
    <div class="mb-6 p-4 bg-gradient-to-r from-blue-50 to-purple-50 rounded-lg border border-blue-100">
      <div class="flex items-center justify-center gap-2 text-sm">
        <span class="px-3 py-1 bg-white rounded-full font-medium text-blue-600">
          {":" <>
            if Map.has_key?(@permission_context, :role),
              do: @permission_context.role.name,
              else: @permission_context.user_attribute.name}
        </span>
        <span class="text-gray-400">→</span>
        <span class="px-3 py-1 bg-white rounded-full font-medium text-green-600">
          {":" <> @permission_context.action.name}
        </span>
        <span class="text-gray-400">→</span>
        <span class="px-3 py-1 bg-white rounded-full font-medium text-purple-600">
          {@permission_context.resource.name}
        </span>
      </div>
    </div>
    """
  end

  @doc """
  Renders help text for condition syntax.
  """
  def condition_help_text(assigns) do
    ~H"""
    <div class="mb-4">
      <p class="text-sm font-medium text-gray-700 mb-2">Apply conditions (optional):</p>
      <div class="text-xs text-gray-600 bg-blue-50 border border-blue-200 rounded-md p-3">
        <p class="font-medium mb-1">Enter conditions using Permit syntax:</p>
        <ul class="list-disc list-inside space-y-1 ml-2">
          <li phx-no-curly-interpolation>
            <code class="bg-white px-1 rounded">123</code> - Numbers
          </li>
          <li phx-no-curly-interpolation>
            <code class="bg-white px-1 rounded">published</code>
            or <code class="bg-white px-1 rounded">"published"</code>
            - Strings (quotes optional)
          </li>
          <li phx-no-curly-interpolation>
            <code class="bg-white px-1 rounded">{:&lt;=, 100}</code>
            - Comparisons (:&lt;=, :&gt;=, :&gt;, :&lt;, :!=)
          </li>
          <li phx-no-curly-interpolation>
            <code class="bg-white px-1 rounded">{:in, ["a", "b"]}</code> - List membership
          </li>
          <li phx-no-curly-interpolation>
            <code class="bg-white px-1 rounded">{:like, "%admin%"}</code>
            - Pattern matching (:like, :ilike)
          </li>
          <li>
            <code class="bg-white px-1 rounded">nil</code>, <code class="bg-white px-1 rounded">true</code>,
            <code class="bg-white px-1 rounded">false</code>
            - Special values
          </li>
        </ul>
      </div>
    </div>
    """
  end

  @doc """
  Renders the list of condition attributes with checkboxes and inputs.
  """
  attr :attributes, :list, required: true
  attr :selected_conditions, :map, required: true

  def condition_attributes_list(assigns) do
    ~H"""
    <div class="space-y-4">
      <%= for attribute <- @attributes do %>
        <.condition_attribute_item attribute={attribute} selected_conditions={@selected_conditions} />
      <% end %>
    </div>
    """
  end

  @doc """
  Renders a single condition attribute item with checkbox and input.
  """
  attr :attribute, :any, required: true
  attr :selected_conditions, :map, required: true

  def condition_attribute_item(assigns) do
    assigns =
      assign(
        assigns,
        :is_selected,
        Map.has_key?(assigns.selected_conditions, assigns.attribute.name)
      )

    ~H"""
    <div class={[
      "p-4 rounded-lg border-2 transition-all",
      if(@is_selected,
        do: "bg-blue-50 border-blue-500",
        else: "bg-gray-50 border-transparent hover:border-gray-300"
      )
    ]}>
      <label class="flex items-center gap-3 cursor-pointer mb-3">
        <input
          type="checkbox"
          phx-click="toggle_condition"
          phx-value-attribute={@attribute.name}
          checked={@is_selected}
          class="h-5 w-5 text-blue-600 rounded cursor-pointer"
        />
        <span class="text-sm font-medium text-gray-900">{@attribute.name}</span>
      </label>

      <div :if={@is_selected} class="ml-8">
        <.input
          type="text"
          name={"condition_#{@attribute.name}"}
          id={"condition_#{@attribute.name}"}
          value={@selected_conditions[@attribute.name] || ""}
          phx-blur="update_condition"
          phx-value-attribute={@attribute.name}
          required
        />
      </div>
    </div>
    """
  end

  @doc """
  Renders the footer buttons for the permission modal.
  """
  attr :existing_permission, :any, required: true

  def permission_modal_footer(assigns) do
    ~H"""
    <div class="flex justify-between items-center pt-4">
      <button
        :if={@existing_permission}
        type="button"
        phx-click="delete_permission"
        data-confirm="Are you sure you want to delete this permission?"
        class="px-6 py-2.5 text-sm font-medium text-white bg-red-600 rounded-lg hover:bg-red-700 cursor-pointer"
      >
        Delete
      </button>
      <div :if={!@existing_permission}></div>

      <div class="flex gap-3">
        <button
          type="button"
          phx-click="hide_condition_modal"
          class="px-6 py-2.5 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 cursor-pointer"
        >
          Cancel
        </button>
        <button
          type="button"
          phx-click="save_permission"
          class="px-6 py-2.5 text-sm font-medium text-white bg-blue-600 rounded-lg hover:bg-blue-700 cursor-pointer shadow-sm"
        >
          Save
        </button>
      </div>
    </div>
    """
  end

  # Helper functions
  defp is_matrix_empty?(matrix) do
    case matrix.type do
      :role ->
        Enum.empty?(matrix.roles) or Enum.empty?(matrix.actions) or Enum.empty?(matrix.resources)

      :attribute ->
        Enum.empty?(matrix.user_attributes) or Enum.empty?(matrix.actions) or
          Enum.empty?(matrix.resources)

      :management ->
        Enum.empty?(matrix.roles) or Enum.empty?(matrix.user_attributes) or
          Enum.empty?(matrix.actions) or Enum.empty?(matrix.resources)
    end
  end

  @doc """
  Renders the generated can/1 function preview.
  """
  attr :can_function_preview, :string, required: true

  def can_function_preview(assigns) do
    highlighted_code =
      Makeup.highlight_inner_html(
        assigns.can_function_preview,
        lexer: Makeup.Lexers.ElixirLexer
      )

    assigns = assign(assigns, :highlighted_code, highlighted_code)

    ~H"""
    <div class="bg-gray-50 rounded-lg p-4 h-full flex flex-col">
      <div class="flex items-center justify-between mb-3">
        <h4 class="text-lg font-semibold text-gray-900 flex items-center gap-2">
          <.icon name="hero-code-bracket" class="w-5 h-5 text-blue-600" /> Generated can/1
        </h4>
        <button
          type="button"
          class="flex items-center gap-2 px-4 py-2 text-sm font-medium text-blue-600 bg-blue-50 border border-blue-200 rounded-lg hover:bg-blue-100 hover:border-blue-300 focus:outline-none transition-all duration-200 cursor-pointer"
          data-copy-target="#code-content"
          phx-hook="CopyCode"
          id="copy-code-btn"
        >
          <.icon name="hero-clipboard" class="w-4 h-4" /> Copy
        </button>
      </div>
      <div class="bg-gray-900 rounded-lg p-4 overflow-x-auto flex-1 relative">
        <input
          type="text"
          id="code-content"
          value={assigns.can_function_preview}
          class="sr-only"
          readonly
        />
        <pre
          class="text-sm text-gray-100 font-mono whitespace-pre-wrap highlight"
          phx-no-curly-interpolation
        ><%= Phoenix.HTML.raw(@highlighted_code) %></pre>
      </div>
    </div>
    """
  end
end
