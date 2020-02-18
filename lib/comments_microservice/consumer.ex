defmodule CommentConsumer do
    def handle_message((%{key: key, value: value} = message)) do
      IO.inspect(message)
      cond do
        message[:topic] == "create_comment" ->
          CommentsMicroservice.validation_insert(value)
        message[:topic] == "update_comment" ->
          IO.puts("OKK")
          CommentsMicroservice.comment_update(value)
        message[:topic] == "get_amount_comm" ->
          CommentsMicroservice.comments_amount(value)
      end
      #IO.inspect(message)
      IO.puts("#{key}: #{value}")
      :ok
    end
end
