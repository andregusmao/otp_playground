defmodule OtpPlayground.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      OtpPlayground.CalculatorSupervisor,
      OtpPlayground.AuditServer,
      OtpPlayground.MetricsServer,
      OtpPlayground.UserSupervisor,
      {Task.Supervisor, name: OtpPlayground.TaskSupervisor},
      OtpPlayground.JobManager
    ]

    Supervisor.start_link(
      children,
      strategy: :rest_for_one,
      name: OtpPlayground.Supervisor
    )
  end
end
