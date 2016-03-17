defmodule Sideshow.Future do
  defstruct pid: nil, ref: nil, owner: nil, returnable?: false

  def yield!(term, timeout \\ 5000)

  def yield!({:ok, future}, timeout) do
    yield!(future, timeout)
  end

  def yield!(%Sideshow.Future{ref: ref, pid: pid, returnable?: true} = future, timeout) do
    receive do
      {:sideshow_job_finished, ^future, result} ->
        Process.demonitor ref, [:flush]
        {:ok, result}
      {:DOWN, ^ref, _, ^pid, reason} -> # process going down demonitors itself
        exit({ {:error, reason}, {__MODULE__, :await, [future, timeout]} })
    after
      timeout ->
        Process.demonitor ref, [:flush]
        exit( { {:timeout, nil}, {__MODULE__, :await, [future, timeout]} } )
    end
  end


  def yield(term, timeout \\ 5000)

  def yield({:ok, future}, timeout) do
    yield(future, timeout)
  end

  def yield(%Sideshow.Future{ref: ref, pid: pid, returnable?: true} = future, timeout) do
    receive do
      {:sideshow_job_finished, ^future, result} ->
        Process.demonitor ref, [:flush]
        {:ok, result}
      {:DOWN, ^ref, _, ^pid, reason} ->
        {:error, reason}
    after
      timeout ->
        {:timeout, nil}
    end
  end


  def shutdown({_, future}) do
    shutdown(future)
  end

  def shutdown(%Sideshow.Future{pid: pid, ref: ref} = future) do
    Process.exit pid, :kill # TODO: should we kill through the supervisor instead?
    Process.demonitor ref, [:flush]

    receive do
      {:sideshow_job_finished, ^future, result} -> nil
    after
     0 -> nil
    end

  end
end
