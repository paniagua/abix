FROM nebo15/alpine-elixir:1.4.5

RUN apk add --no-cache git gcc make
ENV MIX_ENV=prod REPLACE_OS_VARS=true

WORKDIR /app

COPY . .

CMD ["/app/start.sh"]