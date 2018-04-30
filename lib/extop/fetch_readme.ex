defmodule Extop.FetchReadme do
  alias Extop.{Repo, File}
  require Logger

  @moduledoc """
  Module that fetchs README.md file. 
  
  Fetches README.md file from H4cc "awersome-elixir" repository. 
  """
  
  @github_url  "https://api.github.com/repos/h4cc/awesome-elixir/readme" 
  @timeouts    [timeout: 10_000, recv_timeout: 10_000]

  def fetch() do  
    Logger.info "Fetching file README.md from #{@github_url}"
    @github_url
    |> HTTPoison.get([{"Authorization", 
         "token #{Application.get_env(:extop, :github)[:token_header]}"}], @timeouts)
    |> Extop.Handler.handle_response
    |> validate_sha
    |> check_db
  end

  def check_db({:ok, {sha, size, file}}) do
    if sha != File.last_sha() do
      Logger.info "It's new file README.md"
      Repo.insert(%File{sha: sha, size: size, loaded: Date.to_string(Date.utc_today())})
      file
        |> Extop.Parser.parse_file()
        |> Extop.Library.save_libraries()
      Logger.info "File README.md is saved to the DB"
    else
      Logger.info "File README.md already exists in DB"
    end
  end

  def check_db({:error, reason}), do: Logger.error "Error! Reason: #{reason}"

  def validate_sha({:error, _}), do: {:error, "Handle response error"}
  
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
      {:ok, {sha, size, file}}    
    else
      Logger.warn "SHA not equal! #{sha_calc} and #{sha}"
      {:error, "Integrity violation"}
    end  
  end

  def validate_sha({:ok, _body}), do: {:error, "Uncorrect data structure"}
end
