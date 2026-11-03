defmodule OtpPlayground.Calculator do
  def double(value) do
    value * 2
  end

  def triple(value) do
    value * 3
  end

  def divide(_value, 0) do
    {:error, "Divisão por zero"}
  end

  def divide(value, divisor) do
    {:ok, value / divisor}
  end

  def sum(value1, value2) do
    value1 + value2
  end

  def subtract(value1, value2) do
    value1 - value2
  end
end
