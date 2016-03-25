defmodule Sideshow.Application do
  import Supervisor.Spec#, warn: false

  def start(_type, args) do
  IO.puts "APPLICATION START WITH ARGS #{inspect args}"
  IO.puts "APPLICATION START WITH POLL INTERVAL #{inspect args[:poll_interval]}"
    poll_interval = args[:poll_interval] ||  Application.get_env(:sideshow, :schedulerometer_poll_interval)
    Sideshow.Schedulerometer.start(poll_interval)
    Sideshow.start(args[:instance_name])
  end

end
