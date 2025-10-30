# Testing Guide

## Running Tests

### Run all tests
```bash
bundle exec rspec
```

### Run specific test file
```bash
bundle exec rspec spec/models/restaurant_spec.rb
```

### Run specific test by line number
```bash
bundle exec rspec spec/models/restaurant_spec.rb:10
```

### Run tests with coverage
```bash
COVERAGE=true bundle exec rspec
```

After running with coverage, open `coverage/index.html` in your browser to see the detailed report.

### Run tests with profiling
```bash
bundle exec rspec --profile 10
```

This will show the 10 slowest examples.

## Test Organization

### Shared Examples
Located in `spec/support/shared_examples/`, these provide reusable test patterns:

- `use_case_error_handling.rb` - Error handling and ErrorReporter notifications
- `use_case_validations.rb` - Repository, params, and resource validations
- `use_case_success_scenarios.rb` - Common success scenarios (create, update, destroy, etc.)
- `use_case_failure_scenarios.rb` - Common failure scenarios

Usage example:
```ruby
RSpec.describe Restaurants::Create do
  let(:repo) { ::Repositories::Persistence::RestaurantsRepository.new }
  let(:call_params) { { repo: repo, params: { name: "Test" } } }

  it_behaves_like "a successful create use case", :restaurant
  it_behaves_like "a use case with repository validation"
  it_behaves_like "a use case with params validation"
end
```

### Test Types

#### Model Specs (`spec/models/`)
- Validations
- Associations
- Callbacks (normalizations)
- Scopes
- Instance methods

#### Use Case Specs (`spec/use_cases/`)
- Success scenarios
- Validation failures
- Error handling
- Repository/params validation

#### Repository Specs (`spec/repositories/`)
- CRUD operations
- Edge cases
- Bulk operations
- Query performance (N+1 prevention)

#### Blueprint Specs (`spec/blueprints/`)
- JSON serialization
- Field presence
- Nested associations

#### Request Specs (`spec/requests/`)
- API endpoints (with Rswag documentation)
- HTTP status codes
- Response formats
- Error handling

## Code Coverage

### Minimum Coverage Requirements
- Overall: 80%
- Per file: 70%

### Viewing Coverage Report
1. Run tests with coverage: `COVERAGE=true bundle exec rspec`
2. Open `coverage/index.html` in your browser
3. Click on files to see line-by-line coverage

### Coverage Groups
- Models
- Controllers
- Use Cases
- Repositories
- Blueprints
- Helpers
- Services

## Performance Testing

### N+1 Query Detection
Use the `exceed_query_limit` matcher to prevent N+1 queries:

```ruby
it "eager loads associations to avoid N+1 queries" do
  relation = repo.relation_for_index

  expect do
    relation.each do |r|
      r.menus.to_a
    end
  end.not_to exceed_query_limit(1)
end
```

## API Documentation

### Generate Swagger/OpenAPI docs
```bash
bundle exec rake rswag:specs:swaggerize
```

### View API documentation
Start the server and visit: http://localhost:3000/api-docs

## Best Practices

### 1. Use Factories, Not Fixtures
```ruby
# Good
let(:restaurant) { create(:restaurant) }

# Bad
let(:restaurant) { Restaurant.create!(name: "Test") }
```

### 2. Use Shared Examples for Common Patterns
```ruby
# Good
it_behaves_like "a use case with error handling", "restaurants.create"

# Bad - duplicating error handling tests in every spec
```

### 3. Test Edge Cases
- Nil values
- Empty strings
- Duplicate records
- Very long strings
- Concurrent updates
- Cascade deletions

### 4. Use Descriptive Context Blocks
```ruby
# Good
context "when validation fails" do
  context "with blank name" do
    # ...
  end
end

# Bad
it "fails with blank name" do
  # ...
end
```

### 5. One Expectation Per Example (when possible)
```ruby
# Good
it "creates a restaurant" do
  expect(result).to be_success
end

it "persists the restaurant" do
  expect(result[:restaurant]).to be_persisted
end

# Acceptable for related assertions
it "creates a restaurant with correct attributes" do
  expect(result).to be_success
  expect(result[:restaurant].name).to eq("Test")
end
```

### 6. Use let and let! Appropriately
```ruby
# Use let for lazy evaluation
let(:restaurant) { create(:restaurant) }

# Use let! when you need the record to exist before the test
let!(:existing_restaurant) { create(:restaurant, name: "Existing") }
```

## Debugging Tests

### Run with backtrace
```bash
bundle exec rspec --backtrace
```

### Run with warnings
```bash
bundle exec rspec --warnings
```

### Use binding.pry
Add `binding.pry` in your test to debug:
```ruby
it "does something" do
  binding.pry
  expect(result).to be_success
end
```

## Continuous Integration

### Running in CI
```bash
# Run all tests with coverage
COVERAGE=true RAILS_ENV=test bundle exec rspec

# Generate Swagger docs
bundle exec rake rswag:specs:swaggerize
```

### Coverage Enforcement
Tests will fail if coverage drops below:
- 80% overall
- 70% per file

## Additional Resources

- [BetterSpecs](https://www.betterspecs.org/) - RSpec best practices
- [RSpec Documentation](https://rspec.info/)
- [FactoryBot](https://github.com/thoughtbot/factory_bot)
- [Shoulda Matchers](https://github.com/thoughtbot/shoulda-matchers)
- [Rswag](https://github.com/rswag/rswag)

