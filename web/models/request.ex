defmodule Abix.Request do
  use Abix.Web, :model
  schema "requests" do
    field :request_id, :string
    field :timeout, :integer
    field :site_id, :string
    field :platform, :string
    field :authorization, :string
    field :visit_session_id, :string
    field :sender_id, :string
    field :message, :string
  end
end
