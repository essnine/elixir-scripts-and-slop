defmodule MyApp.Periodically do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{})
    IO.puts("GenServer running")
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_info(payload, state) do
    response = %{
      "key1" => "value1",
      "key2" => "value2"
    }

    {:noreply, Map.get(response, payload, "Unknown key")}
  end
end
