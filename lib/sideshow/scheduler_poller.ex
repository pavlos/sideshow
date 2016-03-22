defmodule Sideshow.SchedulerPoller do

  def start_link(poll_interval \\ 1000) do
    init()
    pid = spawn_link(__MODULE__, :poll, [1000])
    unregister()
    true = Process.register(__MODULE__, pid)
    {:ok, pid}
  end

  defp unregister do
    if Process.whereis(__MODULE__), do: Process.unregister(__MODULE__)
  end

  defp init do
    :erlang.system_flag(:scheduler_wall_time, true)
  end

  def stop do
    unregister
    :erlang.system_flag(:scheduler_wall_time, false)
  end

  def poll(interval) do
    #start measuring
    #sleep
    #stop measuring
    #compute the scheduler usage
    #update the agent
    first = :erlang.statistics(:scheduler_wall_time)
    :timer.sleep(interval)
    last = :erlang.statistics(:scheduler_wall_time)
    scheduler_usage(first, last) |> IO.inspect |> update_schedulerometer
    poll(interval)
  end

  defp update_schedulerometer(usage) do
    Agent.cast Sideshow.Schedulerometer, fn(_old_usage)-> usage end
  end

  defp scheduler_usage(first, last) do
    # TODO: consider making this asynchronous so that it gets
    #       factored into the statistics in the next loop
    {last_active,  last_total}  = reduce_sample(last)
    {first_active, first_total} = reduce_sample(first)
    (last_active - first_active)/(last_total - first_total)
  end

  defp reduce_sample(sample) do
    sample |>
    Enum.reduce({0,0},
      fn({_scheduler, active_time, total_time}, {total_active, total_total}) ->
        {active_time + total_active, total_time + total_total}
      end
    )
  end


  def test_listen do
    (8090..9000) |>
    Enum.map(fn(port)->
      spawn_monitor fn ->
        {:ok, listenSocket} = :gen_tcp.listen(port, [{:active, true}, :binary])
        {:ok, acceptSocket} = :gen_tcp.accept(listenSocket)
      end
    end)

  end


  def fib_calc(0), do: 0
  def fib_calc(1), do: 1
  def fib_calc(n), do: fib_calc(n-1) + fib_calc(n-2)

  
end
