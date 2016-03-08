defmodule Sideshow.IsolatedSupervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def stop do
    Supervisor.stop(__MODULE__, :shutdown)
  end

  def init(_) do
    children = [
      # but the Task Supervisor is temporary so that failures DO NOT bubble up to sideshow
      worker(Task.Supervisor, [], restart: :temporary  )
    ]
    supervise(children, strategy: :simple_one_for_one)
  end

  defp start_child(max_restarts) do
    # this is the code that starts the subsupervisor - i.e. the wrapper around the job
    # the task is in run transient mode so that it can be retried
    {:ok, _pid} = Supervisor.start_child __MODULE__, [[max_restarts: max_restarts, restart: :transient]]
  end

  def perform_async(function, opts \\ []) do
    retries = opts[:retries] || 0
    delay = opts[:delay] || false

    {:ok, task_supervisor_pid} = start_child(retries)

    Task.Supervisor.start_child task_supervisor_pid, fn->
      if delay, do: :timer.sleep delay

      function.() # do we need to check for error return
      Supervisor.stop task_supervisor_pid, :shutdown
    end
  end

  def perform_async(module, function, args, opts \\ [])  do
    retries = opts[:retries] || 0
    delay = opts[:delay] || false

    {:ok, task_supervisor_pid} = start_child(retries)

    Task.Supervisor.start_child task_supervisor_pid, fn->
      if delay, do: :timer.sleep delay

      apply(module, function, args)
      Supervisor.stop task_supervisor_pid, :shutdown
    end
  end
end
