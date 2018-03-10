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
    |> HTTPoison.get([{"Authorization", "token #{Application.get_env(:extop, :github)[:token_header]}"}])
    |> handle_response
  end

  def handle_response({ _, %{status_code: status, body: _body}}) do
    {:error, status}
  end
  
  def handle_response({ :error, %{reason: reason}}) do
    {:error, reason}
  end
end
