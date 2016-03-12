defmodule Sideshow do

  def start, do: start(nil, nil)

  def start(_type, _args) do
    Sideshow.IsolatedSupervisor.start_link
  end

  def stop do
    Sideshow.IsolatedSupervisor.stop
  end

  def perform_async(function, opts \\ []) do
    perform_async(:erlang, :apply, [function, []], opts)
  end

  def perform_async(module, function, args, opts \\ []) when is_list(args) do
    Sideshow.IsolatedSupervisor.perform_async module, function, args, opts
  end
end
