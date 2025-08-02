# frozen_string_literal: true

namespace :projections do
  desc 'Rebuild CartProducts projection (carts_with_products table) from cart-related events'
  task :rebuild_cart_products do
    require_relative File.expand_path('../../lib/container', __dir__)
    require_relative File.expand_path('projector', __dir__)

    conn_str = ENV.fetch('DATABASE_URL') do
      abort '❌ Please set DATABASE_URL to your Postgres connection string'
    end

    CartsWithProducts::Projector.create_table(conn_str)
    puts '🔄 Rebuilding CartProducts projection…'
    CartsWithProducts::Projector.rebuild(Application::Container.event_store, conn_str)
    puts '🏁 Done.'
  end

  desc 'Delete CartProducts projection table'
  task :delete_cart_products do
    require_relative File.expand_path('../../lib/container', __dir__)
    require_relative File.expand_path('projector', __dir__)

    conn_str = ENV.fetch('DATABASE_URL') do
      abort '❌ Please set DATABASE_URL to your Postgres connection string'
    end

    CartsWithProducts::Projector.delete_table(conn_str)
    puts '🗑️  Deleted CartProducts projection'
  end
end 