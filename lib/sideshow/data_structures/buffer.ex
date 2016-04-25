defprotocol Buffer do
  def add(buffer, item)
  def remove(buffer)
end

defimpl Buffer, for: Sideshow.Queue do
  def add(buffer, item) do
    Sideshow.Queue.enqueue buffer, item
  end

  def remove(buffer) do
    Sideshow.Queue.dequeue buffer
  end
end

defimpl Buffer, for: Sideshow.Stack do
  def add(buffer, item) do
    Sideshow.Stack.push buffer, item
  end

  def remove(buffer) do
    Sideshow.Stack.pop buffer
  end
end
