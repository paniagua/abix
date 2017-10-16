defmodule Abix.Engagement do
  use Abix.Web, :model

  schema "engagements" do
    field :engagement_id, :string
    field :engagement_request_id, :string
    field :visit_id, :string
    field :sub_engagement_id, :string
    field :operator_id, :string
    field :site_id, :string
    field :ended, :boolean
  end
end
