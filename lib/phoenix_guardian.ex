defmodule PhoenixGuardian do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PhoenixGuardian.Supervisor]
    Supervisor.start_link(children(Mix.env), opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    PhoenixGuardian.Endpoint.config_change(changed, removed)
    :ok
  end

  def children(env) when env != "test" do
    import Supervisor.Spec, warn: false
    children() ++ [worker(GuardianDb.ExpiredSweeper, [])]
  end

  def children do
    import Supervisor.Spec, warn: false

    [
      # Start the endpoint when the application starts
      supervisor(PhoenixGuardian.Endpoint, []),
      # Start the Ecto repository
      worker(PhoenixGuardian.Repo, []),

      # Here you could define other workers and supervisors as children
      # worker(PhoenixGuardian.Worker, [arg1, arg2, arg3]),
    ]
  end
end
