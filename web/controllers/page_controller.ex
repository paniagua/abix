defmodule Abix.PageController do
  use Abix.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
