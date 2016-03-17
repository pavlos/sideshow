defmodule FuturesTest do
  use SideshowFunctionalTestCase
  alias Sideshow.Future

  setup do
    on_exit fn->
      refute_received _
    end
  end

  test "future returns returnable future" do
    {:ok, future} = Sideshow.future successful_test_function
    assert future.yielding?
  end

  test "perform_async returns non-returnable future" do
    {:ok, future} = Sideshow.perform_async successful_test_function
    refute future.yielding?
  end


  ### yield! ###

  test "yield! will only accept an awaitable future" do
    assert catch_error(
      Sideshow.perform_async(successful_test_function) |> Future.yield!
    )

    assert Sideshow.future(successful_test_function) |> Future.yield!
  end

  test "yield! returns the result if successful" do
    assert {:ok, 1} == Sideshow.future(fn-> 1 end) |> Future.yield!
  end

  test "yield! returns error if job fails" do
    capture_log fn ->
      assert {:error, :shutdown} == Sideshow.future(fn-> raise "going down" end) |> Future.yield!
    end
  end

  test "yield! kills job if timeout is exceeded" do
    {:ok, future} = Sideshow.future slow_function
    assert {:timeout, nil} == Future.yield!(future, 1)
    refute Process.alive? future.pid
  end

  test "yield! returns {:timeout, nil} if timeout exceeded" do
    assert {:timeout, nil} == Sideshow.future(slow_function) |> Future.yield!(1)
  end

  test "yield! uses pattern match to crash on timeout" do
    {:ok, future} = Sideshow.future slow_function

    assert_raise MatchError, fn ->
      {:ok, _result} = Future.yield!(future, 1) #timeout
    end
  end

  test "yield! uses pattern match to crash on job crash" do
    capture_log fn ->

      {:ok, future} = Sideshow.future fn -> raise "down!" end
      assert_raise MatchError, fn ->
        {:ok, _result} = Future.yield!(future)
      end

    end
  end

  test "cannot yield! on another process' future" do
    capture_log fn ->
      {:ok, future} = Sideshow.future fn-> 42 end
      test_pid = self()

      spawn_link fn->
        assert_raise FunctionClauseError, fn ->
          future |> Future.yield!
        end
        send test_pid, :done
      end

      receive do :done -> :ok end #block until spawned process is done
    end
  end


  ### yield ###

  test "yield will only accept an awaitable future" do
     assert catch_error(
       Sideshow.perform_async(successful_test_function) |> Future.yield
     )

     assert Sideshow.future(successful_test_function) |> Future.yield
  end

  test "yield returns the result if successful" do
    assert {:ok, 1} == Sideshow.future(fn-> 1 end) |> Future.yield
  end

  test "yield returns error if job fails" do
    capture_log fn ->
      assert {:error, :shutdown} == Sideshow.future(fn-> raise "going down" end) |> Future.yield
    end
  end

  test "yield returns {:timeout, nil} if timeout exceeded" do
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

  test "job still alive after yield times out" do
    {:ok, future} = Sideshow.future slow_function
    assert {:timeout, nil} == Future.yield(future, 1)
    assert Process.alive? future.pid
  end

  test "yield uses pattern match to crash on timeout" do
    {:ok, future} = Sideshow.future slow_function

    assert_raise MatchError, fn ->
      {:ok, _result} = Future.yield(future, 1) #timeout
    end
  end

  test "yield uses pattern match to crash on job crash" do
    capture_log fn ->

      {:ok, future} = Sideshow.future fn -> raise "down!" end
      assert_raise MatchError, fn ->
        {:ok, _result} = Future.yield(future) #error
      end

    end
  end

  test "cannot yield on another process' future" do
    capture_log fn ->
      {:ok, future} = Sideshow.future fn-> 42 end
      test_pid = self()

      spawn_link fn->
        assert_raise FunctionClauseError, fn ->
          future |> Future.yield
        end
        send test_pid, :done
      end

      receive do :done -> :ok end #block until spawned process is done
    end
  end


  ### cancel ###

  test "cancel kills the job" do
    {:ok, future} = slow_function(50) |> Sideshow.future
    assert Process.alive? future.pid
    Future.cancel future
    refute Process.alive? future.pid
  end

  test "no messages are received after cancel" do
    {:ok, future} = slow_function(50) |> Sideshow.future
    Future.cancel future
    refute_receive _
  end

  test "job finished before being cancelled" do
    {:ok, future} = Sideshow.future(fn -> 42 end)
    :timer.sleep 100
    Future.cancel future
    refute_receive _
  end

  test "job died before being cancelled" do
    capture_log fn ->
      {:ok, future} = Sideshow.future(fn -> raise "mayday!" end)
      :timer.sleep 100
      Future.cancel future
      refute_receive _
    end
  end

  defp slow_function(sleep \\ 10) do
    fn ->
      :timer.sleep sleep
      42
    end
  end

end
