defmodule Extop.PageController do
  use Extop.Web, :controller
  alias Extop.Library

  def index(conn, %{"min_stars" => min_stars}) do
    query =
      case Integer.parse(min_stars) do
        {int, _str}   -> from lib in Library, where: lib.stars >= ^int
        :error        -> Library
      end
    libraries = Extop.Repo.all(query)
    conn
    |> assign(:libraries, libraries)
    |> render("index.html")
  end

  def index(conn, _params) do
    libraries = Extop.Repo.all(Library)
    conn
    |> assign(:libraries, libraries)
    |> render("index.html")
  end
end
