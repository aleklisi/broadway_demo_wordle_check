#  See more https://hexdocs.pm/broadway/Broadway.html
#  and https://hexdocs.pm/broadway/rabbitmq.html
defmodule MyBroadway do
  use Broadway

  @word "abcde"
  alias Broadway.Message

  def start_link(_opts) do
    Broadway.start_link(__MODULE__,
      name: MyBroadway,
      # A producer defines the source of data.
      # In our case it is RabbitMQ queue.
      producer: [
        module: {
          BroadwayRabbitMQ.Producer,
          #  The :prefetch_count setting instructs RabbitMQ to
          # limit the number of unacknowledged messages a consumer
          # will have at a given moment
          # (except with a value of 0, which RabbitMQ treats as infinity).          
          on_failure: :reject,
          queue: "my_queue",
          connection: [
            host: "localhost",
            port: 5672,
            username: "test",
            password: "test"
          ],
          qos: [
            prefetch_count: 1
          ]
        },
        concurrency: 10
      ],
      processors: [
        default: [
          concurrency: 6
        ]
      ],
      batchers: [
        default: [
          batch_size: 7,
          batch_timeout: 3000,
          concurrency: 10
        ]
      ]
    )
  end

  @impl true
  def handle_message(_, message, _) do
    message
    |> Message.update_data(fn data -> {data, Wordle.color_word(data, @word)} end)
  end

  @impl true
  def handle_batch(_, messages, _, _) do
    list =
      messages
      |> Enum.map(fn e -> e.data end)

    IO.inspect(list, label: "Got batch")
    messages
  end
end
