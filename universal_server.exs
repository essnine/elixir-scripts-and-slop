Mix.install([
  {:bandit, "~> 1.6.1"}
])

defmodule Router do
  use Plug.router
  # plug(Plug.logger)

  plug :match
  plug :dispatch

  get "/" do
    send_resp(conn, 200, "Hello, World!")
  end

  match _ do
    send_resp(conn, 404, "Not found.")
  end
end

webserver = {Bandit, plug: Router, scheme: :http, port: 4000}
{:ok, _} = Supervisor.start_link([webserver], strategy: :one_for_one)

unless IEx.started?() do
  Process.sleep(:infinity)
end
