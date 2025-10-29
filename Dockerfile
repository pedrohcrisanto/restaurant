# syntax=docker/dockerfile:1

FROM ruby:3.2.4-slim AS base

ENV BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3 \
    BUNDLER_EDITOR=vim \
    APP_HOME=/app

# Sistema e libs nativas necessárias para gems (pg etc.)
RUN apt-get update -y \
    && apt-get install -y --no-install-recommends \
       build-essential \
       libpq-dev \
       git \
       curl \
    && rm -rf /var/lib/apt/lists/*

# Garantir versão do bundler compatível com Gemfile.lock
RUN gem install bundler -v 2.6.9

WORKDIR ${APP_HOME}

# Instalar gems com cache eficiente
COPY Gemfile Gemfile.lock ./
RUN bundle config set path '/usr/local/bundle' \
 && bundle config set without '' \
 && bundle install --jobs=${BUNDLE_JOBS} --retry=${BUNDLE_RETRY}

# Copiar restante do app
COPY . .

# Entrypoint que remove PID do puma/rails se existir
RUN chmod +x bin/docker-entrypoint || true

ENV RAILS_ENV=development

# Comando padrão é somente abrir shell; usaremos `docker compose run` para tarefas
CMD ["bash"]

