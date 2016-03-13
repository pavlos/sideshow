defmodule SideshowSynchronousTest do

  # run these tests synchronously because Mock doesn't support async
  use ExUnit.Case, async: false
  import Mock

  test "perform_async lambda calls perform_async MFA" do
    with_mock Sideshow.IsolatedSupervisor, [perform_async: fn(_m, _f, _a, _opts) -> :ok end] do
      lambda = fn-> IO.puts("hi") end
      Sideshow.perform_async lambda, delay: 4000, retries: 2, backoff: false
      assert called(
        Sideshow.IsolatedSupervisor.
          perform_async(:erlang, :apply, [lambda, []], [delay: 4000, retries: 2, backoff: false])
      )
    end
  end

end
