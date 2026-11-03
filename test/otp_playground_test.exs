defmodule OtpPlaygroundTest do
  use ExUnit.Case
  doctest OtpPlayground

  test "greets the world" do
    assert OtpPlayground.hello() == :world
  end
end
