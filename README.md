# Sideshow

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add sideshow to your list of dependencies in `mix.exs`:

        def deps do
          [{:sideshow, "~> 0.0.1"}]
        end

  2. Ensure sideshow is started before your application:

        def application do
          [applications: [:sideshow]]
        end


## Running

```bash
docker build -t sideshow .
docker run -it --rm sideshow
```
