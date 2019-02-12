defmodule Fpair.Monitor.EventTransformTest do
  use ExUnit.Case, async: true

  alias Fpair.Monitor.EventTransform

  doctest EventTransform

  describe "transform_event/2" do
    test "`:modified` transformation" do
      assert {:modified, "/path"} =
        EventTransform.transform_event(:modified, "/path")
    end

    test "`:created` transformation" do
      assert {:modified, "/path"} =
        EventTransform.transform_event(:created, "/path")
    end

    test "`:removed` transformation" do
      assert {:removed, "/path"} =
        EventTransform.transform_event(:removed, "/path")
    end

    test "`:renamed` transformation when file exists after emmiting event" do
      assert {:modified, "."} =
        EventTransform.transform_event(:renamed, ".")
    end

    test "`:renamed` transformation when file doesn't exist after emmiting event" do
      assert {:removed, "/impossible_dir"} =
        EventTransform.transform_event(:renamed, "/impossible_dir")
    end
  end
end
