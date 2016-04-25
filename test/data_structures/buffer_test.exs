`defmodule BufferTest do
  use ExUnit.Case, async: true
  alias Sideshow.Stack
  alias Sideshow.Queue

  test "queue" do
    b = Queue.new
    b = Buffer.add b, 1
    b = Buffer.add b, 2
    b = Buffer.add b, 3

    assert {{:value, 1}, b = %{}} = Buffer.remove b
    assert {{:value, 2}, b = %{}} = Buffer.remove b
    assert {{:value, 3}, b = %{}} = Buffer.remove b
    assert {:empty, _b = %{}} = Buffer.remove b
  end

  test "stack" do
    b = Stack.new
    b = Buffer.add b, 1
    b = Buffer.add b, 2
    b = Buffer.add b, 3

    assert {{:value, 3}, b = %{}} = Buffer.remove b
    assert {{:value, 2}, b = %{}} = Buffer.remove b
    assert {{:value, 1}, b = %{}} = Buffer.remove b
    assert {:empty, _b = %{}} = Buffer.remove b
  end
  
end
