defmodule Sideshow.Foreman do
  use GenFSM

  @timeout  500

  def start_link() do
    GenFSM.start_link(__MODULE__, [], [])
  end

  def stop(pid) do
    GenFSM.send_all_state_event(pid, :stop)
  end

  def work(pid) do
  "called work in pid #{inspect pid}"
    GenFSM.send_event(pid, :work)
  end

    def work_sync(pid) do
    "called work in pid #{inspect pid}"
      GenFSM.sync_send_event(pid, :work)
    end

  # Callbacks

  def init(_args) do
    IO.puts "inside init!!!"
    { :ok, :stopped, nil}
  end

  #def working(:stop, state_data) do
  #  IO.puts "stopping the worker"
  #  {:next_state,  :stopped, state_data}
  #end

  def working(:timeout, state_data) do
    IO.puts "already working! - timed out! #{inspect self()}"
    {:next_state, :working, state_data, @timeout}
  end

  def working(:work, state_data) do
    IO.puts "already working!"
    {:next_state, :working, state_data, @timeout}
  end

  #def stopped(:stop, state_data) do
  #  IO.puts "already stopped!"
  #  {:next_state, :stopped, state_data}
  #end

  def stopped(:work, state_data) do
    IO.puts "starting this thing"
    {:next_state, :working, state_data, @timeout}
  end

  def stopped(:work, from, state_data) do
    IO.puts "starting this thing - SYNC from #{inspect self()}"
    {:reply, "howdy!", :working, state_data, @timeout}
  end


  def handle_event(:stop, _from_state, state_data) do
   IO.puts "stopping"
   {:next_state, :stopped, state_data}
  end

  def do_work(pid) do
    IO.puts "doing something"
    :timer.sleep 50
    IO.puts "do_work pid is #{inspect pid}"
  end
end
