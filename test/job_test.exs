defmodule TestJob do
  use Sideshow.Job, delay: 4000, retries: 2, backoff: false

  def perform(a, b, c, opts \\ []) do
    a + b + c + opts[:foo]
  end
end


defmodule JobTest do
  use ExUnit.Case, async: false
  import Mock

  test "calling perform_async makes Sideshow call the perform method with args passed to `use`" do
    with_mock Sideshow, [perform_async: fn(_module, _function, _args, _opts) -> :ok end] do
      TestJob.perform_async 1, 2, 3, foo: 4
      assert called(
        Sideshow.perform_async(TestJob, :perform, [1, 2, 3, [foo: 4]], delay: 4000, retries: 2, backoff: false)
      )
    end
  end

end
