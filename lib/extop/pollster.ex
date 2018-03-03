defmodule Extop.Pollster do
  require Logger

  @moduledoc """
  Polls links (Extop.Library.url's) from DB. 
  """

  @timeouts [timeout: 10_000, recv_timeout: 10_000]

  def polling() do
    Logger.info "Start polling libraries"
    Extop.Repo.all(Extop.Library)
     |> Enum.take(5)
     |> Enum.map(&Task.async(fn -> take_info(&1) end))
     |> Enum.map(&Task.await/1)
  end

  @doc """
    Returns JSON information about ropository by it URL.
  """
  def get_url(url) do
    Logger.info "Fetching info from #{url}"
    url
    |> String.replace_leading("https://github.com", "https://api.github.com/repos")
    |> String.trim_trailing("/")
    |> HTTPoison.get(Application.get_env(:extop, :github)[:token_header], @timeouts)
    |> Extop.Handler.handle_response
  end

  @doc """
    Returns updated lib with actual information about number of stars and date of last commit.
  """
  def take_info(lib) do
    with true       <- lib.is_git,
         {:ok, ans} <- get_url(lib.url)
    do
      stars = Map.get(ans, "stargazers_count")
      date = Map.get(ans, "pushed_at")                 
      changeset = Extop.Library.changeset(lib, %{stars: stars, commited: date})
      Extop.Repo.update!(changeset)
    else
      false       ->
        Logger.warn "#{lib.url} is not a Github library"
      {:error, _} -> 
        Logger.error "#{lib.url} is unavailable"
    end
  end
end
