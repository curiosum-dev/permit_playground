defmodule PermitPlayground.ConditionParser do
  @moduledoc """
  Parses stored permission conditions into the format expected by Permit.Ecto.

  ## Examples

      iex> parse_conditions(%{"author_id" => "123"})
      %{author_id: 123}

      iex> parse_conditions(%{"vote_count" => "{:<=, 100}"})
      %{vote_count: {:<=, 100}}

      iex> parse_conditions(%{"status" => "{:in, [\"active\", \"pending\"]}"})
      %{status: {:in, ["active", "pending"]}}

      iex> parse_conditions(%{"name" => "{:like, \"%admin%\"}"})
      %{name: {:like, "%admin%"}}

      iex> parse_conditions(%{"deleted_at" => "nil"})
      %{deleted_at: nil}

      iex> parse_conditions(%{"role" => "admin"})
      %{role: "admin"}
  """

  def parse_conditions(conditions) when is_map(conditions) do
    Enum.reduce(conditions, %{}, fn {field_name, condition_string}, acc ->
      case parse_condition(condition_string) do
        {:ok, parsed} -> Map.put(acc, String.to_atom(field_name), parsed)
        {:error, _} -> acc
      end
    end)
  end

  def parse_conditions(_), do: %{}

  defp parse_condition(condition_string) when is_binary(condition_string) do
    condition_string = String.trim(condition_string)

    if condition_string == "" do
      {:error, :empty_condition}
    else
      with {:error, _} <- try_eval(condition_string) do
        try_eval("\"#{escape_string(condition_string)}\"")
      end
    end
  end

  defp parse_condition(_), do: {:error, :invalid_format}

  defp try_eval(string) do
    {parsed, _bindings} = Code.eval_string(string)
    {:ok, parsed}
  rescue
    _error -> {:error, :invalid_syntax}
  end

  defp escape_string(string) do
    String.replace(string, "\"", "\\\"")
  end
end
