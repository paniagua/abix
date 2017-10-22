  defmodule Abix.Facebook do
  import Ecto.Query, only: [from: 2]

  require Logger
  require IEx;
  use Tesla

  plug Tesla.Middleware.JSON

  def build_url(token) do
    "https://graph.facebook.com/v2.6/me/messages?access_token="
      <> token
  end


  def get_conf(page_id) do
    query = from u in Abix.FacebookConfigurations,
      where: u.page_id == ^page_id,
      select: u

    Abix.Repo.all(query) |> Enum.at(0)
  end

  def get_conf_by_challenge(verification_token) do
    query = from u in Abix.FacebookConfigurations,
      where: u.verification_token == ^verification_token,
      select: u

    Abix.Repo.all(query) |> Enum.at(0)
  end

  def get_conf_by_site_id(site_id) do
    query = from u in Abix.FacebookConfigurations,
      where: u.site_id == ^site_id,
      select: u

    Abix.Repo.all(query) |> Enum.at(0)
  end

  def message_data(recipient_id, messages_text) do
    %{
      recipient: %{
        id: recipient_id
      },
      message: %{
        text: messages_text
      }
    }
  end

  def send(site_id, message, to) do
    conf = site_id |> get_conf_by_site_id
    url = build_url(conf.page_access_token)
    payload = message_data(to, message)

    post(url, payload)
  end
end