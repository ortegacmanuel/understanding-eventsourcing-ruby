require 'sinatra/base'
require_relative '../events/cart_created'
require_relative '../events/cart_cleared'

ClearCartCommand = Data.define(:cart_id)

module ClearCartCommandHandler
  State = Data.define(:cart_exists)

  class CartDoesNotExist < StandardError; end

  def self.call(events, command)
    state = build_state(events)
    raise CartDoesNotExist if state.cart_exists == false
    
    [CartCleared.new(data: {cart_id: command.cart_id})]
  end

  private

  def self.build_state(events)
    State.new(cart_exists: events.any? { |event| event.type == "CartCreated" })
  end
end


class ClearCart < Sinatra::Base
  configure do
    set :event_store, nil
  end

  post '/:cart_id/clear' do
      query = Kroniko::Query.new([
        Kroniko::QueryItem.new(
          types: %w[CartCreated], 
          properties: {"cart_id" => params[:cart_id]
        })
      ])
      events = settings.event_store.read(query: query)

      command = ClearCartCommand.new(cart_id: params[:cart_id])
      new_events = ClearCartCommandHandler.call(events, command)

      stored = settings.event_store.write(events: new_events)

      status 200
      { message: "Cart cleared" }.to_json
  rescue ClearCartCommandHandler::CartDoesNotExist
    status 404
    { error: "Cart does not exist" }.to_json
  end
end
  