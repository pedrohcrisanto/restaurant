# 🧪 Testing Suite - Restaurant API

Este projeto possui uma suite de testes completa seguindo as melhores práticas da comunidade Ruby, RSpec e Rails.

## 📊 Estatísticas

- **Cobertura de Código**: >80% (configurado com SimpleCov)
- **Total de Specs**: 30+ arquivos
- **Shared Examples**: 4 arquivos reutilizáveis
- **Custom Matchers**: 2 conjuntos (Use Cases e API)
- **Contract Tests**: Validação de schemas de API
- **Performance Tests**: Detecção de N+1 queries

## 📚 Documentação

- **[TESTING_GUIDE.md](TESTING_GUIDE.md)** - Guia completo de como executar e escrever testes
- **[BEST_PRACTICES.md](BEST_PRACTICES.md)** - Melhores práticas Ruby/RSpec/Rails

---

## 🛠️ Stack de Testes

## Gems Instaladas

### Testing Framework
- **RSpec Rails** - Framework de testes para Rails
- **FactoryBot Rails** - Criação de dados de teste
- **Faker** - Geração de dados fake
- **Shoulda Matchers** - Matchers adicionais para RSpec

### Code Quality
- **Rubocop** - Linter e formatador de código Ruby
- **Rubocop Rails** - Regras específicas para Rails
- **Rubocop RSpec** - Regras específicas para RSpec

### API Documentation
- **Rswag** - Documentação de API com Swagger/OpenAPI
- **Rswag Specs** - Geração de documentação a partir de specs
- **Rswag API** - Servir documentação da API
- **Rswag UI** - Interface Swagger UI

### Business Logic
- **U-Case** - Pattern para casos de uso
- **Blueprinter** - Serialização de objetos para JSON

## Como Usar

### Executar Testes

```bash
# Executar todos os testes
bundle exec rspec

# Executar um arquivo específico
bundle exec rspec spec/models/user_spec.rb

# Executar com documentação detalhada
bundle exec rspec --format documentation
```

### Rubocop

```bash
# Verificar código
bundle exec rubocop

# Auto-corrigir problemas
bundle exec rubocop -a

# Auto-corrigir problemas de forma segura
bundle exec rubocop -A
```

### FactoryBot

Crie factories em `spec/factories/`:

```ruby
# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password { "password123" }
  end
end
```

Use nas specs:

```ruby
# Criar instância
user = create(:user)

# Criar sem salvar
user = build(:user)

# Criar com atributos customizados
user = create(:user, name: "John Doe")
```

### Shoulda Matchers

```ruby
RSpec.describe User, type: :model do
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:email) }
  it { should have_many(:posts) }
end
```

### U-Case

Crie casos de uso em `app/use_cases/`:

```ruby
# app/use_cases/users/create.rb
module Users
  class Create < Micro::Case
    attributes :name, :email, :password

    def call!
      user = User.new(attributes)
      
      return Success(result: { user: user }) if user.save
      
      Failure(result: { errors: user.errors })
    end
  end
end
```

Use nos controllers:

```ruby
def create
  Users::Create.call(user_params)
    .on_success { |result| render json: result[:user], status: :created }
    .on_failure { |result| render json: result[:errors], status: :unprocessable_entity }
end
```

### Blueprinter

Crie blueprints em `app/blueprints/`:

```ruby
# app/blueprints/user_blueprint.rb
class UserBlueprint < Blueprinter::Base
  identifier :id

  fields :name, :email, :created_at

  view :detailed do
    fields :updated_at
    association :posts, blueprint: PostBlueprint
  end
end
```

Use nos controllers:

```ruby
def show
  user = User.find(params[:id])
  render json: UserBlueprint.render(user, view: :detailed)
end
```

### Rswag - Documentação de API

Crie specs de request em `spec/requests/`:

```ruby
# spec/requests/api/v1/users_spec.rb
require 'swagger_helper'

RSpec.describe 'api/v1/users', type: :request do
  path '/api/v1/users' do
    get 'Lista usuários' do
      tags 'Users'
      produces 'application/json'
      
      response '200', 'usuários encontrados' do
        schema type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :integer },
              name: { type: :string },
              email: { type: :string }
            }
          }
        
        run_test!
      end
    end

    post 'Cria usuário' do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'
      
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          email: { type: :string },
          password: { type: :string }
        },
        required: ['name', 'email', 'password']
      }

      response '201', 'usuário criado' do
        let(:user) { { name: 'John', email: 'john@example.com', password: 'password' } }
        run_test!
      end

      response '422', 'requisição inválida' do
        let(:user) { { name: '' } }
        run_test!
      end
    end
  end
end
```

Gerar documentação Swagger:

```bash
# Gerar arquivo swagger.yaml
bundle exec rake rswag:specs:swaggerize

# Acessar documentação em:
# http://localhost:3000/api-docs
```

## 📁 Estrutura de Diretórios

```
spec/
├── blueprints/              # Blueprint serialization tests
│   ├── restaurant_blueprint_spec.rb
│   ├── menu_blueprint_spec.rb
│   ├── menu_item_blueprint_spec.rb
│   └── menu_item_placement_blueprint_spec.rb
├── contracts/               # Contract/Schema validation tests
│   ├── restaurant_contract_spec.rb
│   └── menu_contract_spec.rb
├── factories/               # FactoryBot factories with traits
│   ├── restaurants.rb
│   ├── menus.rb
│   ├── menu_items.rb
│   └── menu_item_placements.rb
├── models/                  # Model specs (validations, associations, scopes)
│   ├── restaurant_spec.rb
│   ├── menu_spec.rb
│   ├── menu_item_spec.rb
│   └── menu_item_placement_spec.rb
├── repositories/            # Repository pattern tests
│   └── persistence/
│       ├── restaurants_repository_spec.rb
│       └── menus_repository_spec.rb
├── requests/                # API integration tests with Rswag
│   └── api/v1/
│       ├── restaurants_spec.rb
│       └── menus_spec.rb
├── support/                 # Test support files
│   ├── config/              # Configuration files
│   │   ├── database_cleaner.rb
│   │   ├── factory_bot.rb
│   │   └── shoulda_matchers.rb
│   ├── helpers/             # Test helpers
│   │   ├── request_helpers.rb
│   │   ├── factory_helpers.rb
│   │   └── database_helpers.rb
│   ├── matchers/            # Custom RSpec matchers
│   │   ├── use_case_matchers.rb
│   │   └── api_matchers.rb
│   ├── shared_examples/     # Reusable test patterns
│   │   ├── use_case_error_handling.rb
│   │   ├── use_case_validations.rb
│   │   ├── use_case_success_scenarios.rb
│   │   └── use_case_failure_scenarios.rb
│   └── query_counter.rb     # N+1 query detection
├── use_cases/               # Use case tests
│   ├── restaurants/
│   │   ├── create_spec.rb
│   │   ├── update_spec.rb
│   │   ├── destroy_spec.rb
│   │   ├── find_spec.rb
│   │   └── list_spec.rb
│   └── menus/
│       ├── create_spec.rb
│       ├── list_for_restaurant_spec.rb
│       └── find_for_restaurant_spec.rb
├── rails_helper.rb          # Rails-specific RSpec configuration
├── spec_helper.rb           # General RSpec configuration
├── swagger_helper.rb        # Rswag/OpenAPI configuration
├── README.md                # This file
├── TESTING_GUIDE.md         # Complete testing guide
└── BEST_PRACTICES.md        # Ruby/RSpec best practices

app/
├── blueprints/              # Blueprinter serializers
├── controllers/             # API controllers
├── models/                  # ActiveRecord models
├── repositories/            # Repository pattern
└── use_cases/               # Business logic (U-Case)
```

## 🚀 Quick Start

```bash
# Executar todos os testes
bundle exec rspec

# Executar com cobertura de código
COVERAGE=true bundle exec rspec

# Executar testes específicos
bundle exec rspec spec/models/restaurant_spec.rb

# Gerar documentação Swagger
bundle exec rake rswag:specs:swaggerize

# Ver documentação da API
# http://localhost:3000/api-docs
```

## 🎯 Recursos Principais

### 1. Shared Examples (DRY)

Reduz duplicação de código em ~60%:

```ruby
# Uso
it_behaves_like "a successful create use case", :restaurant
it_behaves_like "a use case with params validation"
it_behaves_like "a use case with error handling", "restaurants.create"
```

### 2. Custom Matchers

Melhora legibilidade dos testes:

```ruby
# Use Case Matchers
expect(result).to be_a_success
expect(result).to fail_with_type(:validation_error)
expect(result).to succeed_with_data(restaurant: restaurant)

# API Matchers
expect(response).to have_http_status_ok
expect(response).to return_json_with(%w[id name menus])
expect(json_response).to match_json_schema(id: :integer, name: :string)
```

### 3. Factory Traits

Criação flexível de dados de teste:

```ruby
# Traits disponíveis
create(:restaurant, :with_menus)
create(:restaurant, :with_full_menu)
create(:menu, :with_items, items_count: 10)
create(:menu_item_placement, :expensive)
create(:menu_item_placement, :cheap)
```

### 4. Test Helpers

Helpers para simplificar testes:

```ruby
# Request Helpers
json_get "/api/v1/restaurants"
json_post "/api/v1/restaurants", params: { name: "Test" }
expect(json_response).to include("id" => 1)

# Factory Helpers
restaurant = create_full_restaurant(menus_count: 3, items_per_menu: 5)
menu = create_menu_with_items(items_count: 10)

# Database Helpers
expect { action }.not_to exceed_query_limit(2)
queries = capture_queries { Restaurant.all.to_a }
```

### 5. Contract Testing

Valida schemas de API:

```ruby
# Garante que responses seguem o schema definido
expect(json_response).to match_json_schema(
  id: :integer,
  name: :string,
  menus: :array
)
```

### 6. Performance Testing

Detecta N+1 queries:

```ruby
it "eager loads associations to avoid N+1 queries" do
  expect do
    restaurants.each { |r| r.menus.to_a }
  end.not_to exceed_query_limit(1)
end
```

## 📈 Cobertura de Código

Execute com SimpleCov:

```bash
COVERAGE=true bundle exec rspec
open coverage/index.html
```

**Thresholds configurados:**
- Cobertura geral: 80%
- Por arquivo: 70%

## 🔍 Debugging

```bash
# Com backtrace completo
bundle exec rspec --backtrace

# Com warnings
bundle exec rspec --warnings

# Profile dos 10 testes mais lentos
bundle exec rspec --profile 10

# Executar apenas testes com :focus
bundle exec rspec --tag focus
```

## 📖 Mais Informações

- **[TESTING_GUIDE.md](TESTING_GUIDE.md)** - Guia completo de testes
- **[BEST_PRACTICES.md](BEST_PRACTICES.md)** - Melhores práticas
- **[BetterSpecs](https://www.betterspecs.org/)** - RSpec best practices
- **[RSpec Style Guide](https://rspec.rubystyle.guide/)** - Guia de estilo

---

**Desenvolvido seguindo as melhores práticas da comunidade Ruby, RSpec e Rails** 🚀

