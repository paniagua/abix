defmodule Abix.SiteConfigurations do
  use Abix.Web, :model

  schema "site_configurations" do
    field :webhook_base_url, :string
    field :app_token, :string
    field :site_id, :string
    field :endpoint, :string
  end
end
