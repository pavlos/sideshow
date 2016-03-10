defmodule SideshowTest do
  use ExUnit.Case, async: false
  import ExUnit.CaptureLog

  setup_all do
    # stop sideshow so that we can link it to the test harness process instead of the application
    Sideshow.stop
  end

  setup do
    # give it some time to shut down from previous run
    # TODO: figure out if we can just get notified insted of sleeping
    :timer.sleep 10
    {:ok, pid} = Sideshow.start
    {:ok, [sideshow_pid: pid]}
  end

  test "a task is not retried by default" do
    capture_log fn ->
      Sideshow.perform_async failing_test_function
      assert received_message? :job_failed
      refute received_message? :job_failed
    end
  end

  test "a task is allowed to be retried n times" do
    capture_log fn ->
      Sideshow.perform_async failing_test_function, retries: 2, backoff: false

      Enum.each 1..3, fn(_) ->
        #get the message 3 times - once, plus two retries
        assert received_message? :job_failed
      end

      #make sure it doesn't happen again
      refute received_message? :job_failed
    end
  end

  test "sub supervisor is stopped after successfully performing a task" do
    Sideshow.perform_async successful_test_function

    assert Supervisor.count_children(Sideshow.IsolatedSupervisor).active == 1
    assert received_message? :job_succeeded

    # give it some time to shut down
    # TODO: figure out if we can just get notified insted of sleeping
    :timer.sleep 10

    assert Supervisor.count_children(Sideshow.IsolatedSupervisor).active == 0
  end

  test "a sub supervisor is stopped after failing" do
    capture_log fn ->
      Sideshow.perform_async failing_test_function, retries: 2, backoff: false
      assert Supervisor.count_children(Sideshow.IsolatedSupervisor).active == 1

      Enum.each 1..3, fn(_) ->
        assert received_message? :job_failed
      end

      :timer.sleep 10
      assert Supervisor.count_children(Sideshow.IsolatedSupervisor).active == 0
    end
  end

  test "a sub supervisor doesnt bring down the supervisor", context do
    capture_log fn ->
      # max 3 restarts in 5 seconds - the otp default, means that we need to bring down a task subsubervisor at least 4
      # times to attempt to kill Sideshow.  In reality, it doesn't matter since the task subsupervisors are temporary
      Enum.each 1..5, fn(_) ->
        Sideshow.perform_async failing_test_function, retries: 1, backoff: false
      end

      sideshow_pid = context[:sideshow_pid]
      assert Process.alive? sideshow_pid
      :timer.sleep 5000
      assert Process.alive? sideshow_pid
    end
  end

  test "delay option" do
    Sideshow.perform_async successful_test_function, delay: 200
    refute received_message? :job_succeeded
    assert received_message? :job_succeeded, 200
  end

  test "only delay first time" do

  end

  test "skip backoff" do

  end

  test "backoff" do

  end

  defp received_message?(message, timeout \\ 10) do
    receive do
      ^message -> true
    after
      timeout -> false
    end
  end

  defp successful_test_function do
    me = self()
    fn ->
      send(me, :job_succeeded)
    end
  end

  defp failing_test_function do
    me = self()
    fn ->
      send(me, :job_failed)
      raise RuntimeError
    end
  end

  defp flush do
    receive do
      _ -> flush
    after
      0 -> :ok
    end
  end

end
