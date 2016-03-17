defmodule SideshowTest do
  use SideshowFunctionalTestCase

  test "a task is not retried by default" do
    capture_log fn ->
      Sideshow.perform_async failing_test_function
      assert_receive :job_failed, 10
      refute_receive :job_failed, 10
    end
  end

  test "a task is allowed to be retried n times" do
    capture_log fn ->
      Sideshow.perform_async failing_test_function, retries: 2, backoff: false

      Enum.each 1..3, fn(_) ->
        #get the message 3 times - once, plus two retries
        assert_receive :job_failed, 10
      end

      #make sure it doesn't happen again
      refute_received :job_failed, 10
    end
  end

  test "sub supervisor is stopped after successfully performing a task" do
    Sideshow.perform_async successful_test_function

    assert Supervisor.count_children(Sideshow).active == 1
    assert_receive :job_succeeded, 10

    # give it some time to shut down
    # TODO: figure out if we can just get notified insted of sleeping
    :timer.sleep 10

    assert Supervisor.count_children(Sideshow).active == 0
  end

  test "a sub supervisor is stopped after failing" do
    capture_log fn ->
      Sideshow.perform_async failing_test_function, retries: 2, backoff: false
      assert Supervisor.count_children(Sideshow).active == 1

      Enum.each 1..3, fn(_) ->
        assert_receive :job_failed, 10
      end

      :timer.sleep 10
      assert Supervisor.count_children(Sideshow).active == 0
    end
  end

  test "a sub supervisor doesnt bring down the supervisor", context do
    capture_log fn ->
      # max 3 restarts in 5 seconds - the otp default, means that we need to bring down a task subsubervisor at least 4
      # times to attempt to kill Sideshow.  In reality, it doesn't matter since the task subsupervisors are temporary
      Enum.each 1..5, fn(_) ->
        Sideshow.perform_async failing_test_function, retries: 10, backoff: false
      end

      sideshow_pid = context[:sideshow_pid]
      assert Process.alive? sideshow_pid
      :timer.sleep 5000
      assert Process.alive? sideshow_pid
    end
  end

  test "delay option" do
    Sideshow.perform_async successful_test_function, delay: 200
    refute_receive :job_succeeded, 199
    assert_receive :job_succeeded, 200
  end

  test "only delay first time" do
    capture_log fn ->
      Sideshow.perform_async failing_test_function, delay: 200, retries: 2, backoff: false
      assert_receive :job_failed, 210
      assert_receive :job_failed, 10
      assert_receive :job_failed, 10
    end
  end

  test "backoff" do
    backoff_intervals = (1..3) |> Enum.map(&Sideshow.Backoff.exponential/1)

    capture_log fn ->
      Sideshow.perform_async failing_test_function, retries: 3
      assert_receive :job_failed, 10 # test that it doesn't backoff the first time
      Enum.each backoff_intervals, fn(interval) ->
        refute_receive :job_failed, (interval - 1)
        assert_receive :job_failed, interval
      end
    end
  end

  test "backoff and delay together" do
    delay_time = 100
    backoff_time = Sideshow.Backoff.exponential(1)

    capture_log fn ->
      Sideshow.perform_async failing_test_function, retries: 1, delay: delay_time
      refute_receive :job_failed, delay_time - 1
      assert_receive :job_failed, delay_time

      refute_receive :job_failed, backoff_time - 1
      assert_receive :job_failed, backoff_time
    end
  end

  test "backoff: false" do
    capture_log fn ->
      Sideshow.perform_async failing_test_function, retries: 2, backoff: false
      assert_receive :job_failed, 10
      assert_receive :job_failed, 10
      assert_receive :job_failed, 10
    end
  end

  test "multiple sideshows are independent", context do
    assert Process.alive? context[:sideshow_pid]

    {:ok, other_sideshow} = Sideshow.start(:another)
    :ok = Sideshow.stop

    refute Process.alive? context[:sideshow_pid]
    assert Process.alive? other_sideshow

    assert catch_exit(Sideshow.perform_async successful_test_function)
    Sideshow.perform_async successful_test_function, instance_name: :another
    assert_receive :job_succeeded, 10
  end

end
