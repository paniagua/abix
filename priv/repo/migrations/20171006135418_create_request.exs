defmodule Abix.Repo.Migrations.CreateRequest do
  use Ecto.Migration

  def change do
    create table(:requests) do
      add :request_id, :string
      add :timeout, :integer
      add :site_id, :string
      add :platform, :string
      add :authorization, :string
      add :visit_session_id, :string
      add :sender_id, :string
      add :message, :string
      timestamps()
    end
  end
end
