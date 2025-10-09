defmodule PermitPlayground.PermitGenerator do
  @moduledoc """
  Generates Permit.Ecto permission code from stored permissions.
  """

  alias PermitPlayground.ConditionParser

  def generate_can_function_preview(role, action, resource, conditions \\ %{}) do
    action_name = String.to_atom(action.name)
    resource_name = resource.name

    parsed_conditions = ConditionParser.parse_conditions(conditions)

    permission_call =
      if map_size(parsed_conditions) == 0 do
        "    |> #{action_name}(#{resource_name})"
      else
        condition_pairs = format_conditions(parsed_conditions)
        "    |> #{action_name}(#{resource_name}, #{condition_pairs})"
      end

    """
    def can(%{role: :#{role.name}} = user) do
      permit()
    #{permission_call}
    end
    """
  end

  defp format_conditions(conditions) do
    conditions
    |> Enum.map(&format_condition/1)
    |> Enum.join(", ")
  end

  defp format_condition({field, value}) do
    case value do
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
