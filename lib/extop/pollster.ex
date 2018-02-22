defmodule Extop.Pollster do
  require Logger

  @headers [{"Authorization", "token #{Application.get_env(:extop, :github)[:token]}"}]

  def polling() do
    Logger.info "Start polling"
    Extop.Repo.all(Extop.Library)
     |> Enum.take(5)
     |> Enum.map(&async_take_info/1)
     |> Enum.map(fn(_) -> get_result() end)
  end

  def async_take_info(lib) do
    caller = self()
    spawn(fn -> send(caller, {:result, take_info(lib)}) end)
  end

  def get_result() do
    receive do
      {:result, result} -> 
        result
    end
  end

  @doc """
    Returns JSON information about ropository by it URL.
  """
  def get_url(url) do
    Logger.info "Fetching info from #{url}"
    url
    |> String.replace_leading("https://github.com", "https://api.github.com/repos")
    |> String.trim_trailing("/")
    |> HTTPoison.get(@headers, [timeout: 10_000, recv_timeout: 10_000])
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
      #%{lib | stars: stars, commited: date}
    else
      false       ->
        Logger.warn "#{lib.url} is not a Github library"
       # lib
      {:error, _} -> 
        Logger.error "#{lib.url} is unavailable"
       # lib
    end
  end

end
