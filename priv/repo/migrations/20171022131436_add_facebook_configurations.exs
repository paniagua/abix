defmodule Abix.Repo.Migrations.AddFacebookConfigurations do
  use Ecto.Migration

  def change do
    create table(:facebook_configurations) do
      add :page_id, :string
      add :verification_token, :string
      add :page_access_token, :string
      add :site_id, :string
    end
  end
end
