defmodule Sideshow.Schedulerometer do

  def start_link do
    {:ok, pid} = Agent.start_link fn -> 0 end, name: __MODULE__
  end

  def read do
    Agent.get __MODULE__, fn(state)-> state end
  end

  def set_poll_interval(interval) do
    Sideshow.SchedulerPoller.set_poll_interval(interval)
  end

end
