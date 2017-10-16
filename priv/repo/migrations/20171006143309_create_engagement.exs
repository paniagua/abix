defmodule Abix.Repo.Migrations.CreateEngagement do
  use Ecto.Migration

  def change do
    create table(:engagements) do
      add :engagement_id, :string
      add :engagement_request_id, :string
      add :visit_id, :string
      add :sub_engagement_id, :string
      add :operator_id, :string
      add :site_id, :string
      add :ended, :boolean, default: false
      timestamps()
    end
  end
end
