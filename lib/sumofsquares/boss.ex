defmodule Sumofsquares.Boss do
  @moduledoc """
  A module for managing the sum of squares problem in a concurrent environment

  Has two parts: 1) Client API 2) Server Callbacks

  1) Client API - It defines the methods for interacting with the Boss which implements GenServer
  Behaviour
  2) Server Callbacks - If defines the behaviour which is invoked when GenServer specific callbacks
  are initiated
  """
  use GenServer
  require Logger

  # Constants Definition

  # Optimal number of workers
  # TODO: Find optimal number of workers
  # TODO: Check if the constant can be moved to runtime
  # Constant
  @num_workers 50

  # Subproblem size for each worker
  # TODO: Find optimal subproblem size
  # TODO: Check if the constant can be moved to runtime
  # Constant
  @subproblem_size 1000

  # Start of Client API

  @doc """
  A function to start the Boss with the given opts like `name`

  Returns a tuple containing :ok atom and Genserver process id

  ##Example:
  iex> {:ok, boss} = Sumofsquares.Boss.start_link(name: Boss)
  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @doc """
  A function to check whether sum of squares sequences of a specified length
  starting from 1 upto a certain limit is a perfect square concurrently

  Use GenServer.cast to create multiple processes without blocking the main thread

  Returns a atom saying :ok if the cast was successful

  #Example:
  iex> {:ok, boss} = Sumofsquares.Boss.start_link(name: Boss)
  iex> Sumofsquares.Boss.calculate(Boss, 1000000, 24)
  """
  def calculate(server, limit, sequence_length) do
    GenServer.cast(server, {:solve, limit, sequence_length})
  end

  # TODO: Figure out a better way to return the results
  @doc """
  A function to get the results from the state saved in the Sumofsquares.Boss

  Returns an array of results
  #Example:
  iex> {:ok, boss} = Sumofsquares.Boss.start_link(name: Boss)
  iex> Sumofsquares.Boss.get_results(Boss)
  """
  def get_results(server) do
    # refs should be empty
    # next_subproblem_index > n
    GenServer.call(server, {:result})
  end

  # End of Client API

  # Start of Server callbacks

  @doc """
  A GenServer behaviour callback which is called when a GenServer behaviour module is
  started using start_link

  Is responsible to initiate the state of the server

  Returns a tuple containing the state
  """
  def init(:ok) do
    # IO.puts "initiating...."
    # Process references
    # State
    refs = %{}

    # Next  subproblem to be solved
    # State
    next_subproblem_index = 1

    # Start result agent to maintain result state
    # State
    {:ok, results} = Sumofsquares.Result.start_link([])

    # limit
    limit = 0

    # sequence length
    sequence_length = 0

    {:ok, {refs, results, next_subproblem_index, limit, sequence_length}}
  end

  @doc """
  A GenServer callback to handle messages  with `:result` from the Client API

  Returns the state of the result agent
  """
  def handle_call(
        {:result},
        _from,
        {refs, results, next_subproblem_index, limit, sequence_length}
      ) do
    # IO.puts "in handle_call...."
    {:reply, Sumofsquares.Result.get_result(results),
     {refs, results, next_subproblem_index, limit, sequence_length}}
  end

  @doc """
  A GenServer callback to handle messages with `:solve` from the Client API

  Accepts the message with limit and sequence length as input and solves the problem
  concurrently by spawning multiple workers and monitoring their processes
  """
  def handle_cast({:solve, n, k}, {refs, results, next_subproblem_index, limit, sequence_length}) do
    Logger.info("In handle_cast...solving the problem")
    limit = n
    sequence_length = k

    {refs, next_subproblem_index} =
      spawn_workers(refs, results, next_subproblem_index, limit, sequence_length)

    {:noreply, {refs, results, next_subproblem_index, limit, sequence_length}}
  end

  # TODO: Check :DOWN message reason to check if it exited in a normal way
  @doc """
  A Genserver callback to handle messages with `:DOWN` message from the processes when a process
  exits

  This callback  will remove the process from the state of refs then will spawn additional workers if the problem is not yet solved
  """
  def handle_info(
        {:DOWN, ref, :process, _pid, _reason},
        {refs, results, next_subproblem_index, limit, sequence_length}
      ) do
    cont = {}
    Logger.info("In handle_info: Got down message from a process.....")
    {_v, refs} = Map.pop(refs, ref)

    Logger.debug(fn -> "In handle_info: Refs Map is of size " <> inspect(map_size(refs)) end)

    Logger.debug(fn ->
      "In handle_info: next subproblem index is " <> inspect(next_subproblem_index)
    end)

    {refs, next_subproblem_index} =
      spawn_workers(refs, results, next_subproblem_index, limit, sequence_length)

    cont = if next_subproblem_index > limit && map_size(refs) == 0, do: {:continue, :get_results}
    Logger.debug(fn -> "In handle_info: Value of cont is " <> inspect(cont) end)
    if !is_nil(cont) do
      {:noreply, {refs, results, next_subproblem_index, limit, sequence_length}, cont}
    else
      {:noreply, {refs, results, next_subproblem_index, limit, sequence_length}}
    end
  end

  # TODO: Define behaviour for messages other than `:DOWN`
  @doc """
  A GenServer callback to handle messages other than `:DOWN`
  """
  def handle_info(_msg, state) do
    Logger.info("In other handle_info")
    {:noreply, state}
  end

  # TODO: Return results in a string form with each entry on a new line
  @doc """
  A GenServer callback to handle continues with message `:get_results`

  Initiation of this callback signifies that there are no more subproblem to be solved
  and results are ready to be returned
  """
  def handle_continue(
        :get_results,
        {_refs, results, _next_subproblem_index, _limit, _sequence_length} = state
      ) do
    Logger.info("Got to continue....Sending the results")
    Logger.debug(fn -> inspect(Sumofsquares.Result.get_result(results)) end)
    IO.inspect(Sumofsquares.Result.get_result(results))
    {:noreply, state}
  end

  # A private function to spawn wokers
  # Checks for available spaces in workers and if there is a next subproblem to be solved
  # If the conditions above are met it will spawn a worker, update the state of
  # refs to indicate there is worker and also update the state of next_subproblem_index
  defp spawn_workers(refs, results, next_subproblem_index, limit, sequence_length) do
    Logger.info("In spawn_workers")
    Logger.debug(fn -> "In spawn_workers: Size of ref map is " <> inspect(map_size(refs)) end)

    Logger.debug(fn ->
      "In spawn_workers: Next subproblem index is " <> inspect(next_subproblem_index)
    end)

    {refs, next_subproblem_index} =
      if next_subproblem_index < limit and map_size(refs) < @num_workers do
        Logger.info("In spawn_workers: spawing a worker...")

        pid =
          Process.spawn(
            Sumofsquares.SubproblemWorker,
            :solve,
            [
              next_subproblem_index,
              min(next_subproblem_index + @subproblem_size - 1, limit),
              sequence_length,
              results
            ],
            []
          )

        ref = Process.monitor(pid)
        refs = Map.put(refs, ref, pid)

        Logger.debug(fn ->
          "In spawn_workers: Updated Size of ref map is " <> inspect(map_size(refs))
        end)

        next_subproblem_index = min(next_subproblem_index + @subproblem_size, limit + 1)

        Logger.debug(fn ->
          "In spawn_workers: Updated value of next_subproblem_index is " <>
            inspect(next_subproblem_index)
        end)

        spawn_workers(refs, results, next_subproblem_index, limit, sequence_length)
      else
        Logger.info(
          "In spawn_workers: No more free workers available or no more subproblems remaining"
        )

        {refs, next_subproblem_index}
      end
  end
end
