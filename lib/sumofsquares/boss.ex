defmodule Sumofsquares.Boss do
  @moduledoc """
  A module for managing the sum of squares problem in a concurrent environment

  Has two parts: 1) Client API 2) Server Callbacks

  1) Client API - It defines the methods for interacting with the Boss which implements GenServer
  Behaviour
  2) Server Callbacks - If defines the behaviour which is invoked when GenServer specific callbacks
  are initiated
  """
  use GenServer, restart: :transient
  require Logger
  @compile {:parse_transform, :ms_transform}

  # Constants Definition

  # Optimal number of workers
  # TODO: Find optimal number of workers
  # TODO: Check if the constant can be moved to runtime
  # Constant
  @num_workers 200

  # Subproblem size for each worker
  # TODO: Find optimal subproblem size
  # TODO: Check if the constant can be moved to runtime
  # Constant
  @subproblem_size 100000

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

  def calculate(n, k) do
    GenServer.cast(Sumofsquares.Boss, {:solve_v2, n, k})
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
    #workers table
    workers = :ets.new(:workers, [:set, :protected])

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

    workers = spawn_subproblem_workers(workers)

    {:ok, {workers, results, next_subproblem_index, limit, sequence_length}}
  end

  def handle_cast({:solve_v2, limit, sequence_length}, {workers, results, next_subproblem_index, _limit, _sequence_length}) do
    {workers, results, next_subproblem_index} = distribute_subproblems(workers, results, next_subproblem_index, limit, sequence_length, nil)
    {:noreply, {workers, results, next_subproblem_index, limit, sequence_length}}
  end

  def handle_call({:get_results}, _from, {workers, results, next_subproblem_index, _limit, _sequence_length} = state) do
    {:reply, Sumofsquares.Result.get_result(results),state}
  end

  def handle_info({:execution_complete, p}, {workers, results, next_subproblem_index, limit, sequence_length}) do
    #IO.puts "in execution complete"
    #IO.inspect :ets.match_object(workers, {:_, :_, :_})
    #IO.inspect p

    f = :ets.fun2ms(fn({ref, pid, _status}) when pid == p -> {ref, pid, :idle} end)
    :ets.select_replace(workers, f)

    {workers, results, next_subproblem_index} = if next_subproblem_index < limit do
      distribute_subproblems(workers, results, next_subproblem_index, limit, sequence_length, p)
    else
      {workers, results, next_subproblem_index}
    end

    w = :ets.match_object(workers, {:_, :_, :_})
    #IO.inspect Enum.all?(w, fn worker -> elem(worker, 2) == :idle end)
    #IO.inspect next_subproblem_index
    #IO.inspect limit

    if Enum.all?(w, fn worker -> elem(worker, 2) == :idle end) and next_subproblem_index > limit  do
      IO.inspect Sumofsquares.Result.get_result(results)
    end

    {:noreply, {workers, results, next_subproblem_index, limit, sequence_length}}
  end
 
  defp spawn_subproblem_workers(workers) do
    current_worker_table_size = length(:ets.match_object(workers, {:_, :_, :_}))
    if current_worker_table_size < @num_workers do
      pid = Process.spawn(Sumofsquares.SubproblemWorker, :loop_acceptor, [self()], [])
      ref = Process.monitor(pid)
      :ets.insert(workers, {ref, pid, :idle})
      spawn_subproblem_workers(workers)
    else
      workers
    end
  end

  defp distribute_subproblems(workers, results, next_subproblem_index, limit, sequence_length, pid) do
    #IO.puts "distribute"
    #IO.inspect :ets.match_object(workers, {:_, :_, :idle})
    #IO.inspect pid
    first_idle_worker= List.first(:ets.match_object(workers, {:_, :_, :idle}))
    idle_worker =if !is_nil(first_idle_worker) do
      pid || elem(first_idle_worker, 1)
    else
      nil
    end

    ##IO.puts "idle worker"
    ##IO.inspect idle_worker

    if !is_nil(idle_worker) and next_subproblem_index < limit do
      lb = next_subproblem_index
      ##IO.inspect lb
      ub = min(next_subproblem_index + @subproblem_size - 1, limit)
      ##IO.inspect ub
      ##IO.inspect idle_worker
      send_new_subproblem(idle_worker, lb, ub, sequence_length, results) 

      f = :ets.fun2ms(fn({ref, pid, _status}) when pid == idle_worker -> {ref, pid, :busy} end)
      :ets.select_replace(workers, f)

      next_subproblem_index = min(next_subproblem_index + @subproblem_size, limit + 1)
      distribute_subproblems(workers, results, next_subproblem_index, limit, sequence_length, nil)
    else
      {workers, results, next_subproblem_index}
    end
  end

  defp send_new_subproblem(pid, lb, ub, k, agent) do
    ##IO.puts "sending new subproblem"
    send(pid, {:solve_new_subproblem, lb, ub, k, agent})
  end
end
