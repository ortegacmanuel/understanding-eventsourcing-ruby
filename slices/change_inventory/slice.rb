require_relative '../../lib/slice'
require_relative 'change_inventory'
require_relative 'inventory_changed_rabbitmq_consumer'

module ChangeInventory
  extend Slice

  on_boot do |event_store:, app:, container:, **_|
    ChangeInventory::API.set :event_store, event_store
    app.use ChangeInventory::API

    consumer = ChangeInventory::InventoryChangedRabbitmqConsumer.new(
      amqp_url: ENV.fetch('AMQP_URL'),
      exchange: ENV.fetch('INV_EXCHANGE'),
      queue: ENV.fetch('INV_QUEUE'),
      routing_key: ENV.fetch('INV_ROUTING'),
      event_store: event_store
    )

    consumer.start!
  end
end 