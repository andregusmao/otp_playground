defmodule OtpPlayground.AuditServer do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_cast({:register, operation}, state) do
    new_state = [operation | state]
    {:noreply, new_state}
  end

  @impl true
  def handle_call(:get_operations, _from, state) do
    {:reply, Enum.reverse(state), state}
  end
end
