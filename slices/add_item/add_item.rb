require 'sinatra/base'
require 'eventstore_ruby'

class CartCreatedEvent < EventStoreRuby::Event
  def initialize(cart_id:)
    payload = {
      cart_id: cart_id
    }
    super(event_type: 'CartCreated', payload: payload)
  end
end

class ItemAddedEvent < EventStoreRuby::Event
  def initialize(cart_id:, item_id:, description:, image:, product_id:, price:)
    payload = {
      cart_id: cart_id,
      item_id: item_id,
      description: description,
      image: image,
      product_id: product_id,
      price: price
    }
    super(event_type: 'ItemAdded', payload: payload)
  end

  def cart_id; payload[:cart_id]; end
  def item_id; payload[:item_id]; end
  def description; payload[:description]; end
  def image; payload[:image]; end
  def product_id; payload[:product_id]; end
  def price; payload[:price]; end
end

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
      CartCreatedEvent.new(
        cart_id: command.cart_id,
      ),
      ItemAddedEvent.new(
          cart_id: command.cart_id,
          item_id: command.item_id,
          product_id: command.product_id,
          description: command.description,
          image: command.image,
          price: command.price
      )
    ]
  end

  private

  def self.build_state(events)
    events.reduce(State.new(item_count: 0)) do |state, event|
      case event.event_type
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

      filter = EventStoreRuby.create_filter(
        ['ItemAdded', 'ItemRemoved', 'CartCleared'], 
        [{cart_id: data["cart_id"]}]
      )
      query_result = settings.event_store.query(filter)
      events = query_result.events

      command = AddItemCommand.new(
        cart_id: data["cart_id"],
        item_id: data["item_id"],
        description: data["description"],
        image: data["image"],
        product_id: data["product_id"],
        price: data["price"]
      )
      new_events = AddItemCommandHandler.call(events, command)

      settings.event_store.append(
        new_events, 
        filter,
        expected_max_sequence_number: query_result.max_sequence_number
      )

      status 200
      {cart_id: command.cart_id}.to_json
  rescue AddItemCommandHandler::TooManyItemsInCart
    status 400
    { error: "Cart cannot have more than 3 items" }.to_json
  end
end
  