require 'sinatra/base'
require_relative '../events/item_added'
require_relative '../events/cart_created'

AddItemCommand = Data.define(
  :cart_id,
  :item_id,
  :description,
  :image,
  :product_id,
  :price
)

module AddItemCommandHandler
  State = Data.define(:item_count)

  class TooManyItemsInCart < StandardError; end

  def self.call(events, command)
    state = build_state(events)
    if state.item_count >= 3
      raise TooManyItemsInCart
    end
    
    [
      CartCreated.new(
        data: {
          cart_id: command.cart_id,
        }
      ),
      ItemAdded.new(
        data: {
          cart_id: command.cart_id,
          item_id: command.item_id,
          product_id: command.product_id,
          description: command.description,
          image: command.image,
          price: command.price
        }
      )
    ]
  end

  private

  def self.build_state(events)
    events.reduce(State.new(item_count: 0)) do |state, event|
      case event.type
      when "ItemAdded" then State.new(item_count: state.item_count + 1)
      when "ItemRemoved" then State.new(item_count: state.item_count - 1)
      when "CartCleared" then State.new(item_count: 0)
      else state
      end
    end
  end
end


class AddItem < Sinatra::Base
  configure do
    set :event_store, nil
  end

  post '/add_item' do
      data = JSON.parse request.body.read

      query = Kroniko::Query.new([
        Kroniko::QueryItem.new(
          types: %w[ItemAdded ItemRemoved CartCleared], 
          properties: {"cart_id" => data["cart_id"]
        })
      ])
      events = settings.event_store.read(query: query)

      command = AddItemCommand.new(
        cart_id: data["cart_id"],
        item_id: data["item_id"],
        description: data["description"],
        image: data["image"],
        product_id: data["product_id"],
        price: data["price"]
      )
      new_events = AddItemCommandHandler.call(events, command)

      stored = settings.event_store.write(
        events: new_events, 
        condition: Kroniko::AppendCondition.new(
          fail_if_events_match: Kroniko::Query.new([
            Kroniko::QueryItem.new(
              types: ["ItemAdded"],
              properties: { "cart_id" => data["cart_id"] }
            )
          ]),
          after: events.last&.position
        )
      )

      status 200
      stored.to_json
  rescue AddItemCommandHandler::TooManyItemsInCart
    status 400
    { error: "Cart cannot have more than 3 items" }.to_json
  end
end
  