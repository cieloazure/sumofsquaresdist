defmodule Sumofsquares.SubproblemWorker do
  @moduledoc """
  A module to find the solution to the sum of squares problem

  The problem states that given a range of numbers `n` we have to find
  a sequence of `k` numbers from any number `i` in `n` such that sum of squares
  of these numbers is a number who itself is perfect square
  """
  # TODO: Check if this module can be made to use the behaviour of Task
  # TODO: Pass a function instead of an agent to update the state in order to
  # decouple the behaviour

  @doc """
  A function to keep receiving request for subproblems

  It accepts the caller's pid as argument
  ##Example
  iex> {:ok, boss} = Sumofsquares.Boss.start_link(name: Boss)
  iex> Sumofsquares.SubproblemWorker.loop_acceptor(boss)
  """
  def loop_acceptor(caller) do
    receive do
      {:solve_new_subproblem, lb, ub, k, agent} -> solve(lb, ub, k, agent, caller)
    end

    loop_acceptor(caller)
  end

  @doc """
  A function to compute the solution to the sum of squares problem

  Accepts lower bound, upper bound, sequence length, an agent to return results and a calling process to inform of its completed execution as parameters
  Returns `nil`
  ##Example
  iex> result = Sumofsquares.Result.start_link([])
  iex> Sumofsquares.SubproblemWorker.solve(1, 40, 24, results, caller)
  """
  def solve(lb, ub, k, agent, caller) do
    sol =
      Enum.map(lb..ub, fn num -> solve_unit_problem(num, num + k - 1) end)
      |> Enum.filter(fn num -> !is_nil(num) end)

    if !is_nil(sol), do: Sumofsquares.Result.put_bulk(agent, sol)
    send(caller, {:execution_complete, self()})
  end

  @doc """
  A function to specify the child process specifications to the supervisor

  Useful in case of starting a worker under a supervisor

  Not used
  """
  def child_spec([lb, ub, k]) do
    %{
      id: Sumofsquares.SubproblemWorker,
      start: {Sumofsquares.SubproblemWorker, :solve, [lb, ub, k]},
      type: :worker,
      restart: :temporary
    }
  end

  # A function to solve one unit of problem
  # Takes lower bound and upper bound as arguments
  # And tells whether the sum of squares of sequence between lower bound and upper bound
  # is a perfect square
  # If it is a perfect square it returns the lower bound
  defp solve_unit_problem(lower_bound, upper_bound) do
    upper_sum = upper_bound * (upper_bound + 1) * (upper_bound * 2 + 1) / 6

    sum =
      cond do
        lower_bound == 1 ->
          upper_sum

        lower_bound > 1 ->
          lower_sum = (lower_bound - 1) * lower_bound * ((lower_bound - 1) * 2 + 1) / 6
          upper_sum - lower_sum
      end

    sqrt = :math.sqrt(sum)
    floored_sqrt = Float.floor(sqrt)

    if sqrt - floored_sqrt == 0 do
      lower_bound
    end
  end
end
