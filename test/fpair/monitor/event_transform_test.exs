defmodule Fpair.Monitor.EventTransformTest do
  use ExUnit.Case, async: true

  alias Fpair.Monitor.EventTransform

  doctest EventTransform

  describe "transform_events/3" do
    test "`:modified` transformation" do
      assert [{:modified, "path"}] ==
        EventTransform.transform_events("/", "path", [:modified])
    end

    test "`:created` transformation" do
      assert [{:modified, "path"}] ==
        EventTransform.transform_events("/", "path", [:created])
    end

    test "`:removed` transformation" do
      assert [{:removed, "path"}] ==
        EventTransform.transform_events("/", "path", [:removed])
    end

    test "`:renamed` transformation when file exists after emmiting event" do
      assert [{:modified, "."}] ==
        EventTransform.transform_events("/", ".", [:renamed])
    end

    test "`:renamed` transformation when file doesn't exist after emmiting event" do
      assert [{:removed, "impossible_dir"}] ==
        EventTransform.transform_events("/", "impossible_dir", [:renamed])
    end
  end
end
