defmodule Extop.FetchReadme do
  import Ecto.Query
  alias Extop.Repo
  alias Extop.File
  require Logger

  @moduledoc """
  Module that works with Github. 
  
  Fetches README.md file from H4cc "awersome-elixir" repository. 
  """
  
  @github_url "https://api.github.com/repos/h4cc/awesome-elixir/readme" 
  @headers [{"Authorization", "token #{Application.get_env(:extop, :github)[:token]}"}]

  def fetch() do  
    Logger.info "Fetching README.md from #{@github_url}"
    @github_url
    |> HTTPoison.get(@headers, [timeout: 10_000, recv_timeout: 10_000])
    |> Extop.Handler.handle_response
    |> validate_sha
    |> check_db
  end

  def check_db({sha, size, file}) do #Move to model
    if sha != last_sha() do
      Logger.info "Write new data to the DB"
      Repo.insert(%File{sha: sha, size: size, loaded: Date.to_string(Date.utc_today())})
      file
        |> Extop.Parser.parse_file()
        |> save_libraries
      Logger.info "Data is saved to the DB"
    else
      Logger.info "Record is already exist"
    end
  end

  def save_libraries(libs) do
    Repo.delete_all(Extop.Library)
    libs
    |> Enum.map(&Repo.insert(&1))
  end

  def last_sha() do   #Move to model
    from(d in File, limit: 1, order_by: [desc: d.inserted_at])
    |> (&Repo.one(&1) || %{}).()
    |> Map.get(:sha)
  end

  @doc """
    Compares the received SHA and calculated SHA of file.
  """
  def validate_sha({:ok, %{"content" => content, "size" => size, "sha" => sha}}) do
    file = 
      content
      |> Base.decode64!(ignore: :whitespace)
    sha_calc = 
      :crypto.hash(:sha, "blob "<>Integer.to_string(size)<>"\0"<>file) 
      |> Base.encode16       
      |> String.downcase
    if sha_calc == sha do
      Logger.info "SHA equal #{sha}"
      {sha, size, file}    
    else
      Logger.warn "SHA not equal! #{sha_calc} and #{sha}"
    end  
  end

  def validate_file({:ok, body}) do
    Logger.error "Error! Uncorrect data structure!"
    IO.inspect body
  end

  def validate_file({:error, body}) do
    Logger.error "Error! Can't validate file!"
    IO.inspect body
  end
end
