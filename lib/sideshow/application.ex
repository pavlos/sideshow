defmodule Sideshow.Application do

  def start(_type, args) do
    Sideshow.start(args[:instance_name])
  end

end
