defmodule Abix.FacebookController do
  use Abix.Web, :controller

  require Logger
  require IEx;

  # plug :find_configuration

  def find_configuration(conn, _) do
    Logger.info conn.params["entry"]["id"]
    page_id = conn.params["entry"]["id"]
    conf = Abix.FaceBook.get_conf(page_id)
    assign(conn, :conf, conf)
  end

  def message_to_operator(conn, params) do
    params["entry"]
      |> Enum.at(0)
      |> (fn messaging ->
            messaging["messaging"]
          end).()
      |> Enum.at(0)
      |> (fn message_entry ->
          send_message(message_entry, conn.assigns(:conf))
          end).()
    json conn, %{success: :true}
  end

  def verify_token(conn, params) do
    conf = Abix.Facebook.get_conf_by_challenge(params["hub.verify_token"])

    if params["hub.mode"] == "subscribe"
      && conf != nil do
      conn
        |> send_resp(200, params["hub.challenge"])
    else
      conn
        |> send_resp(403, "")
    end
  end

  def send_message(message_entry, conf) do
    sender_id = message_entry["sender"]["id"]
    message = message_entry["message"]["text"]
    if Abix.SaleMove.has_ongoing_engagement?(sender_id) do
      Logger.info "Has engagement going on"
      Abix.SaleMove.send_message(sender_id, message)
    else
      Logger.info "Does not have engagement going on"
      engagement_request = Abix.SaleMove.request_engagement(conf.site_id, "facebook")
      Abix.SaleMove.save_request(engagement_request, sender_id, message)
    end
  end

  def status(conn, _params) do
    json conn, %{success: :true}
  end
end