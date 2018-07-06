FROM nikolauska/phoenix

RUN apk update && apk upgrade && \
    apk add --no-cache git

# Replace with regular neo-scan after this is merged:
# https://github.com/CityOfZion/neo-scan/pull/118
RUN git clone https://github.com/slipo/neo-scan.git /data

WORKDIR /data

RUN git checkout seed-config

# Here are the default environment variables you can override.
ENV POSTGRES_USERNAME='postgres'
ENV POSTGRES_PASSWORD='postgres'
ENV POSTGRES_DATABASE='neoscan_dev'
ENV POSTGRES_HOSTNAME='postgres'
ENV NEO_SEED_1="http://neo-privnet:30333"
ENV NEO_SEED_2="http://neo-privnet:30334"
ENV NEO_SEED_3="http://neo-privnet:30335"
ENV NEO_SEED_4="http://neo-privnet:30336"

RUN mix deps.get
RUN cd apps/neoscan_web/assets && npm install
RUN mix compile

EXPOSE 4000

COPY neoscan_dev.exs /data/apps/neoscan/config/dev.exs
COPY neoscan_monitor_config.exs /data/apps/neoscan_monitor/config/config.exs

# We have to do all this in the command because otherwise the environment variables don't work.
# The sleep is here to make sure postgres is fully started first.
# It should eventually be replaced with a connection check on a loop.
CMD sleep 3 && \
  mix ecto.create && \
  mix ecto.migrate && \
  mix phx.server
