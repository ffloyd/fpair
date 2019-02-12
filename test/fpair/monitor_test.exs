defmodule Fpair.MonitorTest do
  use ExUnit.Case

  alias Fpair.Monitor
  alias Fpair.Monitor.Worker

  setup_all do
    folder = Path.expand("../../fpair_test_env", __DIR__)

    if File.exists?(folder), do: File.rm_rf!(folder)
    File.mkdir!(folder)

    on_exit(fn ->
      File.rm_rf!(folder)
    end)

    start_supervised!({Worker, folder: folder, osx_latency: 0})

    # it's a dirty trick, but we need wait for fsevent to warup
    Process.sleep(500)

    %{folder: folder}
  end

  describe "subscribtion and events" do
    setup do
      :ok = Monitor.subscribe()

      on_exit(fn ->
        :ok = Monitor.unsubscribe()
      end)

      :ok
    end

    test "create file", %{folder: folder} do
      file = "test_create"
      path = Path.expand(file, folder)

      File.touch!(path)

      assert_receive {:"$gen_cast", {:modified, ^file}}
    end

    test "create and delete file", %{folder: folder} do
      file = "test_delete"
      path = Path.expand(file, folder)

      File.touch!(path)
      File.rm!(path)

      assert_receive {:"$gen_cast", {:modified, ^file}}
      assert_receive {:"$gen_cast", {:removed, ^file}}
    end

    test "create and move file", %{folder: folder} do
      file = "test_move_src"
      path = Path.expand(file, folder)

      file_moved = "test_move_dst"
      path_moved = Path.expand(file_moved, folder)

      File.touch!(path)
      File.rename(path, path_moved)

      assert_receive {:"$gen_cast", {:modified, ^file}}
      assert_receive {:"$gen_cast", {:removed, ^file}}
      assert_receive {:"$gen_cast", {:modified, ^file_moved}}
    end
  end
end
