defmodule Sideshow.IsolatedSupervisor do
  use Supervisor

  @one_billion_years 60*60*24*365*1_000_000_000

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

  defp start_task_supervisor(max_restarts) do
    # this is the code that starts the subsupervisor - i.e. the wrapper around the job
    # the task is in run transient mode so that it can be retried
    {:ok, _pid} = Supervisor.start_child __MODULE__, [[max_restarts: max_restarts,
                                                       max_seconds: @one_billion_years,
                                                       restart: :transient]]
  end

  def perform_async(function, opts \\ []) do
    {retries, delay, backoff?} = parse_opts(opts)
    {:ok, task_supervisor_pid} = start_task_supervisor(retries)

    tries = retries + 1

    # need to keep a counter of retries to use in backoff functions
    try_counter = Sideshow.TryCounter.spawn(tries, task_supervisor_pid)

    {status, _pid} = Task.Supervisor.start_child task_supervisor_pid, fn->
      tries_left = Sideshow.TryCounter.decrement try_counter

      wait(delay, backoff?, tries, tries_left)

      function.()
      Supervisor.stop task_supervisor_pid, :shutdown
    end

    status
  end

  def perform_async(module, function, args, opts \\ [])  do
    ( fn -> apply(module, function, args) end ) |>
    perform_async(opts)
  end

  defp wait(delay, backoff?, tries, tries_left) do
    try_number = tries - tries_left + 1

    if try_number == 1 do
      if delay, do: :timer.sleep(delay)
    else
      if backoff?, do: try_number |> backoff |> :timer.sleep
    end
  end

  defp backoff(n) do
    :math.pow(2, n) * 1000 |>  trunc
  end

  defp parse_opts(opts) do
      retries = opts[:retries] || 0
      delay = opts[:delay] || false
      backoff? =  case opts[:backoff] do
                    false -> false
                    _ -> true
                  end

    {retries, delay, backoff?}
  end

end
