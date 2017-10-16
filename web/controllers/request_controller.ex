defmodule Abix.RequestController do
  use Abix.Web, :controller

  require Logger
  require IEx;

  # plug :read_request

  def create_parameters(params) do
    %{
      site_id: params["site_id"],
      sender_id: params["sender_id"]
    }
  end

  def index(conn, _params) do
    requests = Repo.all(Abix.Request)
    json conn, requests
  end

  def show(conn, %{"id" => id}) do
    request = Repo.get(Abix.Request, String.to_integer(id))
    json conn, request
  end

  def create(conn, params) do
    sender_id = params["sender_id"]
    site_id = "17f2e072-3802-47b0-84b5-25eb00d791cd"
    if Abix.SaleMove.has_ongoing_engagement?(sender_id) do
      Abix.SaleMove.send_message(sender_id, params["message"])
    else
      Abix.SaleMove.request_engagement(site_id, sender_id, params["message"])
    end
    json conn, %{success: :true}
  end

  def salemove_callback(conn, params) do
    event_type = params["event_type"]
    Logger.info event_type
    case(params["event_type"]) do
      "engagement.start" ->
        Logger.info "Engagement Start Event Received"
        Abix.SaleMove.engagement_accepted(params["engagement"])
        request = Abix.SaleMove.find_request_by_id(params["engagement"]["engagement_request_id"])
        Abix.SaleMove.send_message(request.sender_id, request.message)
      "engagement.end" ->
        Logger.info "Engagement End Event Received"
        engagement_id = params["engagement"]["id"]
        Abix.SaleMove.end_engagement(engagement_id)
      "engagement.chat.message" ->
        Logger.info "Chat Message Received"
        Logger.info params["message"]["content"]
        sender_id = params["message"]["engagement_id"]
          |> Abix.SaleMove.find_sender_by_engagement_id
        response = Abix.Twilio.send(params["message"]["content"], sender_id)
      "engagement.chat.message.status" ->
        Logger.info "Chat Message Status Received"
        Logger.info params["message"]["status"]
      _ ->
        Logger.info "Unhandled Event #{event_type}"
    end
    json conn, %{success: :true}
  end

  ## messages from operator the third party
  def chat_message(conn, params) do
    response = Abix.Twilio.send(params["message"], params["to"])
    json conn, response
  end

  def end_engagement(conn, params) do
    # engagement_id = params["engagement"]["id"]
    engagement_id = params["engagement_id"]
    Abix.SaleMove.end_engagement(engagement_id)
    json conn, %{success: :true}
  end

  ## third party messages to the operator
  def fb_integration(conn, params) do
    params["entry"]["messaging"]
      |> Enum.filter(fn event -> event["message"] != nil end)
      |> Abix.SaleMove.send_message
  end

  def curl_integration(conn, params) do
    response = Abix.SaleMove.send_message(params["sender_id"], params["message"])
    Logger.info response.status
    json conn, response
  end

  def twilio_integration(conn, params) do
    sender_id = params["From"]
    site_id = "17f2e072-3802-47b0-84b5-25eb00d791cd"
    if Abix.SaleMove.has_ongoing_engagement?(sender_id) do
      Logger.info "Has engagement going on"
      Abix.SaleMove.send_message(sender_id, params["Body"])
    else
      Logger.info "Does not have engagement going on"
      Abix.SaleMove.request_engagement(site_id, sender_id, params["Body"])
    end
    json conn, %{success: :true}
  end

  def status(conn, _params) do
    json conn, %{success: :true}
  end
end