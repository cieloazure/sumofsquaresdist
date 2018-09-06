defmodule Sumofsquares.Result do 
  use Agent

  def start_link(_opts) do
    Agent.start_link(fn -> [] end)
  end

  def put(result, new_result_value) do
    Agent.update(result, fn old_results -> [new_result_value | old_results] end)
  end

  def put_bulk(result, new_result_values) do
    Agent.update(result, fn old_results -> new_result_values ++ old_results end)
  end

  def get_result(result) do
    Agent.get(result, fn results -> results end)
  end
end
