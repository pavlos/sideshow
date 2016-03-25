defmodule Sideshow.Tachometer do
  require Logger

  def start(poll_interval \\ 1000) do
    Sideshow.TachometerSupervisor.start_link(poll_interval)
  end

  def stop do
    Sideshow.TachometerSupervisor.stop
  end

  def start_link do
    {:ok, _pid} = Agent.start_link fn -> 0 end, name: __MODULE__
  end

  def safe_read(fallback \\ 0.50) do
    try do
      read
    catch
      _,_  ->
        Logger.warn "#{inspect __MODULE__ }.safe_read used fallback value of #{fallback}"
        fallback
    end
  end

  def read do
    Agent.get __MODULE__, fn(state)-> state end
  end

  def safe_set_poll_interval(interval) do
    try do
      set_poll_interval(interval)
    catch
      _,_ ->
        Logger.warn "#{inspect __MODULE__ }.safe_set_poll_interval failed"
    end
    :ok
  end

  def set_poll_interval(interval) do
    Sideshow.SchedulerPoller.set_poll_interval(interval)
  end

end
