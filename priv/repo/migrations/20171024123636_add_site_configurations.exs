defmodule Abix.Repo.Migrations.AddSiteConfigurations do
  use Ecto.Migration

  def change do
    create table(:site_configurations) do
      add :webhook_base_url, :string
      add :app_token, :string
      add :site_id, :string
      add :endpoint, :string
    end
  end
end
