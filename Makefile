DC ?= docker compose

.PHONY: help build up-db bundle db-prepare test rswag import up-web logs down clean bash brakeman

help:
	@echo "Targets:"
	@echo "  build           Build images (app, web)"
	@echo "  up-db           Start Postgres (detached)"
	@echo "  bundle          Install gems inside the app container"
	@echo "  db-prepare      Prepare databases (development and test)"
	@echo "  test            Run RSpec with color & documentation"
	@echo "  rswag           Generate Swagger (YAML) from specs"
		@echo "  rswag-json      Generate Swagger JSON into public/api-docs"
	@echo "  brakeman        Run Brakeman security scan (reports in tmp/brakeman)"

	@echo "  import          Run JSON import using contexts/data.json"
	@echo "  up-web          Start Rails server on http://localhost:3000"
	@echo "  logs            Tail web service logs"
	@echo "  down            Stop containers"
	@echo "  clean           Stop containers and remove volumes"
	@echo "  bash            Open interactive shell in app container"

build:
	$(DC) build app web

up-db:
	$(DC) up -d db

bundle:
	$(DC) run --rm app bash -lc "bundle install"

db-prepare:
	$(DC) run --rm app bash -lc "bin/rails db:prepare && RAILS_ENV=test bin/rails db:prepare"

test: up-db bundle db-prepare
	$(DC) run --rm -e RAILS_ENV=test app bash -lc "bundle exec rspec --format documentation --color"


# Save full RSpec output to tmp/rspec_output.txt so the agent can read it
# Usage:
#   make test-save
#   make test-file FILE=spec/models/restaurant_spec.rb [OUT=tmp/rspec_output.txt]
# The file is written inside the repo (mounted at /app), so I can read it.

.PHONY: test-save test-file

# Run the whole suite and save output
test-save: up-db bundle db-prepare
	$(DC) run --rm -e RAILS_ENV=test app bash -lc "set -o pipefail; mkdir -p tmp; bundle exec rspec --format documentation --backtrace --color | tee /app/tmp/rspec_output.txt"

# Run a specific spec file and save output; pass FILE=... and optional OUT=...
# Example:
#   make test-file FILE=spec/models/restaurant_spec.rb OUT=tmp/rspec_restaurant.txt
# Defaults: OUT=tmp/rspec_output.txt
# Note: Use quotes if FILE has spaces or multiple paths
OUT ?= tmp/rspec_output.txt

test-file: up-db bundle db-prepare
	$(DC) run --rm -e RAILS_ENV=test app bash -lc "set -o pipefail; mkdir -p tmp; bundle exec rspec $${FILE} --format documentation --backtrace --color | tee /app/$${OUT}"

rswag: up-db bundle db-prepare
	$(DC) run --rm -e RAILS_ENV=test app bash -lc "bundle exec rake rswag:specs:swaggerize"

import:
	$(DC) run --rm app bash -lc "bin/rails restaurant:import_json[contexts/data.json]"

.PHONY: rswag-json
rswag-json: up-db bundle db-prepare
	$(DC) run --rm -e RAILS_ENV=test app bash -lc "set -o pipefail; bundle exec rake rswag:specs:swaggerize && mkdir -p /app/public/api-docs/v1 && ruby -ryaml -rjson -e 'puts JSON.pretty_generate(YAML.load_file(%q{swagger/v1/swagger.yaml}))' > /app/public/api-docs/v1/swagger.json && echo 'Swagger JSON written to public/api-docs/v1/swagger.json'"

up-web: up-db bundle db-prepare
	$(DC) up web

logs:
	$(DC) logs -f web

down:
	$(DC) down

clean:
	$(DC) down -v

bash:
	$(DC) run --rm app bash



.PHONY: agent-watch
agent-watch:
	@echo "Starting local agent watcher (CTRL+C to stop)..."
	bash -lc "bash ./bin/agent_runner.sh"



.PHONY: brakeman
brakeman: bundle
	$(DC) run --rm app bash -lc "set -euo pipefail; mkdir -p tmp/brakeman; CMD=brakeman; if bundle show brakeman >/dev/null 2>&1; then CMD='bundle exec brakeman'; else echo 'Brakeman not in bundle; installing gem...'; gem install brakeman --no-document; fi; EXIT=0; $$CMD -q -c config/brakeman.yml -f json -o tmp/brakeman/brakeman.json -z || EXIT=$$?; $$CMD -q -c config/brakeman.yml -f html -o tmp/brakeman/brakeman.html || true; exit $$EXIT"