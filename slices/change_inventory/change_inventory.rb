require 'sinatra/base'

module ChangeInventory
  class InventoryChanged < EventStoreRuby::Event
    def initialize(product_id:, quantity:)
      payload = {
        product_id: product_id,
        quantity: quantity
      }
      super(event_type: 'InventoryChanged', payload: payload)
    end

    def product_id; payload[:product_id]; end
    def quantity; payload[:quantity]; end
  end

  ChangeInventoryCommand = Data.define(:product_id, :quantity)

  module ChangeInventoryCommandHandler
    def self.call(events, command)
      [InventoryChanged.new(product_id: command.product_id, quantity: command.quantity)]
    end
  end

  class API < Sinatra::Base
    configure do
      set :event_store, nil
    end

    post '/inventory_changed' do
      data = JSON.parse(request.body.read)
      command = ChangeInventoryCommand.new(
        product_id: data['product_id'],
        quantity: data['quantity']
      )
      new_events = ChangeInventoryCommandHandler.call([], command)
      settings.event_store.append(new_events)
      
      status 200
      { message: 'OK' }.to_json
    end
  end
end