defmodule OtpPlayground.CalculatorServer do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(_state) do
    {:ok, %{operations_count: 0, async_operations_count: 0}}
  end

  @impl true
  def handle_call({:double, value}, _from, state) do
    result = OtpPlayground.Calculator.double(value)

    execute_operation(
      %{
        operation: :double,
        value: value,
        result: result
      },
      state
    )
  end

  @impl true
  def handle_call({:triple, value}, _from, state) do
    result = OtpPlayground.Calculator.triple(value)

    execute_operation(
      %{
        operation: :triple,
        value: value,
        result: result
      },
      state
    )
  end

  @impl true
  def handle_call({:sum, value1, value2}, _from, state) do
    result = OtpPlayground.Calculator.sum(value1, value2)

    execute_operation(
      %{
        operation: :sum,
        values: [value1, value2],
        result: result
      },
      state
    )
  end

  @impl true
  def handle_call(:get_operations_count, _from, state) do
    {:reply, state.operations_count, state}
  end

  @impl true
  def handle_call(:get_async_operations_count, _from, state) do
    {:reply, state.async_operations_count, state}
  end

  @impl true
  def handle_cast(:register_async_operation, state) do
    new_state = increment_operations_count(state, :async_operations_count)
    {:noreply, new_state}
  end

  defp increment_operations_count(state, operation_type) do
    Map.update!(state, operation_type, &(&1 + 1))
  end

  defp register_operation(operation, data) do
    GenServer.cast(OtpPlayground.AuditServer, {:register, data})
    GenServer.cast(OtpPlayground.MetricsServer, {:increment, operation})
  end

  defp execute_operation(%{operation: operation, result: result} = data, state) do
    register_operation(operation, data)

    new_state = increment_operations_count(state, :operations_count)

    {:reply, result, new_state}
  end
end
