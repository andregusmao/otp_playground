defmodule OtpPlayground.MetricsServer do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_cast({:increment, operation}, state) do
    new_state = Map.update(state, operation, 1, &(&1 + 1))

    {:noreply, new_state}
  end

  @impl true
  def handle_call(:get_metrics, _from, state) do
    {:reply, state, state}
  end
end
