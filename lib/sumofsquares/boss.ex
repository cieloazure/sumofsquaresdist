defmodule Sumofsquares.Boss do
  use GenServer

  # Optimal number of workers
  # TODO: Find optimal number of workers
  # Constant
  @num_workers 100 

  # Subproblem size for each worker
  # TODO: Find optimal subproblem size
  # Constant
  @subproblem_size  1000

  # Client API
  
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def calculate(server, limit, sequence_length) do
    GenServer.cast(server, {:solve, limit, sequence_length})
  end

  def get_results(server) do
    GenServer.call(server, {:result})
  end

  # Server callbacks
 
  def init(:ok) do
    IO.puts "initiating....."
    # Process references
    # State
    refs = %{}

    # Maintain a set of subproblems to be solved
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


  def handle_call({:result}, _from, {refs, results, next_subproblem_index, limit, sequence_length}) do
    IO.puts "in handle_call...."
    {:reply, Sumofsquares.Result.get_result(results), {refs, results, next_subproblem_index, limit, sequence_length}}
  end

  def handle_cast({:solve, n, k}, {refs, results, next_subproblem_index, limit, sequence_length}) do
    IO.puts "in handle cast..."
    limit = n
    sequence_length = k
    {refs, next_subproblem_index} = spawn_workers(refs, results, next_subproblem_index, limit, sequence_length)
    {:noreply, {refs, results, next_subproblem_index, limit, sequence_length}}
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, {refs, results, next_subproblem_index, limit, sequence_length}) do
    IO.puts "Got down message from a process, Processing next subproblem....."
    {_v, refs} = Map.pop(refs, ref)
    {refs, next_subproblem_index} = spawn_workers(refs, results, next_subproblem_index, limit, sequence_length)
    {:noreply, {refs, results, next_subproblem_index, limit, sequence_length}}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

  defp spawn_workers(refs, results, next_subproblem_index, limit, sequence_length) do
    IO.puts "in spawn_workers!"
    if map_size(refs) < @num_workers && next_subproblem_index <= limit do
      IO.puts "spawing a worker..." 
      pid = Process.spawn(Sumofsquares.SubproblemWorker, :solve, [next_subproblem_index, next_subproblem_index + @subproblem_size - 1, sequence_length, results], [])
      ref = Process.monitor(pid)
      refs = Map.put(refs, ref, pid)
      next_subproblem_index = next_subproblem_index + @subproblem_size
      spawn_workers(refs, results, next_subproblem_index, limit, sequence_length)
    else
      IO.puts "No more free workers available or no more subproblems remaining"
      {refs, next_subproblem_index}
    end
  end
end
