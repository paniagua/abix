defmodule Abix.Repo.Migrations.AddTwilioConfigurations do
  use Ecto.Migration

  def change do
    create table(:twilio_configurations) do
      add :account_sid, :string
      add :token, :string
      add :messaging_service, :string
      add :site_id, :string
    end
  end
end
