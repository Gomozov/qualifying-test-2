defmodule Extop.PageController do
  use Extop.Web, :controller

  def index(conn, params \\ %{}) do
    min_stars = Map.get(params, "min_stars") || "empty"
    libs = Extop.Library.get_libraries(min_stars)
    keys = Map.keys(libs) |> Enum.sort
    conn
    |> assign(:libs, libs)
    |> assign(:keys, keys)
    |> render("index.html")
  end
end
