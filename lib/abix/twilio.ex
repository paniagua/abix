defmodule Abix.Twilio do
  import Ecto.Query, only: [from: 2]

  require Logger
  require IEx;
  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://api.twilio.com/2010-04-01/Accounts"
  plug Tesla.Middleware.FormUrlencoded

  def send(site_id, message, to) do
    # conf = service_id |> get_conf_from_messaging_service
    conf = site_id |> get_conf_from_site_id

    credentials =  conf.account_sid <> ":" <> conf.token
      |> Base.encode64

    url = "/"
      <> conf.account_sid
      <> "/Messages.json"
    body = %{
      Body: message,
      To: to,
      MessagingServiceSid: conf.messaging_service
    }
    post(url, body, headers: %{"Authorization" => "Basic " <> credentials})
  end

  def get_conf_from_messaging_service(messaging_service) do
    query = from u in Abix.TwilioConfigurations,
      where: u.messaging_service == ^messaging_service,
      select: u

    Abix.Repo.all(query) |> Enum.at(0)
  end

  def get_conf_from_site_id(site_id) do
    query = from u in Abix.TwilioConfigurations,
      where: u.site_id == ^site_id,
      select: u

    Abix.Repo.all(query) |> Enum.at(0)
  end
end