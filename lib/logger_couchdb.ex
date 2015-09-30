defmodule LoggerCouchdb do
  use GenEvent

  alias ComfyCouch.Database
  alias ComfyCouch.Couchdb
  alias ComfyCouch.Document

  @type path      :: String.t
  @type level     :: Logger.level
  @type metadata  :: [atom]

  def init({__MODULE__, name}) do
    {:ok, configure(name, [])}
  end

  def handle_call({:configure, opts}, %{name: name}) do
    {:ok, :ok, configure(name, opts)}
  end

  def handle_call(:url, %{url: url} = state) do
    {:ok, {:ok, url}, state}
  end

  def handle_call(:server_info, state) do
    {:ok, info} = Database.server_info
    {:ok, {:ok, info}, state}
  end

  def handle_event({level, _gl, {Logger, msg, ts, md}}, %{level: min_level} = state) do
    if is_nil(min_level) or Logger.compare_levels(level, min_level) != :lt do
      log_event(level, msg, ts, md, state)
    else
      {:ok, state}
    end
  end

  defp log_event(level, msg, ts, md, %{metadata: metadata} = state) do
    start_db(state)
    %{level: level, msg: msg, ts: ts, md: md, metadata: metadata}
    |> Document.save
    {:ok, state}
  end

  defp start_db(%{url: nil, database: database}) do
    Couchdb.start
    {:ok, _} = Database.use_or_create(database)
  end

  defp start_db(%{url: url, database: database}) do
    Couchdb.start(url)
    {:ok, _} = Database.use_or_create(database)
  end

  defp configure(name, opts) do
    env = Application.get_env(:logger, name, [])
    opts = Keyword.merge(env, opts)
    Application.put_env(:logger, name, opts)

    url      = Keyword.get(opts, :url)
    database = Keyword.get(opts, :database, "logger_couchdb")
    level    = Keyword.get(opts, :level)
    metadata = Keyword.get(opts, :metadata, [])

    %{name: name, url: url, database: database, level: level, metadata: metadata}
  end
end
