defmodule Fpair.FolderTest do
  use ExUnit.Case

  alias Fpair.Folder

  describe "git_repo?/1" do
    test "when folder is a git repo" do
      assert "../.." |> Path.expand(__DIR__) |> Folder.git_repo?()
    end

    test "when folder isn't a git repo" do
      refute "/" |> Folder.git_repo?()
    end
  end

  describe "git_ignored?/2" do
    setup do
      %{
        repo_path: Path.expand("../..", __DIR__)
      }
    end

    test "when path is ignored inside repo", %{repo_path: repo_path} do
      assert Folder.git_ignored?(repo_path, "doc/")
    end

    test "when path isn't ignored iside repo", %{repo_path: repo_path} do
      refute Folder.git_ignored?(repo_path, "mix.exs")
    end

    test "when path outside the repo", %{repo_path: repo_path} do
      refute Folder.git_ignored?(repo_path, "/tmp")
    end
  end
end
