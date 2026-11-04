defmodule OtpPlayground.JobManager do
  use GenServer

  # API pública

  def start_link(opts \\ []) do
    initial_state = %{
      jobs: %{},
      monitors: %{}
    }

    GenServer.start_link(
      __MODULE__,
      initial_state,
      Keyword.put(opts, :name, __MODULE__)
    )
  end

  def list_jobs do
    GenServer.call(__MODULE__, :list_jobs)
  end

  def start_job(fun) when is_function(fun, 0) do
    GenServer.call(__MODULE__, {:start_job, fun})
  end

  # Callbacks

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call(:list_jobs, _from, state) do
    {:reply, state.jobs, state}
  end

  @impl true
  def handle_call({:start_job, fun}, _from, state) do
    job_id = System.unique_integer([:positive, :monotonic])

    result =
      Task.Supervisor.start_child(
        OtpPlayground.TaskSupervisor,
        fn ->
          job_result = fun.()

          if job_result != :skip_notification do
            GenServer.cast(
              __MODULE__,
              {:job_completed, job_id, job_result}
            )
          end
        end
      )

    case result do
      {:ok, pid} ->
        monitor_ref = Process.monitor(pid)

        job = %{
          id: job_id,
          pid: pid,
          monitor_ref: monitor_ref,
          status: :running,
          result: nil
        }

        new_state =
          state
          |> put_in([:jobs, job_id], job)
          |> put_in([:monitors, monitor_ref], job_id)

        {:reply, {:ok, job_id}, new_state}

      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  @impl true
  def handle_cast({:job_completed, job_id, result}, state) do
    new_state =
      update_in(state, [:jobs, job_id], fn job ->
        %{job | status: :completed, result: result}
      end)

    {:noreply, new_state}
  end

  @impl true
  def handle_info({:DOWN, ref, :process, _pid, reason}, state) do
    job_id = Map.get(state.monitors, ref)

    new_state =
      case job_id do
        nil ->
          state

        job_id ->
          job = Map.fetch!(state.jobs, job_id)

          cond do
            reason == :normal and job.status == :running ->
              update_in(state, [:jobs, job_id], fn current_job ->
                %{current_job | status: :unknown}
              end)

            reason == :normal ->
              state

            job.status == :running ->
              update_in(state, [:jobs, job_id], fn current_job ->
                %{current_job | status: :failed, result: nil}
              end)

            true ->
              state
          end
      end

    final_state =
      update_in(new_state, [:monitors], fn monitors ->
        Map.delete(monitors, ref)
      end)

    {:noreply, final_state}
  end
end
