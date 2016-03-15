defmodule FuturesTest do
  use SideshowFunctionalTestCase
  alias Sideshow.Future

  test "future returns returnable future" do
    {:ok, future} = Sideshow.future successful_test_function
    assert future.returnable?
  end

  test "perform_async returns non-returnable future" do
    {:ok, future} = Sideshow.perform_async successful_test_function
    refute future.returnable?
  end

  test "await will only accept an awaitable future" do
    assert catch_error(
      Sideshow.perform_async(successful_test_function) |> Future.await
    )

    assert Sideshow.future(successful_test_function) |> Future.await
  end

  test "yield will only accept an awaitable future" do
     assert catch_error(
       Sideshow.perform_async(successful_test_function) |> Future.yield
     )

     assert Sideshow.future(successful_test_function) |> Future.yield
  end

  test "await returns the result if successful" do
    result = Sideshow.future(fn-> 1 end) |> Future.await
    assert {:ok, 1} == result
  end

  test "await exits if job fails"
  test "await exits if timeout is reached"

  test "yield returns the result if successful" do
    result = Sideshow.future(fn-> 1 end) |> Future.yield
    assert {:ok, 1} == result
  end


  test "yield returns error if job fails"

  test "yield returns nil if timeout exceeded" do
    result = Sideshow.future(fn-> :timer.sleep(10); 42 end) |> Future.yield(1)
    assert {:timeout, nil} == result
  end

  test "yield can be used more than once" do
    {:ok, future} = Sideshow.future(fn-> :timer.sleep(10); 42 end)
    result = Future.yield(future, 1)
    assert {:timeout, nil} == result

    result = Future.yield(future, 11)
    assert {:ok, 42} ==  result
  end

  test "yield times out after yielding result" do
    {:ok, future} = Sideshow.future(fn-> 42 end)
    result = Future.yield(future)
    assert {:ok, 42} ==  result

    result = Future.yield(future, 0)
    assert {:timeout, nil} == result
  end

  test "shutdown returns a value if one was emmitted"
  test "shutdown returns nothing if no value was emmitted"
  test "shutdown kills the job"
  test "the mailbox is empty in all these cases"

end
