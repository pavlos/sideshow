defmodule QueueTest do
  use ExUnit.Case, async: true
  alias Sideshow.Queue

  test "queue" do
    q = Queue.new
    q = Queue.enqueue q, 1
    q = Queue.enqueue q, 2
    q = Queue.enqueue q, 3
    q = Queue.enqueue q, 4
    q = Queue.enqueue q, 5
    q = Queue.enqueue q, 6

    assert {{:value, 1}, q} = Queue.dequeue q
    assert {{:value, 2}, q} = Queue.dequeue q
    assert {{:value, 3}, q} = Queue.dequeue q
    assert {{:value, 4}, q} = Queue.dequeue q
    assert {{:value, 5}, q} = Queue.dequeue q
    assert {{:value, 6}, q} = Queue.dequeue q

    assert {:empty, q} = Queue.dequeue q
    assert {:empty, _q} = Queue.dequeue q
  end

end
