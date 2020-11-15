FROM ubuntu:focal

RUN apt-get update && apt-get install curl git libssl-dev unzip make automake autoconf gcc libncurses5-dev --yes

RUN adduser --shell /bin/bash --home /asdf --disabled-password asdf
WORKDIR /asdf
USER asdf 

RUN git clone https://github.com/asdf-vm/asdf.git /asdf/.asdf
ENV PATH="${PATH}:/asdf/.asdf/shims:/asdf/.asdf/bin"

RUN asdf plugin-add erlang
RUN asdf plugin-add elixir

COPY .tool-versions .
RUN asdf install

ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

COPY mix.exs mix.lock ./
RUN mix local.hex --force && \
  mix local.rebar --force

COPY . ./
RUN mix deps.get
