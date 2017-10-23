defmodule Abix.SaleMove do
  import Ecto.Query, only: [from: 2]
  require Logger
  require IEx;
  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://api.beta.salemove.com"
  plug Tesla.Middleware.JSON

  def find_operator(site_id) do
    get("/operators?include_offline=false&site_ids[]=#{site_id}",
      headers: %{
        "Authorization" => "Token BczJeWiGePA7tRxaOrkHnA",
        "Accept" => "application/vnd.salemove.v1+json"
    }).body["operators"]
      |> Enum.filter(fn operator -> operator["available"] == true end)
      |> Enum.at(0)
  end

  # Move this to a structure
  defp request_params(operator_id, channel_type) do
    %{
      operator_id: operator_id,
      media: "text",
      new_site_visitor: %{
        site_id: "",
        name: "Elixir Visitor"
      },
      webhooks: [
        %{
          url: "https://04383d53.ngrok.io/salemove/start_engagement",
          method: :POST,
          events: ["engagement.start"]
        },
        %{
          url: "https://04383d53.ngrok.io/salemove/" <> channel_type,
          method: :POST,
          events: ["engagement.chat.message"]
        },
        %{
          url: "https://04383d53.ngrok.io/salemove/end_engagement",
          method: :POST,
          events: ["engagement.end"]
        }
      ]
    }
  end

  def save_request(engagement_request, sender_id, message) do
    engagement_request |> build_request
      |> (fn request -> %{request | sender_id: sender_id} end).()
      |> (fn request -> %{request | message: message} end).()
      |> Abix.Repo.insert
  end

  defp send_engagement_request(params) do
    post("/engagement_requests", params,
      headers: %{
        "Authorization" => "Token BczJeWiGePA7tRxaOrkHnA",
        "Accept" => "application/vnd.salemove.v1+json"
      }).body
  end

  def request_engagement(site_id, channel_type) do
    request_parameters = site_id
      |> find_operator
      |> (fn operator ->
            request_params(operator["id"], channel_type)
          end).()
    # request_parameters
      |> (fn params ->
            %{params | new_site_visitor: %{
                          site_id: site_id,
                          name: "Demo"
                        }}
          end).()
      |> send_engagement_request
  end

  defp build_request(request_response) do
    %Abix.Request{
      request_id: request_response["id"],
      timeout: request_response["timeout"],
      site_id: request_response["site_id"],
      platform: request_response["platform"],
      authorization: request_response["visitor_authentication"]["Authorization"],
      visit_session_id: request_response["visitor_authentication"]["X-Salemove-Visit-Session-Id"]
    }
  end

  def build_engagement(engagement) do
    %Abix.Engagement{
      engagement_id: engagement["id"],
      engagement_request_id: engagement["engagement_request_id"],
      visit_id: engagement["visit_id"],
      sub_engagement_id: engagement["current_sub_engagement"]["id"],
      operator_id: engagement["current_sub_engagement"]["operator_id"],
      site_id: engagement["current_sub_engagement"]["site_id"]
    }
  end

  def engagement_accepted(engagement) do
    engagement
      |> build_engagement
      |> Abix.Repo.insert
  end

  def send_message(sender_id, message) do
    request = sender_id
      |> last_request_by_sender

    engagement = request.request_id
      |> find_engagement_by_request_id

    url = "/engagements/" <> engagement.engagement_id <> "/chat_messages/" <> UUID.uuid4()
    Logger.info url
    Logger.info message
    body =  %{
      content: message
    }
    put(url, body, headers: %{
      "Authorization" => request.authorization,
      "Accept" => "application/vnd.salemove.v1+json",
      "X-Salemove-Visit-Session-Id" => request.visit_session_id
    })
  end

  def current_engagement(sender_id) do
    request = sender_id
      |> last_request_by_sender

    request.request_id
      |> find_engagement_by_request_id
  end


  def has_ongoing_engagement?(sender_id) do
    Logger.info sender_id
    request = sender_id
      |> last_request_by_sender

    if request != nil do
      Logger.info request.request_id
      request.request_id
        |> find_engagement_by_request_id
        |> (fn engagement -> engagement != nil && engagement.ended == :false end).()
    else
      false
    end
  end

  def last_request_by_sender(sender_id) do
    query = from u in Abix.Request,
      where: u.sender_id == ^sender_id,
      order_by: [desc: u.inserted_at],
      limit: 1,
      select: struct(u, [:request_id, :authorization, :visit_session_id])
    Abix.Repo.all(query) |> Enum.at(0)
  end

  def find_engagement_by_request_id(request_id) do
    query = from u in Abix.Engagement,
      where: u.engagement_request_id == ^request_id,
      order_by: [desc: u.inserted_at],
      limit: 1,
      select: struct(u, [:engagement_id, :operator_id, :sub_engagement_id, :ended])
    Abix.Repo.all(query) |> Enum.at(0)
  end

  def find_sender_by_engagement_id(id) do
    engagement = id
      |> find_engagement_by_id
    engagement.engagement_request_id
      |> find_request_by_id
      |> (fn request -> request.sender_id end).()
  end

  def find_site_by_engagement_id(id) do
      id
      |> find_engagement_by_id
      |> (fn engagement -> engagement.site_id end).()
  end

  def find_engagement_by_id(id) do
    query = from u in Abix.Engagement,
      where: u.engagement_id == ^id,
      # select: struct(u, [:engagement_id, :operator_id, :sub_engagement_id, :ended, :engagement_request_id, :site_id])
      select: u
    Abix.Repo.all(query) |> Enum.at(0)
  end

  def find_request_by_id(id) do
    query = from u in Abix.Request,
      where: u.request_id == ^id,
      select: struct(u, [:request_id, :authorization, :visit_session_id, :sender_id, :message])
    Abix.Repo.all(query) |> Enum.at(0)
  end

  def find_request(request_id) do
    Abix.Request
    |> Abix.Repo.get_by(request_id: request_id)
  end

  def end_engagement(engagement_id) do
    query = from u in Abix.Engagement,
      where: u.engagement_id == ^engagement_id,
      select: u

    engagement = Abix.Repo.all(query) |> Enum.at(0)

    engagement = Ecto.Changeset.change engagement, ended: :true
    case Abix.Repo.update engagement do
      {:ok, struct}       -> Logger.info "Engagement Ended"
      {:error, changeset} -> Logger.info "Engagement Not Updated"
    end
  end
end