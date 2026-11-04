defmodule OtpPlayground.UserServer do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def child_spec(opts) do
    %{
      id: {__MODULE__, Keyword.fetch!(opts, :user_id)},
      start: {__MODULE__, :start_link, [opts]},
      restart: :temporary,
      shutdown: 5_000,
      type: :worker
    }
  end

  @impl true
  def init(opts) do
    state = %{
      user_id: Keyword.fetch!(opts, :user_id),
      requests_count: 0
    }

    {:ok, state}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_cast(:register_request, state) do
    new_state = Map.update!(state, :requests_count, &(&1 + 1))
    {:noreply, new_state}
  end

  @impl true
  def handle_cast(:stop, state) do
    {:stop, :normal, state}
  end

  @impl true
  def terminate(reason, state) do
    IO.puts("""
    UserServer encerrando...
    User ID: #{state.user_id}
    Motivo: #{inspect(reason)}
    Requisições: #{state.requests_count}
    """)

    :ok
  end
end
