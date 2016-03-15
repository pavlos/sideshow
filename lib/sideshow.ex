defmodule Sideshow do

  def start(instance_name \\ Sideshow) do
    start nil, instance_name: instance_name
  end

  def start(_type, args) do
    instance_name = args[:instance_name] || Sideshow
    Sideshow.IsolatedSupervisor.start_link instance_name
  end

  def stop(instance_name \\ Sideshow) do
    Sideshow.IsolatedSupervisor.stop instance_name
  end

  def future(function, opts \\ []) do
    future(:erlang, :apply, [function, []], opts )
  end

  def future(module, function, args, opts \\ []) do
    opts = Keyword.merge(opts, [return: true])
    Sideshow.IsolatedSupervisor.perform_async module, function, args, opts
  end

  def perform_async(function, opts \\ []) do
    perform_async(:erlang, :apply, [function, []], opts)
  end

  def perform_async(module, function, args, opts \\ []) when is_list(args) do
    Sideshow.IsolatedSupervisor.perform_async module, function, args, opts
  end
end
