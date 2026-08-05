ARG ELIXIR_VERSION=1.19.5
ARG OTP_VERSION=28.3.1
ARG DEBIAN_VERSION=trixie-20260610-slim


ARG BUILDER_IMAGE="hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}"
ARG RUNNER_IMAGE="debian:${DEBIAN_VERSION}"

FROM ${BUILDER_IMAGE} AS builder

RUN apt-get update && apt-get install -y --no-install-recommends build-essential git && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN mix local.hex --force && mix local.rebar --force

ENV MIX_ENV=prod

# deps cache layer - invalidated by mix.exs or mix.lock changes
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV

# deps compilation cache layer - config.exs, prod.exs
RUN mkdir config
COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile

# assets from priv
RUN mix assets.setup
COPY priv priv


# app compilation cache layer - lib invalidates cache
COPY lib lib
RUN mix compile

# frontend assets cache layer - invalidated by change in assets
COPY assets assets
RUN mix assets.deploy

# runtime.exs is not compile-time config, copied after compilation so editing it deosn't invalidate compiled code
COPY config/runtime.exs config/

# release
COPY rel rel
RUN mix release

FROM ${RUNNER_IMAGE} AS runner
ENV MIX_ENV=prod
RUN apt-get update && apt-get install -y --no-install-recommends libstdc++6 openssl libncurses6 locales ca-certificates && rm -rf /var/lib/apt/lists/*

RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en_US
ENV LC_ALL=en_US.UTF-8

WORKDIR /app
RUN chown nobody /app

COPY --from=builder --chown=nobody:root /app/_build/${MIX_ENV}/rel/eve_industrex ./

USER nobody

ENV PHX_SERVER=true

CMD ["/app/bin/eve_industrex", "start"]