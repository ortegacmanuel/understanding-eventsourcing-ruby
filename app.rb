require 'bundler/setup'

require 'kroniko'
require 'sinatra'
require "sinatra/reloader" if development?

class ItemAdded < Kroniko::Event; end
class ItemRemoved < Kroniko::Event; end
class CartCleared < Kroniko::Event; end

store = Kroniko::EventStore.new

store.subscribe do |event|
  puts "[SYNC] Event received: #{event['type']} - #{event['id']}"
end

store.subscribe_async do |event|
  puts "[ASYNC] Processing: #{event['id']}"
end

post '/events' do
  content_type :json
  payload = JSON.parse(request.body.read)
  stored = store.write(payload)
  stored.to_json
end

get '/events' do
  content_type :json

  query = Kroniko::Query.all
  options = Kroniko::ReadOptions.new(from: 2, backwards: true)

  store.read(query: query, options: options).map(&:to_h).to_json
end

post '/add_item' do
  content_type :json
  
  begin
    payload = JSON.parse(request.body.read)
    required_params = %w[cart_id description image price item_id product_id]
    
    missing_params = required_params - payload.keys
    if missing_params.any?
      status 400
      return { error: "Missing required parameters: #{missing_params.join(', ')}" }.to_json
    end

    query = Kroniko::Query.new([
      Kroniko::QueryItem.new(
        types: %w[ItemAdded ItemRemoved CartCleared], 
        properties: {"cart_id" => payload["cart_id"]
      })
    ])
    events = store.read(query: query)

    cart_items_count = events.reduce(0) do |count, event|
      case event.type
      when "ItemAdded" then count + 1
      when "ItemRemoved" then count - 1
      when "CartCleared" then 0
      else count
      end
    end
    
    if cart_items_count >= 3
      status 400
      return { error: "Cart cannot have more than 3 items" }.to_json
    end
    
    event = ItemAdded.new(
      data: {
        cart_id: payload["cart_id"],
        item_id: payload["item_id"],
        product_id: payload["product_id"],
        description: payload["description"],
        image: payload["image"],
        price: payload["price"]
      }
    )
    
    stored = store.write(
      events: [event], 
      condition: Kroniko::AppendCondition.new(
        fail_if_events_match: Kroniko::Query.new([
          Kroniko::QueryItem.new(
            types: ["ItemAdded"],
            properties: { "cart_id" => payload["cart_id"] }
          )
        ]),
        after: events.last&.position
      )
    )
    stored.to_json
  rescue JSON::ParserError
    status 400
    { error: "Invalid JSON payload" }.to_json
  rescue Kroniko::AppendConditionFailed
    status 400
    { error: "Condition failed" }.to_json
  end
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

    events = store.read(query: query)

    puts events.map(&:to_h).to_json

    item_count = events.reduce(0) do |count, event|
      case event.type
      when "ItemAdded" then count + 1
      when "ItemRemoved" then count - 1
      when "CartCleared" then 0
      else count
      end
    end

    if item_count > 0
      event = ItemRemoved.new(
        data: {
          cart_id: payload["cart_id"],
          item_id: payload["item_id"]
        }
      )

      store.write(events: [event])
      { message: "Item removed" }.to_json
    else
      status 404
      { error: "Item not found in cart" }.to_json
    end
  rescue JSON::ParserError
    status 400
    { error: "Invalid JSON payload" }.to_json
  end
end

delete '/clear_cart' do
  content_type :json

  begin
    payload = JSON.parse(request.body.read)

    event = CartCleared.new(
      data: {
        cart_id: payload["cart_id"]
      }
    )

    store.write(events: [event])
    { message: "Cart cleared" }.to_json
  rescue JSON::ParserError
    status 400
    { error: "Invalid JSON payload" }.to_json
  end
end

get '/cart/:cart_id/items' do
  content_type :json
  
  query = Kroniko::Query.new([
    Kroniko::QueryItem.new(
      types: %w[ItemAdded ItemRemoved CartCleared], 
      properties: {"cart_id" => params[:cart_id]}
    )
  ])

  events = store.read(query: query)
  
  cart_data = events.reduce({ cart_id: params[:cart_id], items: [], total: 0.0 }) do |acc, event|
    case event.type
    when "ItemAdded"
      acc[:items] << {
        'item_id' => event.data["item_id"],
        'cart_id' => event.data["cart_id"],
        'product_id' => event.data["product_id"],
        'image' => event.data["image"],
        'price' => event.data["price"],
        'description' => event.data["description"]
      }
      acc[:total] += event.data["price"].to_f
    when "ItemRemoved"
      remove_index = acc[:items].find_index { |item| item['item_id'] == event.data["item_id"] }
      if remove_index
        removed_item = acc[:items][remove_index]
        acc[:items].delete_at(remove_index)
        acc[:total] -= removed_item['price'].to_f
      end
    when "CartCleared"
      acc[:items] = []
      acc[:total] = 0.0
    end
    acc
  end

  cart_data.to_json
end