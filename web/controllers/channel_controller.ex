defmodule Abix.ChannelController do
  use Abix.Web, :controller

  require Logger
  require IEx;

  # plug Tesla.Middleware.BaseUrl, "https://api.twilio.com/2010-04-01/Accounts"


  plug :find_sender
  plug :find_message
  plug :find_site_id

  def find_sender(conn, _) do
    sender_id = conn.params["message"]["engagement_id"]
          |> Abix.SaleMove.find_sender_by_engagement_id
    assign(conn, :sender_id, sender_id)
  end

  def find_message(conn, _) do
    message = conn.params["message"]["content"]
    assign(conn, :message, message)
  end

  def find_site_id(conn, _) do
    assign(conn, :site_id, "17f2e072-3802-47b0-84b5-25eb00d791cd")
  end

  def send_sms(conn, params) do
    sender_id = conn.assigns[:sender_id]
    message = conn.assigns[:message]
    site_id = conn.assigns[:site_id]
    response = Abix.Twilio.send(site_id, message, sender_id)
    json conn, response
  end

  def send_facebook_message(conn, params) do
    sender_id = conn.assigns[:sender_id]
    message = conn.assigns[:message]
    site_id = conn.assigns[:site_id]

    response = Abix.Facebook.send(site_id, message, sender_id)
    json conn, response
  end
end
