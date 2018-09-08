defmodule Sumofsquares.BossTest do
  use ExUnit.Case

  describe "initiation of boss" do
    @tag :pending
    test "starts the boss normally without any error" do
    end

    @tag :pending
    test "will initialize the state of the boss" do
    end
  end

  describe "concurrency of the boss" do
    @tag :pending
    test "it is faster than executing it sequentially for a given number of workers and a subproblem size" do
    end

    @tag :pending
    test "it utilizes multiple cores to achieve the result" do
    end

    @tag :pending
    test "the ratio of CPU time to real time is close to 1" do
    end
  end

  describe "problem size of the boss" do
    @tag :pending
    test "successfully solves for small problem size" do
    end

    @tag :pending
    test "successfully solves for large problem size" do
    end

    @tag :pending
    test "largest problem size" do
    end
  end

  describe "logic of the boss" do
    @tag :pending
    test "if next_subproblem_index + @subproblem_size > limit it should increment only till limit" do
    end

    @tag :pending
    test "when a down message is receive the entry from refs is removed" do
    end

    @tag :pending
    test "when a down message is received and there is space in the free workers and there are still subproblems to be solved" do
    end

    @tag :pending
    test "when a down message is receieved and there is space in the free workers and no more subproblems to be solved" do
    end

    @tag :pending
    test "when a down message is received and there is no space in the free workers and subproblems still to be solved" do
    end

    @tag :pending
    test "when a continue message is received the process will return the results" do
    end
  end
end
