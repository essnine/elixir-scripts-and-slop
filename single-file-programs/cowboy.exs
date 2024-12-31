Mix.install([
  {:plug_cowboy, "~> 2.5"}
])

defmodule Router do
  use Plug.Router
  plug(Plug.Logger)
  plug(:match)
  plug(:dispatch)

  get "/" do
    send_resp(conn, 200, "Hello!")
  end

  match _ do
    send_resp(conn, 404, "not found")
  end
end

plug_cowboy = {Plug.Cowboy, plug: Router, scheme: :http, port: 4001}

require Logger
Logger.info("Starting #{inspect(plug_cowboy)}")
{:ok, pid} = Supervisor.start_link([plug_cowboy], strategy: :one_for_one)
Logger.info("Pid is #{inspect(pid)}")

unless IEx.started?() do
  Process.sleep(:infinity)
end
