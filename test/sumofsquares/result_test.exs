defmodule Sumofsquares.ResultTest do
  use ExUnit.Case

  setup do
    {:ok, result} = Sumofsquares.Result.start_link([])
    %{result: result}
  end

  test "starts an agent normally without errors", %{result: result} do
    assert is_pid(result)
  end

  test "agent is initially empty", %{result: result} do
    assert Enum.empty?(Sumofsquares.Result.get_result(result))
  end

  test "agent has value after put", %{result: result} do
    Sumofsquares.Result.put(result, 1)
    assert Sumofsquares.Result.get_result(result) == [1]
  end

  test "agent can concatanate two arrays using put_bulk", %{result: result} do
    Sumofsquares.Result.put_bulk(result, [1,2,3,4])
    assert Sumofsquares.Result.get_result(result) == [1,2,3,4]
    Sumofsquares.Result.put_bulk(result, [5,6,7,8])
    assert Sumofsquares.Result.get_result(result) == [5,6,7,8,1,2,3,4]
  end
end
