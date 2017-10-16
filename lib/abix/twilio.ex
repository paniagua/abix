defmodule Abix.Twilio do
  # import Ecto.Query, only: [from: 2]
  require Logger
  require IEx;
  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://api.twilio.com/2010-04-01/Accounts"
  # plug Tesla.Middleware.JSON
  plug Tesla.Middleware.FormUrlencoded
  plug Tesla.Middleware.Headers, %{"Authorization" => "Basic " <> credentials}

  def credentials do
    account_sid <> ":" <> token
      |> Base.encode64
  end

  def account_sid do
    "AC8f651995d0179ece84ad513473cf29e7"
  end

  def token do
    "4b16bb8bb5243c0b68d5e9d48c6a8d02"
  end

  def messaging_service do
    "MGfe6dec57c72164b0b5a4397ba24e091e"
  end

  def send(message, to) do
    url = "/"
      <> account_sid
      <> "/Messages.json"
    body = %{
      Body: message,
      To: to,
      MessagingServiceSid: messaging_service
    }
    post(url, body)
  end

end