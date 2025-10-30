# frozen_string_literal: true

# Top-level namespace for repositories under app/repositories/persistence
module Persistence
end

# Backward-compatible alias: allow existing references to Repositories::Persistence
# while aligning Zeitwerk autoloading (which expects `Persistence` from this path).
module Repositories
  Persistence = ::Persistence
end
