ExUnit.start()

# stop sideshow so that we can link it to the test harness process instead of the application
try do
  Sideshow.stop
catch
  :exit, :noproc -> IO.puts "caught noproc"
end

defmodule SideshowFunctionalTestCase do
  defmacro __using__(_opts) do

    quote do
      use ExUnit.Case, async: false
      import ExUnit.CaptureLog

      setup do
        # give it some time to shut down from previous run
        # TODO: figure out if we can just get notified insted of sleeping
        :timer.sleep 10
        {:ok, pid} = Sideshow.start
        {:ok, [sideshow_pid: pid]}
      end
    end

  end
end
