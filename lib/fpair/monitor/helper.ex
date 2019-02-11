defmodule Fpair.Monitor.Helper do
  @moduledoc """
  Helper functions for `Fpair.Monitor.Worker`.
  """

  @doc """
  Transforms `FileSystem` events to monitor messages.

  Examples:

      iex> Fpair.Monitor.Helper.transform_events("/tmp/a", [:modified])
      [{:modified, "/tmp/a"}]

      iex> Fpair.Monitor.Helper.transform_events("/tmp/a", [:created, :inodemetamod, :removed])
      [{:modified, "/tmp/a"}, {:removed, "/tmp/a"}]
  """
  @spec transform_events(Path.t(), [atom()]) :: [Fpair.Monitor.message]
  def transform_events(path, events) do
    events
    |> Enum.reverse()
    |> Enum.reduce([], fn event, acc ->
      case transform_event(event, path) do 
        nil -> acc
        msg -> [msg | acc]
      end
    end)
  end

  @doc """
  Transform `fs_event` for given `path` into `t:Fpair.Monitor.message/0`.
  Returns `nil` if event doesn't produce message.
  """
  @spec transform_event(atom(), Path.t()) :: Fpair.Monitor.message() | nil
  def transform_event(fs_event, path)

  def transform_event(:modified, path), do: {:modified, path}
  def transform_event(:created, path), do: {:modified, path}
  def transform_event(:removed, path), do: {:removed, path}

  def transform_event(:renamed, path) do
    if File.exists?(path) do
      {:modified, path}
    else
      {:removed, path}
    end
  end

  def transform_event(_, _), do: nil
end
