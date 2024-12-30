# this is supposed to be a port of the chatbot-kinda program at
# https://gist.github.com/essnine/2affd9b71c9cf58d7d19b8e3e4298fdf

import GenServer
import Map

defmodule Program do
  defstruct next_id: 1, entries: %{}

  def init do
    Program.programState() = %{init: false}
  end

  def hello do
    IO.puts("hello")
    Program.programState() |> put(:init, true)
  end

  def getState do
    IO.puts(Program.programState())
  end
end
