defmodule Sideshow.TachometerSupervisor do
  import Supervisor.Spec

  def start_link(poll_interval) do
    children = [
      worker(Sideshow.Tachometer, []),
      worker(Sideshow.SchedulerPoller, [poll_interval])
    ]

    Supervisor.start_link(children, strategy: :rest_for_one, name: __MODULE__)
  end

  def stop do
    Supervisor.stop(__MODULE__, :normal)
  end

end
