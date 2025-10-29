# RSpec Best Practices Guide

Este guia segue as melhores práticas da comunidade Ruby, RSpec e Rails.

## 📚 Referências

- [BetterSpecs](https://www.betterspecs.org/) - RSpec best practices
- [RSpec Style Guide](https://rspec.rubystyle.guide/)
- [Thoughtbot Testing Guide](https://github.com/thoughtbot/guides/tree/main/testing-rails)
- [FactoryBot Best Practices](https://github.com/thoughtbot/factory_bot/blob/master/GETTING_STARTED.md)

---

## 🎯 Princípios Fundamentais

### 1. Testes Devem Ser FIRST

- **F**ast - Rápidos
- **I**ndependent - Independentes
- **R**epeatable - Repetíveis
- **S**elf-validating - Auto-validáveis
- **T**imely - Oportunos

### 2. Arrange-Act-Assert (AAA)

```ruby
# Good
it "creates a restaurant" do
  # Arrange
  params = { name: "Test Restaurant" }
  
  # Act
  result = Restaurants::Create.call(params: params)
  
  # Assert
  expect(result).to be_a_success
end
```

### 3. One Assertion Per Test (quando possível)

```ruby
# Good
it "returns success" do
  expect(result).to be_a_success
end

it "creates a persisted restaurant" do
  expect(result[:restaurant]).to be_persisted
end

# Acceptable - assertions relacionadas
it "creates restaurant with correct attributes" do
  expect(result).to be_a_success
  expect(result[:restaurant].name).to eq("Test")
end
```

---

## 🏗️ Estrutura de Testes

### Describe vs Context

```ruby
# describe - para "coisas" (métodos, classes)
describe Restaurant do
  describe "#name" do
    # ...
  end
  
  describe ".ordered" do
    # ...
  end
end

# context - para "estados" ou "condições"
context "when name is blank" do
  # ...
end

context "with valid params" do
  # ...
end
```

### Let vs Let! vs Before

```ruby
# let - lazy evaluation (só executa quando chamado)
let(:restaurant) { create(:restaurant) }

# let! - eager evaluation (executa antes de cada teste)
let!(:existing_restaurant) { create(:restaurant) }

# before - para setup que não retorna valor
before do
  allow(ErrorReporter).to receive(:notify)
end
```

### Subject

```ruby
# Implicit subject
describe Restaurant do
  it { is_expected.to validate_presence_of(:name) }
end

# Named subject
subject(:create_restaurant) { Restaurants::Create.call(params: params) }

it "creates a restaurant" do
  expect(create_restaurant).to be_a_success
end
```

---

## 🏭 FactoryBot Best Practices

### Use Traits

```ruby
# Good
FactoryBot.define do
  factory :restaurant do
    sequence(:name) { |n| "Restaurant #{n}" }
    
    trait :with_menus do
      after(:create) do |restaurant|
        create_list(:menu, 3, restaurant: restaurant)
      end
    end
  end
end

# Usage
create(:restaurant, :with_menus)
```

### Use Sequences

```ruby
# Good
sequence(:name) { |n| "Restaurant #{n}" }

# Avoid
name { "Restaurant #{rand(1000)}" }
```

### Use Transient Attributes

```ruby
factory :restaurant do
  trait :with_menus do
    transient do
      menus_count { 3 }
    end
    
    after(:create) do |restaurant, evaluator|
      create_list(:menu, evaluator.menus_count, restaurant: restaurant)
    end
  end
end

# Usage
create(:restaurant, :with_menus, menus_count: 5)
```

### Build vs Create

```ruby
# Use build quando não precisa persistir
let(:restaurant) { build(:restaurant) }

# Use create quando precisa persistir
let(:restaurant) { create(:restaurant) }

# Use build_stubbed para testes unitários (mais rápido)
let(:restaurant) { build_stubbed(:restaurant) }
```

---

## 🎭 Custom Matchers

### Quando Criar

Crie custom matchers quando:
- A mesma expectativa é usada em múltiplos testes
- Melhora significativamente a legibilidade
- Encapsula lógica complexa de validação

```ruby
# Good - custom matcher
expect(result).to be_a_success

# Instead of
expect(result.success?).to be true
```

### Como Criar

```ruby
RSpec::Matchers.define :be_a_success do
  match do |result|
    result.success?
  end
  
  failure_message do |result|
    "expected success, but got: #{result.data}"
  end
end
```

---

## 🔍 Shared Examples

### Quando Usar

Use shared examples para:
- Comportamentos comuns entre múltiplas classes
- Reduzir duplicação de código
- Testar interfaces/contratos

```ruby
# Definition
RSpec.shared_examples "a use case with error handling" do |operation|
  context "when an error occurs" do
    it "notifies ErrorReporter" do
      # ...
    end
  end
end

# Usage
it_behaves_like "a use case with error handling", "restaurants.create"
```

---

## 📊 Performance

### Evite N+1 Queries

```ruby
# Good
it "eager loads associations" do
  expect do
    restaurants.each { |r| r.menus.to_a }
  end.not_to exceed_query_limit(1)
end
```

### Use Database Transactions

```ruby
# Default - usa transactions (rápido)
RSpec.configure do |config|
  config.use_transactional_fixtures = true
end

# Para testes específicos que precisam de truncation
it "does something", :no_transaction do
  # ...
end
```

### Profile Slow Tests

```bash
# No .rspec
--profile 10

# Ou via comando
bundle exec rspec --profile 10
```

---

## 🎨 Estilo e Convenções

### Naming

```ruby
# Good - descritivo e específico
describe "GET /api/v1/restaurants" do
  context "when restaurant exists" do
    it "returns the restaurant" do
      # ...
    end
  end
end

# Bad - vago
describe "restaurants" do
  it "works" do
    # ...
  end
end
```

### DRY (Don't Repeat Yourself)

```ruby
# Good - usa shared examples
it_behaves_like "a use case with validations"

# Bad - duplica código em cada spec
context "when params are invalid" do
  # ... mesmo código repetido em 10 specs
end
```

### Avoid Stubbing

```ruby
# Good - testa comportamento real
let(:restaurant) { create(:restaurant) }

# Avoid - stub excessivo
let(:restaurant) { double("Restaurant", name: "Test") }
```

---

## 🔒 Contract Testing

### Teste Schemas de API

```ruby
describe "GET /api/v1/restaurants/:id" do
  it "returns response matching schema" do
    get "/api/v1/restaurants/#{restaurant.id}"
    
    expect(json_response).to match_json_schema(
      id: :integer,
      name: :string,
      menus: :array
    )
  end
end
```

---

## 📝 Documentation

### Use RSpec Documentation Format

```bash
# .rspec
--format documentation
```

### Write Descriptive Examples

```ruby
# Good
it "creates a restaurant with normalized name" do
  # ...
end

# Bad
it "works" do
  # ...
end
```

---

## 🚀 CI/CD Best Practices

### Random Order

```ruby
# spec_helper.rb
config.order = :random
Kernel.srand config.seed
```

### Fail Fast (opcional)

```ruby
# Para CI
config.fail_fast = 1
```

### Coverage Thresholds

```ruby
# .simplecov
SimpleCov.start do
  minimum_coverage 80
  minimum_coverage_by_file 70
end
```

---

## 🎯 Checklist de Code Review

- [ ] Testes seguem padrão AAA (Arrange-Act-Assert)
- [ ] Usa `expect` ao invés de `should`
- [ ] Usa factories ao invés de fixtures
- [ ] Testa edge cases
- [ ] Usa shared examples para código duplicado
- [ ] Testes são independentes
- [ ] Nomes descritivos e claros
- [ ] Sem N+1 queries
- [ ] Coverage adequado (>80%)
- [ ] Testes passam em ordem aleatória

---

## 📖 Exemplos Práticos

### Model Spec

```ruby
RSpec.describe Restaurant, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
  end
  
  describe "associations" do
    it { is_expected.to have_many(:menus).dependent(:destroy) }
  end
  
  describe "scopes" do
    describe ".ordered" do
      it "returns restaurants ordered by name" do
        # ...
      end
    end
  end
end
```

### Use Case Spec

```ruby
RSpec.describe Restaurants::Create do
  subject(:create_restaurant) do
    described_class.call(repo: repo, params: params)
  end
  
  let(:repo) { Repositories::Persistence::RestaurantsRepository.new }
  let(:params) { { name: "Test Restaurant" } }
  
  it_behaves_like "a successful create use case", :restaurant
  it_behaves_like "a use case with params validation"
  it_behaves_like "a use case with error handling", "restaurants.create"
end
```

### Request Spec

```ruby
RSpec.describe "Restaurants API", type: :request do
  describe "GET /api/v1/restaurants" do
    it "returns all restaurants" do
      create_list(:restaurant, 3)
      
      get "/api/v1/restaurants"
      
      expect(response).to have_http_status(:ok)
      expect(json_response).to be_an(Array)
      expect(json_response.size).to eq(3)
    end
  end
end
```

---

## 🔗 Links Úteis

- [RSpec Documentation](https://rspec.info/)
- [FactoryBot](https://github.com/thoughtbot/factory_bot)
- [Shoulda Matchers](https://github.com/thoughtbot/shoulda-matchers)
- [SimpleCov](https://github.com/simplecov-ruby/simplecov)
- [Database Cleaner](https://github.com/DatabaseCleaner/database_cleaner)
- [Rswag](https://github.com/rswag/rswag)

