defmodule Fpair.Monitor do
  @moduledoc """
  Folder monitoring service.
  """

  alias Fpair.Monitor.Worker

  @type message_type :: :modified | :removed
  @type message :: {message_type(), Path.t()}

  @doc """
  Subscribe to events. Events are GenServer casts with format described by `t:message/0`.
  """
  def subscribe do
    GenServer.call(Worker, {:subscribe, self()})
  end

  @doc """
  Unsubscribe from events.
  """
  def unsubscribe do
    GenServer.call(Worker, {:unsubscribe, self()})
  end
end
