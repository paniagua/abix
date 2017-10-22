defmodule Abix.FacebookConfigurations do
  use Abix.Web, :model

  schema "facebook_configurations" do
    field :page_id, :string
    field :verification_token, :string
    field :page_access_token, :string
    field :site_id, :string
  end
end

