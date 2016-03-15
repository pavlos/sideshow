defmodule FuturesTest do
  use SideshowFunctionalTestCase
  alias Sideshow.Future

#await - we blow up
#cancel - future blows up
#yield  - nothing blows up

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
    assert {:ok, 1} == Sideshow.future(fn-> 1 end) |> Future.await
  end

  test "await exits if job fails" do
    capture_log fn ->
      assert {{:error, :shutdown}, _} = catch_exit(
        Sideshow.future(fn-> 1/0 end) |> Future.await
      )
    end
  end

  test "await exits if timeout is exceeded" do
    assert {{:timeout, nil}, _} = catch_exit(
      Sideshow.future(slow_function) |> Future.await(0)
    )
  end

  test "future still running if await exits if timeout is exceeded"

  test "yield returns the result if successful" do
    assert {:ok, 1} == Sideshow.future(fn-> 1 end) |> Future.yield
  end

  test "yield returns error if job fails" do
    capture_log fn ->
      assert {:error, :shutdown} == Sideshow.future(fn-> 1/0 end) |> Future.yield
    end
  end

  test "yield returns nil if timeout exceeded" do
    assert {:timeout, nil} == Sideshow.future(slow_function) |> Future.yield(1)
  end

  test "yield can be used more than once" do
    {:ok, future} = Sideshow.future slow_function
    assert {:timeout, nil} == Future.yield(future, 1)
    assert {:ok, 42} ==  Future.yield(future, 11)
  end

  test "yield times out after yielding result" do
    {:ok, future} = Sideshow.future(fn-> 42 end)
    assert {:ok, 42} == Future.yield(future)
    assert {:timeout, nil} == Future.yield(future, 0)
  end

  test "shutdown returns a value if one was emmitted"
  test "shutdown returns nothing if no value was emmitted"
  test "shutdown kills the job"
  test "the mailbox is empty in all these cases"

  defp slow_function(sleep \\ 10) do
    fn ->
      :timer.sleep sleep
      42
    end
  end

end
