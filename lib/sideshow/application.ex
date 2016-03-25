defmodule Sideshow.Application do

  def start(_type, args) do
    poll_interval = args[:poll_interval] ||  Application.get_env(:sideshow, :tachometer_poll_interval)
    Sideshow.Tachometer.start(poll_interval)
    Sideshow.start(args[:instance_name])
  end

end
