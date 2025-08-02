require 'minitest/autorun'
require 'eventstore_ruby'
require_relative 'cart_items'
require_relative '../../lib/read_model_helper'

class CartItemsTest < Minitest::Test
  include ReadModelHelper

  def test_cart_items
    with_read_model(CartItemsReadModel).
      given([
        EventStoreRuby::Event.new(event_type: "CartCreated", payload: { cart_id: "21711360-1d51-41d4-8843-ee2e9d6a3b88" }),
        EventStoreRuby::Event.new(event_type: "ItemAdded", payload: { cart_id: "21711360-1d51-41d4-8843-ee2e9d6a3b88", item_id: "21711360-1d51-41d4-8843-ee2e9d6a3b88", description: 'Test Item', image: 'http://example.com/image.png', product_id: "21711360-1d51-41d4-8843-ee2e9d6a3b89", price: 10.00 })
      ]).
      then(
        {
          "cart_id": "21711360-1d51-41d4-8843-ee2e9d6a3b88",
          "total_price": 10.00,
          "data": [
            {
              "item_id": "21711360-1d51-41d4-8843-ee2e9d6a3b88",
              "cart_id": "21711360-1d51-41d4-8843-ee2e9d6a3b88",
              "description": "Test Item",
              "image": "http://example.com/image.png",
              "price": 10.00,
              "product_id": "21711360-1d51-41d4-8843-ee2e9d6a3b89"
            }
          ]
        }
      )
  end

  def test_cart_items_with_removed_item
    with_read_model(CartItemsReadModel).
      given([
        EventStoreRuby::Event.new(event_type: "CartCreated", payload: { cart_id: "21711360-1d51-41d4-8843-ee2e9d6a3b88" }),
        EventStoreRuby::Event.new(event_type: "ItemAdded", payload: { cart_id: "21711360-1d51-41d4-8843-ee2e9d6a3b88", item_id: "21711360-1d51-41d4-8843-ee2e9d6a3b88", description: 'Test Item', image: 'http://example.com/image.png', product_id: "21711360-1d51-41d4-8843-ee2e9d6a3b89", price: 10.00 }),
        EventStoreRuby::Event.new(event_type: "ItemRemoved", payload: { cart_id: "21711360-1d51-41d4-8843-ee2e9d6a3b88", item_id: "21711360-1d51-41d4-8843-ee2e9d6a3b88" })
      ]).
      then(
        {
          "cart_id": "21711360-1d51-41d4-8843-ee2e9d6a3b88",
          "total_price": 0.0,
          "data": []
        }
      )
  end

  def test_cart_items_with_cleared_cart
    with_read_model(CartItemsReadModel).
      given([
        EventStoreRuby::Event.new(event_type: "CartCreated", payload: { cart_id: "21711360-1d51-41d4-8843-ee2e9d6a3b88" }),
        EventStoreRuby::Event.new(event_type: "ItemAdded", payload: { cart_id: "21711360-1d51-41d4-8843-ee2e9d6a3b88", item_id: "21711360-1d51-41d4-8843-ee2e9d6a3b88", description: 'Test Item', image: 'http://example.com/image.png', product_id: "21711360-1d51-41d4-8843-ee2e9d6a3b89", price: 10.00 }),
        EventStoreRuby::Event.new(event_type: "CartCleared", payload: { cart_id: "21711360-1d51-41d4-8843-ee2e9d6a3b88" })
      ]).
      then(
        {
          cart_id: "21711360-1d51-41d4-8843-ee2e9d6a3b88",
          total_price: 0.0,
          data: []
        }
      )
  end
end