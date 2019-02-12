defmodule Fpair.Monitor.EventTransform do
  @moduledoc """
  Transformation from `FileSystem` events to simplified internal ones.
  """

  @doc """
  Transforms `FileSystem` events to `t:Fpair.Monitor.message/0`.

  Examples:

      iex> Fpair.Monitor.EventTransform.transform_events("/", "tmp/a", [:modified])
      [{:modified, "tmp/a"}]

      iex> Fpair.Monitor.EventTransform.transform_events("/", "tmp/a", [:created, :inodemetamod, :removed])
      [{:modified, "tmp/a"}, {:removed, "tmp/a"}]
  """
  @spec transform_events(Path.t(), Path.t(), [atom()]) :: [Fpair.Monitor.message]
  def transform_events(folder, path, events) do
    events
    |> Enum.reverse()
    |> Enum.reduce([], fn event, acc ->
      case transform_event(folder, event, path) do
        nil -> acc
        msg -> [msg | acc]
      end
    end)
  end

  defp transform_event(folder, fs_event, path)

  defp transform_event(folder, :modified, path), do: {:modified, path |> Path.relative_to(folder)}
  defp transform_event(folder, :created, path), do: {:modified, path |> Path.relative_to(folder)}
  defp transform_event(folder, :removed, path), do: {:removed, path |> Path.relative_to(folder)}

  defp transform_event(folder, :renamed, path) do
    type = if File.exists?(path) do
      :modified
    else
      :removed
    end

    {type, path |> Path.relative_to(folder)}
  end

  defp transform_event(_, _, _), do: nil
end
