defmodule Sumofsquares.Result do 
  @moduledoc """
  An agent to maintain the state of the results calculated by the subworkers
  The state is a list which stores the elements
  Defines a API for using agent functions
  """
  use Agent

  @doc """
  Function to start the agent

  ##Example
  iex> result = Sumofsquares.Result.start_link([])
  """
  def start_link(_opts) do
    Agent.start_link(fn -> [] end)
  end

  @doc """
  Function to insert the new result value in the agent

  ##Example
  iex> result = Sumofsquares.Result.start_link([])
  iex> Sumofsquares.Result.put(result, 1) 
  """
  def put(result, new_result_value) do
    Agent.update(result, fn old_results -> [new_result_value | old_results] end)
  end

  @doc """
  Function to insert multiple values in the agent

  ##Example
  iex> result = Sumofsquares.Result.start_link([])
  iex> Sumofsquares.Result.put_bulk(result, [1,2]) 
  """
  def put_bulk(result, new_result_values) do
    Agent.update(result, fn old_results -> new_result_values ++ old_results end)
  end

  @doc """
  Function to get the state of the agent

  ##Example
  iex> result = Sumofsquares.Result.start_link([])
  iex> Sumofsquares.Result.put_bulk(result, [1,2,3,4]) 
  iex> Sumofsquares.Result.get_result(result)
  """
  def get_result(result) do
    Agent.get(result, fn results -> results end)
  end
end
