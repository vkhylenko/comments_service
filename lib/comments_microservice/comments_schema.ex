defmodule CommentsMicroservice.Comments do
  use Ecto.Schema
  @primary_key false #disable the generation of a primary key field

  schema "comment" do
    field :uuid, :string, primary_key: true
    field :author_id, :integer, null: false
    field :timelapse_id, :integer, null: false
    field :comment_hash, :string, null: false
    field :timestamp, :utc_datetime
  end
end
