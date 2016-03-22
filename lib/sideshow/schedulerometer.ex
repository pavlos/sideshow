defmodule Sideshow.Schedulerometer do

  def start_link do
    {:ok, pid} = Agent.start_link fn -> 0 end, name: __MODULE__
  end

  def read do
    Agent.get __MODULE__, fn(state)-> state end
  end

end
