defmodule Extop.Pollster do
  require Logger

  @moduledoc """
  Polls links (Extop.Library.url's) from DB. 
  """

  @timeouts [timeout: 10_000, recv_timeout: 10_000]

  def polling() do
    Logger.info "Start polling libraries"
    Extop.Repo.all(Extop.Library)
     |> Enum.take(10)
     |> Enum.map(&Task.async(fn -> take_info(&1, &1.is_git) end))
 #    |> Enum.map(&Task.await(&1, 10000))
     |> Task.yield_many(10000)
  end

  def take_info(lib, true) do
    with {:ok, ans} <- get_git_url(lib.url)
    do
      stars = Map.get(ans, "stargazers_count")
      date = Map.get(ans, "pushed_at")                 
      changeset = Extop.Library.changeset(lib, %{stars: stars, commited: date})
      Extop.Repo.update!(changeset)
    else
      {:error, reason} -> Logger.error "#{lib.url} is unavailable. Reason: #{reason}"
    end
  end

  def take_info(lib, false) do
    with {:ok, ans} <- get_hex_url(lib.url)
    do
      date = Map.get(ans, "updated_at")                 
      changeset = Extop.Library.changeset(lib, %{commited: date})
      Extop.Repo.update!(changeset)
    else
      {:error, reason}  -> Logger.error "#{lib.url} is unavailable. Reason: #{reason}"
      {:processed} -> ""
    end
  end

  def get_git_url(url) do
    Logger.info "Fetching info from #{url}"
    url
    |> String.replace_leading("https://github.com", "https://api.github.com/repos")
    |> String.trim_trailing("/")
    |> HTTPoison.get([{"Authorization", 
         "token #{Application.get_env(:extop, :github)[:token_header]}"}], @timeouts)
    |> Extop.Handler.handle_response
  end

  def get_hex_url(url) do
    if String.contains?(url, "hex.pm/pack") do
      Logger.info "Fetching info from #{url}"
      url
      |> String.replace_leading("https://hex.pm/pack", "https://hex.pm/api/pack")
      |> HTTPoison.get(@timeouts)
      |> Extop.Handler.handle_response
    else
      Logger.warn "#{url} is not a Github or Hex library"
      {:processed}
    end
  end
end
