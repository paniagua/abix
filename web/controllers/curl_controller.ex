defmodule Abix.CurlController do
  use Abix.Web, :controller

  require Logger
  require IEx;

  def message_to_operator(conn, params) do
    response = Abix.SaleMove.send_message(params["sender_id"], params["message"])
    Logger.info response.status
    json conn, response
  end

  def status(conn, _params) do
    json conn, %{success: :true}
  end
end