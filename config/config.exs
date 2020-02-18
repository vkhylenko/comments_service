import Config

config :comments_microservice, Comments.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "postgres",
  # username: "khylenko",
  # password: "pass",
  username: "postgres",
  password: "postgres",
  hostname: "db"

config :comments_microservice, ecto_repos: [Comments.Repo]

config :kaffe,
producer: [
  endpoints: [kafka: 9092],
  topics: ["new_comment", "comments_amount", "a_create_comment"], # a list of topics i plan to produce messages to
]

config :kaffe,
consumer: [
  endpoints: [kafka: 9092],
  topics: ["create_comment", "update_comment", "get_amount_comm"],     # the topic(s) that will be consumed
  consumer_group: "comments-consumer-group",   # the consumer group for tracking offsets in Kafka
  message_handler: CommentConsumer,           # the module that will process messages
]
