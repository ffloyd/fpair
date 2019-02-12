defmodule Fpair.Monitor.Worker do
  @moduledoc """
  `GenServer` part of `Fpair.Monitor`.
  """

  use GenServer

  import Fpair.Monitor.EventTransform, only: [transform_events: 3]

  require Logger

  @type options :: [option]
  @type option ::
          {:folder, Path.t()}
          | {:osx_latency, float()}

  @spec start_link(options()) :: GenServer.on_start()
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc false
  def init(opts) do
    osx_latency = Keyword.get(opts, :osx_latency, 0.5)

    folder =
      opts
      |> Keyword.fetch!(:folder)
      |> Path.expand()

    {:ok, fs} = FileSystem.start_link(dirs: [folder], latency: osx_latency)
    :ok = FileSystem.subscribe(fs)

    {:ok, %{folder: folder, fs: fs, subscribers: []}}
  end

  def handle_call({:subscribe, pid}, _form, state = %{subscribers: subscribers}) do
    {
      :reply,
      :ok,
      %{state | subscribers: [pid | subscribers]}
    }
  end

  def handle_call({:unsubscribe, pid}, _form, state = %{subscribers: subscribers}) do
    {
      :reply,
      :ok,
      %{state | subscribers: subscribers |> List.delete(pid)}
    }
  end

  def handle_info(
        {:file_event, fs, {path, events}},
        state = %{folder: folder, fs: fs, subscribers: subscribers}
      ) do
    folder
    |> transform_events(path, events)
    |> Enum.each(&cast_all(subscribers, &1))

    {:noreply, state}
  end

  def handle_info(msg, state) do
    Logger.warn("Unexpected message received: #{msg |> inspect()}")

    {:noreply, state}
  end

  defp cast_all(subscribers, msg) do
    subscribers
    |> Enum.each(&GenServer.cast(&1, msg))
  end
end
