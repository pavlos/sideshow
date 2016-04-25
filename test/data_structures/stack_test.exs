defmodule StackTest do
  use ExUnit.Case, async: true
  alias Sideshow.Stack

  test "stack" do
    s = Stack.new
    s = Stack.push s, 1
    s = Stack.push s, 2
    s = Stack.push s, 3
    s = Stack.push s, 4
    s = Stack.push s, 5
    s = Stack.push s, 6

    assert {{:value, 6}, s} = Stack.pop s
    assert {{:value, 5}, s} = Stack.pop s
    assert {{:value, 4}, s} = Stack.pop s
    assert {{:value, 3}, s} = Stack.pop s
    assert {{:value, 2}, s} = Stack.pop s
    assert {{:value, 1}, s} = Stack.pop s

    assert {:empty, s} = Stack.pop s
    assert {:empty, _s} = Stack.pop s
  end

end
