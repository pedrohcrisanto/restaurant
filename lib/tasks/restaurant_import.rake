# frozen_string_literal: true

namespace :restaurant do
  desc 'Import restaurants/menus/items from a JSON file path (e.g., rails restaurant:import_json[contexts/data.json])'
  task :import_json, [:path] => :environment do |_t, args|
    path = args[:path]
    unless path && File.exist?(path)
      abort "Usage: rails restaurant:import_json[PATH_TO_JSON]; file not found: #{path}"
    end

    content = File.read(path)
    result = Imports::RestaurantsJson::Process.call(json: content)

    puts "Success: #{result[:success].inspect}"
    Array(result[:logs]).each do |log|
      puts log.inspect
    end

    exit(result.success? ? 0 : 1)
  end
end

