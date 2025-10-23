defmodule PermitPlayground.PermitGenerator do
  @moduledoc """
  Generates Permit.Ecto permission code from stored permissions.
  """

  alias PermitPlayground.ConditionParser

  def generate_can_preview(type, role, action, resource, conditions \\ %{}, opts \\ %{}) do
    action_name = String.to_atom(action.name)
    resource_name = resource.name
    parsed_conditions = ConditionParser.parse_conditions(conditions)

    all_conditions = build_conditions(parsed_conditions, role, opts, type)
    function_head = build_function_head(role, type)

    permission_call =
      build_permission_call(action_name, resource_name, all_conditions, role, type)

    build_complete_function(function_head, permission_call)
  end

  defp build_conditions(parsed_conditions, role, opts, type) do
    if type == :abac and Map.get(opts, :include_user_attr?, true) do
      user_attr_var = "user_#{role.name}"
      user_attr_key = String.to_atom(role.name)
      Map.put(parsed_conditions, user_attr_key, user_attr_var)
    else
      parsed_conditions
    end
  end

  defp build_function_head(role, type) do
    case type do
      :abac ->
        user_attr_var = "user_#{role.name}"
        "def can(%User{#{role.name}: #{user_attr_var}} = user) do"

      :rbac ->
        "def can(%{role: :#{role.name}} = user) do"

      _ ->
        "def can(user) do"
    end
  end

  defp build_permission_call(action_name, resource_name, all_conditions, role, type) do
    if map_size(all_conditions) == 0 do
      "    |> #{action_name}(#{resource_name})"
    else
      condition_pairs = format_conditions(all_conditions, role, type)
      "    |> #{action_name}(#{resource_name}, #{condition_pairs})"
    end
  end

  defp build_complete_function(function_head, permission_call) do
    """
    #{function_head}
      permit()
    #{permission_call}
    end
    """
  end

  defp format_conditions(conditions, role, type) do
    if type == :abac do
      user_attr_var = "user_#{role.name}"

      {user_attr_pair, other_pairs} =
        Enum.split_with(conditions, fn {_field, val} -> val == user_attr_var end)

      ordered_pairs = user_attr_pair ++ other_pairs

      ordered_pairs
      |> Enum.map(&format_condition(&1, user_attr_var))
      |> Enum.join(", ")
    else
      conditions
      |> Enum.map(&format_condition(&1, nil))
      |> Enum.join(", ")
    end
  end

  defp format_condition({field, value}, user_attr_var) do
    case value do
      ^user_attr_var when user_attr_var != nil ->
        "#{user_attr_var}: #{user_attr_var}"

      {op, val} when op in [:!=, :>, :>=, :<, :<=, :like, :ilike] ->
        "#{field}: {#{inspect(op)}, #{inspect(val)}}"

      {op, val} when op in [:in, :not_in] and is_list(val) ->
        "#{field}: {#{inspect(op)}, #{inspect(val)}}"

      {:is, nil} ->
        "#{field}: {:is, nil}"

      {:not, {:is, nil}} ->
        "#{field}: {:not, {:is, nil}}"

      val ->
        "#{field}: #{inspect(val)}"
    end
  end
end
