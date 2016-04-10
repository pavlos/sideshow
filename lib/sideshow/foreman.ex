defmodule Sideshow.Foreman do
  use GenFSM

  @timeout 0

  def start_link() do
    GenFSM.start_link __MODULE__, [], name: __MODULE__
    Tachometer.add_scheduler_usage_handler Sideshow.SchedulerUsageHandler
  end

  def work_sync do
    GenFSM.sync_send_all_state_event(__MODULE__, :work)
  end

  def chill_sync do
    GenFSM.sync_send_all_state_event(__MODULE__, :chill)
  end

  # Callbacks
  def init(_args) do
    { :ok, :chilling, nil}
  end

  def working(:timeout, state_data) do
    do_work(state_data)
  end

  def handle_sync_event(:work, _from , _from_state, state_data) do
    {:reply, "working", :working, state_data, @timeout}
  end

  def handle_sync_event(:chill, _from , _from_state, state_data) do
    {:reply, "chilling", :chilling, state_data}
  end

  def do_work(state_data) do
    if Tachometer.below_max? do
    n = Enum.random(40..46)
      spawn( fn -> fib_calc(n) end )
      IO.puts "started a worker"
      {:next_state, :working, state_data, @timeout}
    else
      IO.puts "overload!  chilling"
      {:next_state, :chilling, state_data}
    end
  end

    def fib_calc(0), do: 0
    def fib_calc(1), do: 1
    def fib_calc(n), do: fib_calc(n-1) + fib_calc(n-2)
end
