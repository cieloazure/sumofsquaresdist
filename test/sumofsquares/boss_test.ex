defmodule Sumofsquares.BossTest do
  use ExUnit.Case

  describe "initiation of boss" do
    @tag :pending
    test "starts the boss normally without any error" do
    end

    @tag :pending
    test "will initialize the state of the boss" do
    end

    @tag :pending
    test "will spawn worker processes waiting for input" do
    end

    @tag :pending
    test "ets table of process will say :idle initially" do
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
    test "the ratio of CPU time to real time greater than 1" do
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
    test "after the worker has finished solving the subproblem it's entry changes to :busy" do
    end

    @tag :pending
    test "after the worker has finished solving the subproblem it's entry changes to :busy and it is given another problem to solve if there are problems remaining" do
    end

    @tag :pending
    test "after the worker has finished solving the subproblem it's entry changes to :busy and it is not given another problem to solve if there are no problems remaining" do
    end

    @tag :pending
    test "after all sub problems have been solved it returns the results" do
    end
    
    @tag :pending
    test "if next_subproblem_index + @subproblem_size > limit it should increment only till limit" do
    end
  end
end
