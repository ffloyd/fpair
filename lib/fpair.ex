defmodule Fpair do
  @moduledoc """
  Code folder sync tool for remote pair programming.
  """

  @type events_map :: %{required(atom()) => atom()}

  @type message_type :: :modified | :removed
  @type message :: {message_type(), Path.t()}

  @doc """
  Transforms fsevents `events` to monitor messages using `events_map`.

  Examples:

      iex> Fpair.build_messages("/tmp/a", [:modified])
      [{:modified, "/tmp/a"}]

      iex> Fpair.build_messages("/tmp/a", [:created, :inodemetamod, :removed])
      [{:modified, "/tmp/a"}, {:removed, "/tmp/a"}]
  """
  @spec build_messages(Path.t(), [atom()]) :: [message]
  def build_messages(path, events) do
    events
    |> Enum.reverse()
    |> Enum.reduce([], fn event, acc ->
      case events_map()[event] do
        nil -> acc
        message_type -> [{message_type, path} | acc]
      end
    end)
  end

  @spec events_map :: events_map()
  defp events_map do
    %{
      created: :modified,
      modified: :modified,
      removed: :removed
    }
  end
end
