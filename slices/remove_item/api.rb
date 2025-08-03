require 'sinatra/base'
require_relative 'remove_item_command'
require_relative 'remove_item_command_handler'

module RemoveItem
  class API < Sinatra::Base
    configure do
      set :event_store, nil
    end

    delete '/remove_item' do
      content_type :json
      
      begin
        payload = JSON.parse(request.body.read)

        f_add_and_removes_operations = EventStoreRuby.create_filter(
          ['ItemAdded', 'ItemRemoved'], 
          [{cart_id: payload["cart_id"], item_id: payload["item_id"]}]
        )
        f_cleared_operations = EventStoreRuby.create_filter(
          ['CartCleared'], 
          [{cart_id: payload["cart_id"]}]
        )
        query = EventStoreRuby.create_query([f_add_and_removes_operations, f_cleared_operations])      
        query_result = settings.event_store.query(query)
        
        new_events = RemoveItemCommandHandler.call(query_result.events, RemoveItemCommand.new(
          cart_id: payload["cart_id"],
          item_id: payload["item_id"]
        ))
        
        settings.event_store.append(
          new_events, 
          query,
          expected_max_sequence_number: query_result.max_sequence_number
        )
    
        status 200
        { message: "Item removed" }.to_json
      rescue RemoveItemCommandHandler::ItemNotInCart
        status 404
        { error: "Item not found in cart" }.to_json
      rescue JSON::ParserError
        status 400
        { error: "Invalid JSON payload" }.to_json
      end
    end
  end
end