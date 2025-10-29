# Testing and Documentation Setup

Este projeto está configurado com as seguintes gems para testes e documentação:

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

## Estrutura de Diretórios

```
spec/
├── factories/          # FactoryBot factories
├── models/            # Model specs
├── requests/          # Request specs (API tests)
├── support/           # Arquivos de suporte
│   ├── factory_bot.rb
│   └── shoulda_matchers.rb
├── rails_helper.rb    # Configuração Rails para RSpec
├── spec_helper.rb     # Configuração geral do RSpec
└── swagger_helper.rb  # Configuração do Rswag

app/
├── blueprints/        # Blueprinter serializers
└── use_cases/         # U-Case use cases
```

## Comandos Úteis

```bash
# Instalar dependências
bundle install

# Executar testes
bundle exec rspec

# Executar Rubocop
bundle exec rubocop

# Gerar documentação Swagger
bundle exec rake rswag:specs:swaggerize

# Executar servidor
rails server

# Acessar documentação da API
# http://localhost:3000/api-docs
```

