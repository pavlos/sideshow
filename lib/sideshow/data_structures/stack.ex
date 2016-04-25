defmodule Sideshow.Stack do
  defstruct data: {[], []}

  def new do
    %Sideshow.Stack{data: :queue.new}
  end

  def push(%Sideshow.Stack{data: stack}, item) do
    stack = :queue.in_r item, stack
    %Sideshow.Stack{data: stack}
  end

  def pop(%Sideshow.Stack{data: stack}) do
    {return, stack} = :queue.out stack
    {return, %Sideshow.Stack{data: stack}}
  end
end
