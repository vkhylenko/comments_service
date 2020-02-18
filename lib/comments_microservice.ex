defmodule CommentsMicroservice do

  def validation_insert(value) do
    uuid = Ecto.UUID.generate()
    %{"author_id" => author_id, "timelapse_id" => timelapse_id, "comment" => comment, "timestamp" => timestamp} = Poison.decode!(value)
    import Ecto.Query, only: [from: 2]
    cond do
      String.length(comment) != 0 -> #check if date in [date-1s, date+1s]
        comment_hash_recieve = :crypto.hash(:sha256, comment)
        |>Base.encode16()
        |>String.downcase()


        timestamp_conv = DateTime.from_unix!(timestamp)
        timestamp_conv_low = DateTime.add(timestamp_conv, -1, :second)
        timestamp_conv_high = DateTime.add(timestamp_conv, 1, :second)

        query = from u in "comment",
          where: u.timestamp >= ^timestamp_conv_low and u.timestamp <= ^timestamp_conv_high
          and u.comment_hash == ^comment_hash_recieve,
          select: {u.uuid, u.comment_hash}

        results_comments = Comments.Repo.all(query)
        cond do
          results_comments == [] -> #insert
            record = %CommentsMicroservice.Comments{
              author_id: author_id,
              timelapse_id: timelapse_id,
              comment_hash: comment_hash_recieve,
              timestamp: timestamp_conv,
              uuid: uuid
            }
            Comments.Repo.insert!(record)
            fin_comment = Poison.encode!(%{"uuid" => uuid, "author_id" => author_id, "timelapse_id" => timelapse_id, "comment" => comment, "timestamp" => timestamp})
            CommentProducer.send_my_message({"ok", fin_comment}, "new_comment")
            CommentProducer.send_my_message({"answer", "Comment created"}, "a_create_comment")
          results_comments != [] -> #insert
            IO.puts("Error, you have already had this comment!")
            CommentProducer.send_my_message({"answer", "Comment isn't created"}, "a_create_comment")
        end
      String.length(comment) == 0 ->
        IO.puts("Error, comment can't be empty!")
        CommentProducer.send_my_message({"answer", "Comment isn't created"}, "a_create_comment")
    end
  end

  def comment_update(value) do
    import Ecto.Query, only: [from: 2]
    %{"uuid" => uuid, "comment" => comment} = Poison.decode!(value)
    cond do
      String.length(comment) != 0 ->
        comment_hash_recieve = :crypto.hash(:sha256, comment)
        |>Base.encode16()
        |>String.downcase()

        Comments.Repo.get_by(CommentsMicroservice.Comments, uuid: uuid)
        |> Ecto.Changeset.change(%{comment_hash: comment_hash_recieve})
        |> Comments.Repo.update!()

        query = from u in "comment",
          where: u.uuid == ^uuid,
          select: {u.uuid, u.author_id, u.timelapse_id, u.timestamp}

        result_comments = Comments.Repo.all(query)
        result_fin = Tuple.append(Enum.at(result_comments, 0), comment)

        update_fin = Poison.encode!(%{"uuid" => Enum.at(Tuple.to_list(result_fin), 0), "author_id" => Enum.at(Tuple.to_list(result_fin), 1),
         "timelapse_id" => Enum.at(Tuple.to_list(result_fin), 2), "comment" => Enum.at(Tuple.to_list(result_fin), 4),
         "timestamp" => DateTime.to_unix(DateTime.from_naive!(Enum.at(Tuple.to_list(result_fin), 3), "Etc/UTC"))})
        update_fin = Poison.encode!(%{})
        CommentProducer.send_my_message({"ok", update_fin}, "new_comment")
      String.length(comment) == 0 ->
        IO.puts("Error, comment can't be empty!")
    end
  end

  def comments_amount(value) do
    import Ecto.Query, only: [from: 2]
    %{"timelapse_id" => timelapse_id} = Poison.decode!(value)

    query = from u in "comment",
      where: u.timelapse_id == ^timelapse_id,
      select: count(u.uuid)

    result_count = Comments.Repo.all(query)
    result_fin = Poison.encode!(%{"count"=>List.first(result_count), "timelapse_id" =>timelapse_id})
    CommentProducer.send_my_message({"ok", result_fin}, "comments_amount")
  end

  def comment_delete(value) do
    %{"uuid" => uuid} = Poison.decode!(value)
    comment_to_delete = CommentsMicroservice.Comments |> Comments.Repo.get(uuid)
    Comments.Repo.delete(comment_to_delete)
  end


end
