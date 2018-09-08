defmodule Sumofsquares.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    children = [
      {Sumofsquares.Boss, name: Sumofsquares.Boss}
      # TODO: Figure out whether a subproblem supervisor is needed to monitor
      # the subproblem worker processes
      # If it is needed, a dynamic supervisor would suit the best
      # { DynamicSupervisor, name: Sumofsquares.SubproblemSupervisor, strategy: :one_for_one }
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
