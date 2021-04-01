FROM elixir:latest

RUN mix local.hex --force

RUN mix local.rebar --force

COPY mix.* ./

RUN mix deps.get

RUN mix deps.compile

COPY . .

RUN mix compile