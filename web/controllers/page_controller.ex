defmodule Extop.PageController do
  use Extop.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
