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
  @num_workers System.schedulers_online

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
    # workers table
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

  @doc """
  Callback to handle messages of type `{:solve_v2, limit, sequence_length}`

  This callback is responsible for distributing the subproblems among workers
  """
  def handle_cast(
        {:solve_v2, limit, sequence_length},
        {workers, results, next_subproblem_index, _limit, _sequence_length}
      ) do
    {workers, results, next_subproblem_index} =
      distribute_subproblems(workers, results, next_subproblem_index, limit, sequence_length, nil)

    {:noreply, {workers, results, next_subproblem_index, limit, sequence_length}}
  end

  @doc """
  Callback to give next subproblem to the worker who has finished his processing

  This callback is also responsible for displaying the results and stopping the system
  """
  def handle_info(
        {:execution_complete, p},
        {workers, results, next_subproblem_index, limit, sequence_length}
      ) do
    f = :ets.fun2ms(fn {ref, pid, _status} when pid == p -> {ref, pid, :idle} end)
    :ets.select_replace(workers, f)

    {workers, results, next_subproblem_index} =
      if next_subproblem_index < limit do
        distribute_subproblems(workers, results, next_subproblem_index, limit, sequence_length, p)
      else
        {workers, results, next_subproblem_index}
      end

    w = :ets.match_object(workers, {:_, :_, :_})

    if Enum.all?(w, fn worker -> elem(worker, 2) == :idle end) and next_subproblem_index > limit do
      Enum.sort(Sumofsquares.Result.get_result(results))
      |> Enum.join("\n")
      |> IO.puts
      
      System.stop(0)
    end

    {:noreply, {workers, results, next_subproblem_index, limit, sequence_length}}
  end

  # End of Server Callbacks

  # Start of private functions
  # A private function to spawn workers and wait for subproblems
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

  # A private function to distribute subproblem among workers
  defp distribute_subproblems(
         workers,
         results,
         next_subproblem_index,
         limit,
         sequence_length,
         pid
       ) do
    first_idle_worker = List.first(:ets.match_object(workers, {:_, :_, :idle}))

    idle_worker =
      if !is_nil(first_idle_worker) do
        pid || elem(first_idle_worker, 1)
      else
        nil
      end

    if !is_nil(idle_worker) and next_subproblem_index < limit do
      lb = next_subproblem_index
      ub = min(next_subproblem_index + @subproblem_size - 1, limit)
      send_new_subproblem(idle_worker, lb, ub, sequence_length, results)

      f = :ets.fun2ms(fn {ref, pid, _status} when pid == idle_worker -> {ref, pid, :busy} end)
      :ets.select_replace(workers, f)

      next_subproblem_index = min(next_subproblem_index + @subproblem_size, limit + 1)
      distribute_subproblems(workers, results, next_subproblem_index, limit, sequence_length, nil)
    else
      {workers, results, next_subproblem_index}
    end
  end

  # A private fnction to send new subproblem to the worker
  defp send_new_subproblem(pid, lb, ub, k, agent) do
    send(pid, {:solve_new_subproblem, lb, ub, k, agent})
  end

  # End of private functions
end
