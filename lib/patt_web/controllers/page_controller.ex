defmodule PattWeb.PageController do
  use PattWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
