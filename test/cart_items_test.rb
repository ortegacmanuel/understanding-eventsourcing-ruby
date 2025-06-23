require 'minitest/autorun'
require_relative '../slices/cart_items'
require_relative 'read_model_helper'

class CartItemsTest < Minitest::Test
  include ReadModelHelper

  def test_cart_items
    with_read_model(CartItemsReadModel).
      given([
        CartCreated.new(
          data: {
            "cart_id" => "21711360-1d51-41d4-8843-ee2e9d6a3b88"
          }
        ),
        ItemAdded.new(
          data: {
            "cart_id" => "21711360-1d51-41d4-8843-ee2e9d6a3b88",
            "item_id" => "21711360-1d51-41d4-8843-ee2e9d6a3b88",
            "description" => 'Test Item',
            "image" => 'http://example.com/image.png',
            "product_id" => "21711360-1d51-41d4-8843-ee2e9d6a3b89",
            "price" => 10.00
          }
        )
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
end