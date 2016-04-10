defmodule Sideshow.SchedulerUsageHandler do
  use Tachometer.SchedulerUsageEvent.Handler

  def handle_scheduler_usage_update(usage) do
    if usage < 1.0 do
      IO.puts "scheduler less than 1.0"
      Sideshow.Foreman.work_sync
    end
  end

end
