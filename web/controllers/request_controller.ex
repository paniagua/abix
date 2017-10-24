defmodule Abix.RequestController do
  use Abix.Web, :controller

  require Logger
  require IEx;

  def start_engagement(conn, params) do
    Logger.info "Engagement Start Event Received"
    Abix.SaleMove.engagement_accepted(params["engagement"])
    request = Abix.SaleMove.find_request_by_id(params["engagement"]["engagement_request_id"])
    Abix.SaleMove.send_message(request.sender_id, request.message)
    json conn, %{success: :true}
  end

  def end_engagement(conn, params) do
    Logger.info "Engagement End Event Received"
    engagement_id = params["engagement"]["id"]
    Abix.SaleMove.end_engagement(engagement_id)
    json conn, %{success: :true}
  end

  def status(conn, _params) do
    json conn, %{success: :true}
  end
end