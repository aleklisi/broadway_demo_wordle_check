# BroadwayDemo

**TODO: Add description**

## Installation

### Setup RabbitMQ
Start RabbitMQ in docker container in a separate terminal: `docker-compose up -d`.

Connect to the container:

```bash
docker exec -it broadway_demo_rabbitmq_1 /bin/bash
```

and add the test user:

```bash
rabbitmqctl add_user test test
rabbitmqctl set_user_tags test administrator
rabbitmqctl set_permissions -p / test ".*" ".*" ".*"
```

Then disconnect from the rabbit container using Ctrl+d.

### Queue

Based on [this](https://hexdocs.pm/broadway/rabbitmq.html) tutorial.

Create a queue named `my_queue`.
Get the dependencies `mix deps.get`.
Start an Elixir shell `iex -S mix`.

Connect to the RabbitMQ and create a queue named `my_queue`:

```elixir
options = [
  host: "localhost",
  port: 5672,
  username: "test",
  password: "test"
]
{:ok, connection} = AMQP.Connection.open(options)
{:ok, channel} = AMQP.Channel.open(connection)

case AMQP.Queue.declare(channel, "my_queue", durable: true) do
  :ok -> :ok
  {:ok, info} -> :ok
end
```

Press Ctrl+c twice to exit the Elixir shell.

Connect to the container and check if the queue was created:

```bash
docker exec -it broadway_demo_rabbitmq_1 /bin/bash

rabbitmqctl list_queues
```

should result in something like this:

```bash
I have no name!@ecfb76f11fdf:/$ rabbitmqctl list_queues
Timeout: 60.0 seconds ...
Listing queues for vhost / ...
name	messages
my_queue	0
```

```elixir
DataFeeder.feed_n_numbers(5)
```