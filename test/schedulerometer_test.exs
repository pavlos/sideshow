defmodule SchedulerometerTest do
  use ExUnit.Case, async: false
  alias Sideshow.Schedulerometer#, as: Schedometer

  @poll_interval 50
  @wait_interval (@poll_interval * 2)

  setup_all do
    {:ok, _pid} = Schedulerometer.start @poll_interval
    {:ok, []}
  end

  test "doing nothing gives a reading close to 0" do
    wait
    reading = Schedulerometer.read
    reading |> assert_in_delta(0, 0.02)
  end

  test "peg one scheduler" do
    spawn_link fn-> fib_calc(100) end
    wait
    reading = Schedulerometer.read
    expected_reading = 1/(:erlang.system_info(:schedulers))
    reading |> assert_in_delta(expected_reading, 0.02)
  end

  test "peg several schedulers" do
    total_schedulers = :erlang.system_info :schedulers

    for n <- 1..total_schedulers do
      pids = for _ <- 1..n, do: spawn fn-> fib_calc(100) end
      try do
        wait
        expected_reading = n/(:erlang.system_info(:schedulers))
        reading = Schedulerometer.read
        reading |> assert_in_delta(expected_reading, 0.02)
      after
        pids |> Enum.map(fn(p)-> p |> Process.exit(:kill) end)
      end
    end
  end


  #test "waiting on network IO gives low reading" do
  #  :timer.sleep @poll_interval
   # test_listen
  #  reading = Schedulerometer.read
  #  reading |> assert_in_delta(0, 0.01)
  #end

  #test "update polling interval from long to short happens instantly"

  #test "does math correctly"

 # test "starts up nicely"


  defp wait do
    :timer.sleep @wait_interval
  end

  defp test_listen do
    (9000..10000) |>
    Enum.map(fn(port)->
      spawn_link fn ->
        {:ok, listenSocket} = :gen_tcp.listen(port, [{:active, true}, :binary])
        {:ok, _acceptSocket} = :gen_tcp.accept(listenSocket)
      end
    end)
  end

  defp fib_calc(0), do: 0
  defp fib_calc(1), do: 1
  defp fib_calc(n), do: fib_calc(n-1) + fib_calc(n-2)

end
