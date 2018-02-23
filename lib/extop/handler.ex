defmodule Extop.Handler do
  require Logger

  @moduledoc """
  Module that handles HTTP response. 
  """

  def handle_response({ :ok, %{status_code: 200, body: body}}) do
    Poison.Parser.parse(body)
  end
  
  def handle_response({ :ok, %{status_code: 301, body: body}}) do
    Logger.warn "Redirection"
    body
    |> Poison.Parser.parse!()
    |> Map.get("url")
    |> HTTPoison.get(Application.get_env(:extop, :github)[:token_header])
    |> handle_response
  end

  def handle_response({ _, %{status_code: status, body: _body}}) do
    Logger.error "Error #{status} returned"
    {:error, status}
  end
  
  def handle_response({ :error, %{reason: reason}}) do
    Logger.error "Error: #{reason}"
    {:error, reason}
  end
end
