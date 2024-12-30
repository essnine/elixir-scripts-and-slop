defmodule QnaServer do
  use GenServer

  # Starting the GenServer
  def start_link(initial_state \\ %{}) do
    GenServer.start_link(__MODULE__, initial_state, name: __MODULE__)
  end

  # GenServer Callbacks

  # Initializes the state, initially an empty map or as provided
  def init(initial_state) do
    {:ok, initial_state}
  end

  # Handling synchronous calls
  def handle_call({:get_answer, question}, _from, state) do
    # Adding fuzzy matching logic
    threshold = 0.7
    # Use String.jaro_distance for fuzzy matching, check against each key in the map
    possible_matches =
      Enum.filter(Map.keys(state), fn key ->
        String.jaro_distance(question, key) >= threshold
      end)

    # If there are possible matches, fetch the most similar one (highest Jaro distance)
    case possible_matches do
      [] ->
        {:reply, :not_found, state}

      _ ->
        best_match = Enum.max_by(possible_matches, &String.jaro_distance(question, &1))
        answer = Map.fetch!(state, best_match)
        {:reply, answer, state}
    end
  end

  def handle_call({:add_qa, question, answer}, _from, state) do
    new_state = Map.put(state, question, answer)
    # Handling potential commas in questions and answers by escaping them
    File.write!(
      "qna_data.txt",
      Enum.map_join(new_state, "\n", fn {k, v} ->
        escaped_k = String.replace(k, ",", "\\,")
        escaped_v = String.replace(v, ",", "\\,")
        "#{escaped_k},#{escaped_v}"
      end)
    )

    {:reply, :ok, new_state}
  end

  def handle_call({:show_all}, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:available_commands}, _from, state) do
    commands = [
      "get_answer: Provide a question to retrieve an answer.",
      "add_qa: Provide a question and answer pair to add to the server.",
      "show_all: Display all question-answer pairs."
    ]

    {:reply, commands, state}
  end

  # API Functions for external use

  def get_answer(question) do
    GenServer.call(__MODULE__, {:get_answer, question})
  end

  def add_qa(question, answer) do
    GenServer.call(__MODULE__, {:add_qa, question, answer})
  end

  def show_all do
    GenServer.call(__MODULE__, {:show_all})
  end

  def available_commands do
    GenServer.call(__MODULE__, {:available_commands})
  end
end
