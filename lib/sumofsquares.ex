defmodule Sumofsquares do
  use Application

  def start(_type, _args) do
    Sumofsquares.Supervisor.start_link(name: Sumofsquares.Supervisor)
  end
end
