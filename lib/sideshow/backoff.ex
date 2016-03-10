defmodule Sideshow.Backoff do

  def exponential(n) do
    :math.pow(2, n) * 1000 |>  trunc
  end

end
