defmodule Sideshow.Job do

  defmacro __using__(opts) do
    quote do

      # TODO: this is nasty and would be better implemented by overriding the def macro
      #       to make it define both perform and perform_async with the same arity in one shot
      def unquote(:"$handle_undefined_function")(:perform_async, args) do
        Sideshow.perform_async __MODULE__, :perform, args, unquote(opts)
      end

    end
  end

end
