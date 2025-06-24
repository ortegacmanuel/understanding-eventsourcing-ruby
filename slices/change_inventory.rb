require 'sinatra/base'
require_relative '../events/inventory_changed'

ChangeInventoryCommand = Data.define(:product_id, :quantity)

module ChangeInventoryCommandHandler
  def self.call(events, command)
    [InventoryChanged.new(data: { product_id: command.product_id, quantity: command.quantity })]
  end
end

class ChangeInventory < Sinatra::Base
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
    stored = settings.event_store.write(events: new_events)
    status 200
    { message: 'OK' }.to_json
  end
end 