defmodule Extop.PageController do
  use Extop.Web, :controller

  def index(conn, _params) do
    files = Extop.Repo.all(Extop.File)
    libraries = Extop.Repo.all(Extop.Library)
    #render conn, "index.html", {files: files, libraries: libraries}
    conn
    |> assign(:files, files)
    |> assign(:libraries, libraries)
    |> render("index.html")
  end
end
