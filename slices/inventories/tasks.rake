# frozen_string_literal: true

# Tasks related to the Inventories projection for this slice.
# Loaded automatically by the root Rakefile (see Dir.glob). 

namespace :projections do
  desc 'Rebuild Inventories projection (inventories table) from InventoryChanged events'
  task :rebuild_inventories do
    # Load dependencies relative to this file
    require_relative File.expand_path('../../lib/container', __dir__)
    require_relative File.expand_path('projector', __dir__)

    conn_str = ENV.fetch('DATABASE_URL') do
      abort '❌ Please set DATABASE_URL to your Postgres connection string'
    end

    Inventories::Projector.create_table(conn_str)
    puts '🔄 Rebuilding Inventories projection…'
    Inventories::Projector.rebuild(Application::Container.event_store, conn_str)
    puts '�� Done.'
  end

  desc 'Delete Inventories projection (inventories table)'
  task :delete_inventories do
    require_relative File.expand_path('../../lib/container', __dir__)
    require_relative File.expand_path('projector', __dir__)

    conn_str = ENV.fetch('DATABASE_URL') do
      abort '❌ Please set DATABASE_URL to your Postgres connection string'
    end

    Inventories::Projector.delete_table(conn_str)
    puts '🗑️  Deleted Inventories projection'
  end
end 