require 'sinatra/base'
require_relative 'remove_item_command'
require_relative 'remove_item_command_handler'

class RemoveItem < Sinatra::Base
  configure do
    set :event_store, nil
  end

  delete '/remove_item' do
    content_type :json
    
    begin
      payload = JSON.parse(request.body.read)
  
      query = Kroniko::Query.new([
        Kroniko::QueryItem.new(
          types: %w[ItemAdded ItemRemoved], 
          properties: {"cart_id" => payload["cart_id"], "item_id" => payload["item_id"]}
        ),
        Kroniko::QueryItem.new(
          types: %w[CartCleared], 
          properties: {"cart_id" => payload["cart_id"]}
        )
      ])
      events = settings.event_store.read(query: query)
      
      new_events = RemoveItemCommandHandler.call(events, RemoveItemCommand.new(
        cart_id: payload["cart_id"],
        item_id: payload["item_id"]
      ))
      settings.event_store.write(events: new_events)
  
      status 200s
      { message: "Item removed" }.to_json
    rescue RemoveItemCommandHandler::ItemNotFound
      status 404
      { error: "Item not found in cart" }.to_json
    rescue JSON::ParserError
      status 400
      { error: "Invalid JSON payload" }.to_json
    end
  end
end