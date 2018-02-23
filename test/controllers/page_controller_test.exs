defmodule Extop.PageControllerTest do
  use Extop.ConnCase

  setup do
    first_lib  = insert_library(name: "First library", stars: 5)
    second_lib = insert_library(name: "Second library", stars: nil)
    third_lib  = insert_library(name: "Third library", stars: 10)
    {:ok, one: first_lib, two: second_lib, three: third_lib}
  end

  test "GET /" do
    conn = get build_conn(), "/"
    assert html_response(conn, 200) =~ "EliXir TOP list"
    assert html_response(conn, 200) =~ "Libraries"
  end

  test "show libraries without min_stars", 
    %{one: first_lib, two: second_lib, three: third_lib} do

    conn = get build_conn(), "/"
    assert String.contains?(conn.resp_body, first_lib.name)
    assert String.contains?(conn.resp_body, second_lib.name)
    assert String.contains?(conn.resp_body, third_lib.name)
  end

  test "show libraries with min_stars", 
    %{one: first_lib, two: second_lib, three: third_lib} do

    conn = get build_conn(), "/?min_stars=10"
    refute String.contains?(conn.resp_body, first_lib.name)
    refute String.contains?(conn.resp_body, second_lib.name)
    assert String.contains?(conn.resp_body, third_lib.name)
  end

  test "show libraries with uncorrect min_stars", 
    %{one: first_lib, two: second_lib, three: third_lib} do

    conn = get build_conn(), "/?min_stars=error"
    assert String.contains?(conn.resp_body, first_lib.name)
    assert String.contains?(conn.resp_body, second_lib.name)
    assert String.contains?(conn.resp_body, third_lib.name)
  end
end
