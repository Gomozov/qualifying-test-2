defmodule Extop.PageController do
  use Extop.Web, :controller
  alias Extop.Library

  def index(conn, %{"min_stars" => min_stars}) do
    files = Extop.Repo.all(Extop.File)
    query =
      case Integer.parse(min_stars) do
        {int, _str}   -> from lib in Library, where: lib.stars >= ^int
        :error        -> Library
      end
    libraries = Extop.Repo.all(query)
    conn
    |> assign(:files, files)
    |> assign(:libraries, libraries)
    |> render("index.html")
  end

  def index(conn, _params) do
    files = Extop.Repo.all(Extop.File)
    libraries = Extop.Repo.all(Library)
    conn
    |> assign(:files, files)
    |> assign(:libraries, libraries)
    |> render("index.html")
  end
end
