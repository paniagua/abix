defmodule Abix.TwilioController do
  use Abix.Web, :controller

  require Logger
  require IEx;

  plug :find_configuration

  def find_configuration(conn, _) do
    Logger.info conn.params["MessagingServiceSid"]
    message_service_id = conn.params["MessagingServiceSid"]
    conf = Abix.Twilio.get_conf_from_messaging_service(message_service_id)
    assign(conn, :conf, conf)
  end

  def message_to_operator(conn, params) do
    sender_id = params["From"]
    conf = conn.assigns[:conf]
    if Abix.SaleMove.has_ongoing_engagement?(sender_id) do
      Logger.info "Has engagement going on"
      Abix.SaleMove.send_message(sender_id, params["Body"])
    else
      Logger.info "Does not have engagement going on"
      engagement_request = Abix.SaleMove.request_engagement(conf.site_id, "sms")
      Abix.SaleMove.save_request(engagement_request, sender_id, params["Body"])
    end
    json conn, %{success: :true}
  end

  def status(conn, _params) do
    json conn, %{success: :true}
  end
end