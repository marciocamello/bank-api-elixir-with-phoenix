FROM elixir:latest

WORKDIR /app

RUN apt-get update -y \
    && curl -sL https://deb.nodesource.com/setup_14.x | bash - \
    && apt-get install -y -q --no-install-recommends nodejs \
    && mix local.rebar --force \
    && mix local.hex --force

COPY . .

RUN mix do deps.get, compile
RUN #cd ./assets \
    #&& npm install \
    #&& ./node_modules/webpack/bin/webpack.js --node production \
    cd .. \
    && mix phx.digest

EXPOSE 4000

CMD ["mix", "phx.server"]

