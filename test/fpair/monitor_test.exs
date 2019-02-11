defmodule Fpair.MonitorTest do
  use ExUnit.Case

  alias Fpair.Monitor
  alias Fpair.Monitor.Worker

  setup_all do
    folder = Path.expand("../../fpair_test_env", __DIR__)

    if File.exists?(folder), do: File.rm_rf!(folder)
    File.mkdir!(folder)

    start_supervised!({Worker, folder: folder, osx_latency: 0})

    # it's a dirty trick, but we need wait for fsevent to warup 
    Process.sleep(500)

    %{folder: folder}
  end

  describe "subscribe/0" do
    setup do
      :ok = Monitor.subscribe()

      :ok
    end

    test "sends {:modified, path} to subscriber on file creation", %{folder: folder} do
      file = Path.expand("test_create", folder)

      File.touch!(file)

      assert_receive {:"$gen_cast", {:modified, ^file}}
    end

    test "sends {:removed, path} to subscriber on file deletion", %{folder: folder} do
      file = Path.expand("test_delete", folder)

      File.touch!(file)
      File.rm!(file)

      assert_receive {:"$gen_cast", {:modified, ^file}}
      assert_receive {:"$gen_cast", {:removed, ^file}}
    end

    test "sends {:modified, path} to subscriber on file rename", %{folder: folder} do
      file = Path.expand("test_move_src", folder)
      file_moved = Path.expand("test_move_dst", folder)

      File.touch!(file)
      File.rename(file, file_moved)

      assert_receive {:"$gen_cast", {:modified, ^file}}
      assert_receive {:"$gen_cast", {:removed, ^file}}
      assert_receive {:"$gen_cast", {:modified, ^file_moved}}
    end
  end
end
