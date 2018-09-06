defmodule Sumofsquares.SubproblemWorker do

  def child_spec([lb, ub, k]) do
    %{
      id: Sumofsquares.SubproblemWorker,
      start: {Sumofsquares.SubproblemWorker, :solve, [lb, ub, k]},
      type: :worker,
      restart: :temporary
    }
  end

  def solve(lb, ub, k, agent) do
    sol = Enum.map(lb..ub, fn num -> solve_unit_problem(num, num + k - 1) end) 
    |> Enum.filter(fn num -> !is_nil(num) end) 
    Sumofsquares.Result.put_bulk(agent, sol)
  end


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
