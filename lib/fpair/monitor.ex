defmodule Fpair.Monitor do
  @moduledoc """
  Folder monitoring service.
  """

  alias Fpair.Monitor.Worker

  @typedoc """
  Message types.

  We need only two message types:

  * change file -> `:modified`
  * create file -> `:modified` too
  * delete file -> `:removed`
  * rename file -> `:removed` on source path and `:modified` on destination path
  * and we don't care about tracking modification times and so on
  """
  @type message_type :: :modified | :removed

  @typedoc """
  Important note: path inside message should be relative to folder root.
  """
  @type message :: {message_type(), Path.t()}

  @doc """
  Subscribe to events. Events are `GenServer` casts with format described by `t:message/0`.
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
