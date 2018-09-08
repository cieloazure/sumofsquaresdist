defmodule Sumofsquares.SubproblemWorkerTest do
  use ExUnit.Case

  setup do
    {:ok, result} = Sumofsquares.Result.start_link([])
    %{result: result}
  end

  test "should update the state of the agent with the correct solution to the subproblem", %{
    result: result
  } do
    Sumofsquares.SubproblemWorker.solve(1, 40, 24, result)
    assert Sumofsquares.Result.get_result(result) == [1, 9, 20, 25]
  end

  test "should not update the state of the agent if there is no solution", %{result: result} do
    Sumofsquares.SubproblemWorker.solve(1, 40, 25, result)
    assert Sumofsquares.Result.get_result(result) == []
  end

  @tag :pending
  test "when lower bound and upper bound is equal" do
  end

  @tag :pending
  test "when lower bound is greater than upper bound" do
  end

  @tag :pending
  test "when sequence length is an invalid number (<= 0)" do
  end

  @tag :pending
  test "when agent is not valid instance" do
  end
end
