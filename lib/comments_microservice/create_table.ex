defmodule Comments.Repo.Migrations.CreateComments do
  use Ecto.Migration

  def change do
    create table(:comment, primary_key: false) do
      add :uuid, :uuid, primary_key: true
      add :author_id, :integer, null: false
      add :timelapse_id, :integer, null: false
      add :comment_hash, :string, null: false
      add :timestamp, :utc_datetime
    end
  end
end
