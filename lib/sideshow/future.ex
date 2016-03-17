defmodule Sideshow.Future do
  defstruct pid: nil, ref: nil, owner: nil, yielding?: false

  def yield!(term, timeout \\ 5000)

  def yield!({:ok, future}, timeout) do
    yield!(future, timeout)
  end

  def yield!(future, timeout) do
    do_yield(future, timeout, true)
  end

  def yield(term, timeout \\ 5000)

  def yield({:ok, future}, timeout) do
    yield(future, timeout)
  end

  def yield(future, timeout) do
    do_yield(future, timeout, false)
  end

  defp do_yield(%Sideshow.Future{ref: ref, pid: pid, yielding?: true, owner: owner} = future, timeout, cancel?)
              when owner == self() do
    receive do
      {:sideshow_job_finished, ^future, result} ->
        Process.demonitor ref, [:flush]
        {:ok, result}
      {:DOWN, ^ref, _, ^pid, reason} -> # process going down demonitors itself
        {:error, reason}
    after
      timeout ->
        if cancel?, do: cancel(future)
        {:timeout, nil}
    end
  end

  def cancel({_, future}) do
    cancel(future)
  end

  def cancel(%Sideshow.Future{pid: pid, ref: ref} = future) do
    Process.exit pid, :kill # TODO: should we kill through the supervisor instead?
    Process.demonitor ref, [:flush]

    receive do
      {:sideshow_job_finished, ^future, _result} -> nil
    after
     0 -> nil
    end

    :ok
  end
end
