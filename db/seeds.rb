# frozen_string_literal: true

# Seed performático para volume médio (~100k+) usando insert_all em lotes
# Ajuste via variáveis de ambiente conforme necessário.

RESTAURANTS_COUNT       = ENV.fetch("SEED_RESTAURANTS", "50000").to_i
MENUS_PER_RESTAURANT    = ENV.fetch("SEED_MENUS_PER_RESTAURANT", "2").to_i
MENU_ITEMS_POOL         = ENV.fetch("SEED_MENU_ITEMS", "500").to_i
PLACEMENTS_PER_MENU     = ENV.fetch("SEED_PLACEMENTS_PER_MENU", "2").to_i
BATCH_SIZE              = ENV.fetch("SEED_BATCH_SIZE", "5000").to_i

Rails.logger.debug do
  "Seeding with: restaurants=#{RESTAURANTS_COUNT}, menus_per_restaurant=#{MENUS_PER_RESTAURANT}, items_pool=#{MENU_ITEMS_POOL}, placements_per_menu=#{PLACEMENTS_PER_MENU}, batch_size=#{BATCH_SIZE}"
end

now = Time.current

# Helper para inserções em lote com silêncio de logs
def bulk_insert(klass, rows, unique_by: nil)
  return if rows.empty?

  ActiveRecord::Base.logger.silence do
    if unique_by
      klass.insert_all(rows, unique_by: unique_by)
    else
      klass.insert_all(rows)
    end
  end
end

# 1) Restaurants
if Restaurant.count < RESTAURANTS_COUNT
  Rails.logger.debug "Creating restaurants..."
  offset = Restaurant.maximum(:id).to_i
  remaining = RESTAURANTS_COUNT - Restaurant.count
  while remaining.positive?
    size = [remaining, BATCH_SIZE].min
    rows = Array.new(size) do |i|
      n = offset + i + 1
      { name: format("Restaurant %06d", n), created_at: now, updated_at: now }
    end
    bulk_insert(Restaurant, rows, unique_by: :index_restaurants_on_name)
    remaining -= size
    offset += size
    Rails.logger.debug { "  inserted batch, remaining=#{remaining}" }
  end
end

# 2) Menus (2 por restaurante, por padrão)
if Menu.count < Restaurant.count * MENUS_PER_RESTAURANT
  Rails.logger.debug "Creating menus..."
  names = (MENUS_PER_RESTAURANT == 1 ? ["Main"] : %w[Main Drinks]).first(MENUS_PER_RESTAURANT)
  Restaurant.in_batches(of: BATCH_SIZE) do |batch|
    rows = []
    batch.pluck(:id).each do |rid|
      names.each do |name|
        rows << { restaurant_id: rid, name: name, created_at: now, updated_at: now }
      end
    end
    bulk_insert(Menu, rows, unique_by: :index_menus_on_restaurant_id_and_name)
  end
end

# 3) MenuItems globais
if MenuItem.count < MENU_ITEMS_POOL
  Rails.logger.debug "Creating global menu_items..."

  # Nome realista e determinístico sem depender de Faker
  base_names = %w[
    Burger Cheeseburger DoubleBurger VeggieBurger ChickenBurger FishBurger
    Pizza Margherita Pepperoni FourCheese Calabrese Portuguesa
    Pasta Carbonara Bolognese Alfredo Pesto Lasagna Ravioli
    Salad Caesar Greek Caprese Cobb
    Soup Tomato Chicken Noodle Pumpkin Onion
    Sandwich BLT Club Tuna HamTurkey
    Tacos Burrito Quesadilla Nachos
    Sushi Nigiri Sashimi CaliforniaRoll SpicyTuna DragonRoll
    Steak Sirloin Ribeye FiletMignon
    Fries OnionRings Nuggets Wings
    IceCream Cheesecake Brownie Tiramisu ApplePie PannaCotta
    Coffee Espresso Latte Cappuccino Mocha
    Tea BlackTea GreenTea Chai
    Juice Orange Apple Grape Lemonade
  ]

  remaining = MENU_ITEMS_POOL - MenuItem.count
  offset = MenuItem.maximum(:id).to_i
  idx = 0
  while remaining.positive?
    size = [remaining, BATCH_SIZE].min
    rows = Array.new(size) do
      name = if idx < base_names.size
               base_names[idx]
             else
               # Garante unicidade e previsibilidade
               base = base_names[idx % base_names.size]
               suffix = (idx / base_names.size) + 1
               "#{base} #{suffix}"
             end
      idx += 1
      { name: name, created_at: now, updated_at: now }
    end
    bulk_insert(MenuItem, rows, unique_by: :index_menu_items_on_lower_name)
    remaining -= size
    Rails.logger.debug { "  inserted menu_items batch, remaining=#{remaining}" }
  end
end

# 4) MenuItemPlacements (coloca N itens por menu)
expected = Menu.count * PLACEMENTS_PER_MENU
if MenuItemPlacement.count < expected
  Rails.logger.debug "Creating menu_item_placements..."
  item_ids = MenuItem.pluck(:id)
  raise "No menu_items to place" if item_ids.empty?

  price_for = -> { ((rand * 40.0) + 10.0).round(2) }

  Menu.in_batches(of: BATCH_SIZE) do |batch|
    rows = []
    batch.pluck(:id).each do |menu_id|
      sample_ids = item_ids.sample(PLACEMENTS_PER_MENU)
      sample_ids.each do |item_id|
        rows << { menu_id: menu_id, menu_item_id: item_id, price: price_for.call, created_at: now, updated_at: now }
      end
    end
    bulk_insert(MenuItemPlacement, rows, unique_by: :index_menu_item_placements_on_menu_and_item)
  end
end

Rails.logger.debug do
  "Seed done. Counts: restaurants=#{Restaurant.count}, menus=#{Menu.count}, items=#{MenuItem.count}, placements=#{MenuItemPlacement.count}"
end
