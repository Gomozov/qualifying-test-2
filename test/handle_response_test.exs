defmodule HandleResponseTest do
  use ExUnit.Case

  test "test handle_response function with status 200 and correct JSON" do
    body = "{\"id\":123,\"name\":\"Name\",\"desc\":\"Description\"}"
    {:ok, result} = Extop.Handler.handle_response({:ok, %{status_code: 200, body: body}})
    assert result ==  %{"id" => 123, "name" => "Name", "desc" => "Description"}
  end

  test "test handle_response function with status 200 and uncorrect JSON" do
    body = "{123,\"name\":\"Name\",\"desc\":\"Description\"}"
    {:error, result} = Extop.Handler.handle_response({:ok, %{status_code: 200, body: body}})
    assert result ==  {:invalid, "1"}
  end

  test "test handle_response function with status 404" do
    {:error, result} = Extop.Handler.handle_response({:ok, %{status_code: 404, body: "body"}})
    assert result == 404
  end

  test "test handle_response function with error reason" do
    {:error, result} = Extop.Handler.handle_response({:error, %{reason: "Timeout"}})
    assert result == "Timeout"
  end
end
