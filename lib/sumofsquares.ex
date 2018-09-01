defmodule Sumofsquares do
  @moduledoc """
  Documentation for Sumofsquares.

  Includes a function distribute/2 which checks whether a sum of range of numbers is a perfect square concurrently using Actor Model

  ### Actor Model:
  An actor is a computational entity that, in response to a message it receives, can concurrently:

    * send a finite number of messages to other actors;
    * create a finite number of new actors;
    * designate the behavior to be used for the next message it receives
  """

  @doc """
  Distributes sum problems to multiple actors by sending messages and waiting for the response to be received

  Returns a list of integers which indicate the starting sequence or an empty list if there are no sequences whose sum of squares is a perfect square

  ##Examples
    iex> Sumofsquares.with_distribution(3,2)
    [3]
    iex> Sumofsquares.with_distribution(40,24)
    [1,9,20,25]
  """
  def with_distribution(n, k) do
    parent = self()

    processes =
      Enum.map(1..n, fn e ->
        spawn_link(fn ->
          send(parent, {self(), check_sum_of_squares_is_perfect_square(e, e + k - 1)})
        end)
      end)

    Enum.map(processes, fn pid ->
      receive do
        {^pid, result} -> result
      end
    end)
    |> Enum.filter(fn x -> !is_nil(x) end)
  end

  @doc """
  A function to check sum of range of squares of numbers is a perfect square without distribution

  Returns a list of integers which indicate the starting sequence or an empty list if there are no sequences whose sum of squares is a perfect square

  ##Examples
    iex> Sumofsquares.without_distribution(3,2)
    [3]
    iex> Sumofsquares.without_distribution(40,24)
    [1,9,20,25]
  """
  def without_distribution(n,k) do
    Enum.map(1..n, fn e -> check_sum_of_squares_is_perfect_square(e, e + k - 1) end) 
    |> Enum.filter(fn x -> !is_nil(x) end)
  end
  
  # A private function to check whether the sum of sequence between `lower_bound` and
  # `upper bound` is a perfect square
  # Returns the `lower_bound` if that is true or `nil` if false
  defp check_sum_of_squares_is_perfect_square(lower_bound, upper_bound) do
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
