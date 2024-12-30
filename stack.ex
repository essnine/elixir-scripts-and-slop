# this is supposed to be a port of the chatbot-kinda program at
# https://gist.github.com/essnine/2affd9b71c9cf58d7d19b8e3e4298fdf

import GenServer
# import Map

# defmodule Program do
#   programState = %{init: false}

#   def hello do
#     IO.puts("hello")
#     programState |> put(:init, true)
#   end

#   def getState do
#     IO.puts(programState)
#   end
# end

defmodule Stack do
  use GenServer

  def start_link(default) when is_binary(default) do
    GenServer.start_link(__MODULE__, default)
  end

  def push(pid, element) do
    GenServer.cast(pid, {:push, element})
  end

  def pop(pid) do
    GenServer.call(pid, :pop)
  end

  # Server (callbacks)

  @impl true
  def init(elements) do
    initial_state = String.split(elements, ",", trim: true)
    {:ok, initial_state}
  end

  @impl true
  def handle_call(:pop, _from, state) do
    [to_caller | new_state] = state
    {:reply, to_caller, new_state}
  end

  @impl true
  def handle_cast({:push, element}, state) do
    new_state = [element | state]
    {:no_reply, new_state}
  end
end
