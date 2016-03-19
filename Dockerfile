FROM elixir:latest

WORKDIR /sideshow

COPY ./ ./
RUN echo "y" | mix deps.get
RUN mix compile

CMD ["iex", "-S",  "mix"]
