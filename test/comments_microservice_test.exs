defmodule CommentsMicroserviceTest do
  use ExUnit.Case
  doctest CommentsMicroservice

  test "greets the world" do
    assert CommentsMicroservice.hello() == :world
  end
end
