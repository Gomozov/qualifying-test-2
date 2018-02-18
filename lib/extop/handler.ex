defmodule Extop.Handler do
  require Logger

  @headers [{"Authorization", "token #{Application.get_env(:extop, :github)[:token]}"}]

  def handle_response({ :ok, %{status_code: 200, body: body}}) do
    Poison.Parser.parse(body)
  end
  
  def handle_response({ :ok, %{status_code: 301, body: body}}) do
    Logger.warn "Redirection"
    body
    |> Poison.Parser.parse!()
    |> Map.get("url")
    |> HTTPoison.get(@headers)
    |> handle_response
  end

  def handle_response({ _, %{status_code: status}}) do
    Logger.error "Error #{status} returned"
    {:error, %{}}
  end
  
  def handle_response({ :error, %{reason: reason}}) do
    Logger.error "Error: #{reason}"
    {:error, %{}}
  end
end
