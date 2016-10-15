# Version: 0.0.1
FROM ubuntu:16.04
MAINTAINER Steve Hook "steve@example.com"
ENV DEBIAN_FRONTEND noninteractive

# Ensure locale
RUN apt-get -y update
RUN dpkg-reconfigure locales && \
  locale-gen en_GB.UTF-8 && \
  /usr/sbin/update-locale LANG=en_GB.UTF-8
ENV LC_ALL en_GB.UTF-8

# Essential packages
RUN apt-get -y update
RUN apt-get -y install wget build-essential git curl

# Install Erlang
RUN mkdir /tmp/erlang-build
WORKDIR /tmp/erlang-build
RUN wget http://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb
RUN dpkg -i erlang-solutions_1.0_all.deb
RUN apt-get -y update
RUN apt-get -y install erlang

# Install Elixir and Phoenix
RUN apt-get install elixir
RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix archive.install --force https://github.com/phoenixframework/archives/raw/master/phoenix_new.ez
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash - && apt-get install -y nodejs

WORKDIR /app
ADD . /app

RUN npm install
RUN mix deps.get
