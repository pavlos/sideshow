defmodule Sideshow.Queue do
  defstruct data: {[], []}

  def new do
    %Sideshow.Queue{data: :queue.new}
  end

  def enqueue(%Sideshow.Queue{data: q}, item) do
    q = :queue.in item, q
    %Sideshow.Queue{data: q}
  end

  def dequeue(%Sideshow.Queue{data: q}) do
    {return, q} = :queue.out q
    {return, %Sideshow.Queue{data: q}}
  end
end
