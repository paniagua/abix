defmodule Abix.TwilioConfigurations do
  use Abix.Web, :model

  schema "twilio_configurations" do
    field :account_sid, :string
    field :token, :string
    field :messaging_service, :string
    field :site_id, :string
  end
end

