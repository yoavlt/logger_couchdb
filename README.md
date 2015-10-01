LoggerCouchdb
=============

CouchDB logger driver for Elixir

# Installation

To install it, simply add the following line to your mix.exs:

```elxilr
  defp deps do
    [
      {:logger_couchdb, git: "https://github.com/yoavlt/logger_couchdb.git"}
    ]
  end
```


Then, write config file as follows:

```elixir
config :logger, backends: [:console, {LoggerCouchdb, :info}]

config :logger, :info,
  level: :info,
  database: "logger_sample",
  url: "couchdb url",
  format: "$time $metadata[$level] $message"
```
