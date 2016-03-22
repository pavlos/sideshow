defmodule Sideshow.SchedulerPoller do
  require Logger

  def start_link(poll_interval \\ 1000) do
    :erlang.system_flag(:scheduler_wall_time, true)
    initial_reading = :erlang.statistics(:scheduler_wall_time)
    pid = spawn_link(__MODULE__, :poll, [poll_interval, initial_reading])
    unregister()
    true = Process.register(pid, __MODULE__)
    {:ok, pid}
  end

  defp unregister do
    if Process.whereis(__MODULE__), do: Process.unregister(__MODULE__)
  end

  def stop do
    unregister
    :erlang.system_flag(:scheduler_wall_time, false)
  end

  def poll(interval, first) do
    receive do
      {:set_poll_interval, new_interval} ->
        interval = new_interval
      message ->
        Logger.warn "received unexpected message #{inspect message}"
    after
      interval -> :ok
    end
    last = :erlang.statistics(:scheduler_wall_time)
    scheduler_usage(first, last) |> update_schedulerometer
    poll(interval, last)
  end

  def set_poll_interval(interval) do
    send __MODULE__, {:set_poll_interval, interval}
    :ok
  end

  defp scheduler_usage(first, last) do
    # TODO: consider making this asynchronous so that it gets
    #       factored into the statistics in the next loop
    {last_active,  last_total}  = reduce_sample(last)
    {first_active, first_total} = reduce_sample(first)
    (last_active - first_active)/(last_total - first_total)
  end

  defp update_schedulerometer(usage) do
    Agent.cast Sideshow.Schedulerometer, fn(_old_usage)-> usage end
  end

  defp reduce_sample(sample) do
    sample |>
    Enum.reduce({0,0},
      fn({_scheduler, active_time, total_time}, {total_active, total_total}) ->
        {active_time + total_active, total_time + total_total}
      end
    )
  end
  
end
