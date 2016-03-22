defmodule Sideshow.TryCounter do

  def spawn(tries, supervisor) do
    {:ok, pid} = Agent.start fn ->
      # link agent to the task supervisor it gets killed when the supervisor gets killed
      Process.link supervisor
      tries
    end
    assert_link pid, supervisor
    pid
  end

  def decrement(counter) do
    Agent.get_and_update counter,
      fn(state) ->
        {state, state - 1}
      end
  end

  defp assert_link(counter, supervisor) do
    {:links, [^supervisor]} = counter |> Process.info(:links)
  end
end
