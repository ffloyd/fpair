defmodule Fpair.Folder do
  @moduledoc """
  Folder analyze functions.
  """

  @doc """
  Is `folder` a git repo?
  """
  def git_repo?(folder) do
    status =
      folder
      |> Git.new()
      |> Git.status()
      |> elem(0)

    case status do
      :ok -> true
      :error -> false
    end
  end

  @doc """
  Is `file` ignored by git repo in `folder`? 
  """
  def git_ignored?(folder, path) do
    status =
      folder
      |> Git.new()
      |> Git.check_ignore(path)
      |> elem(0)

    case status do
      :ok -> true
      :error -> false
    end
  end
end
