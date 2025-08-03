require 'minitest/autorun'

require_relative 'add_item'
require_relative '../../lib/command_handler_helper'

class AddItemTest < Minitest::Test
  include CommandHandlerHelper

  def test_add_item
    with_command_handler(AddItemCommandHandler).
      given([]).
      when(
        AddItemCommand.new(
          cart_id: "cart123",
          item_id: "21711360-1d51-41d4-8843-ee2e9d6a3b88",
          description: 'Test Item',
          image: 'http://example.com/image.png',
          product_id: "21711360-1d51-41d4-8843-ee2e9d6a3b89",
          price: '10.99'
        )
      ).
      then(
        [
          CartCreatedEvent.new(cart_id: "cart123"),
          ItemAddedEvent.new(
            cart_id: "cart123",
            item_id: "21711360-1d51-41d4-8843-ee2e9d6a3b88",
            description: 'Test Item',
            image: 'http://example.com/image.png',
            product_id: "21711360-1d51-41d4-8843-ee2e9d6a3b89",
            price: '10.99'
          )
        ]
      )
  end

  def test_add_item_raises_error_when_cart_is_full
    with_command_handler(AddItemCommandHandler).
      given(
        [
          ItemAddedEvent.new(
            cart_id: "cart123",
            item_id: "21711360-1d51-41d4-8843-ee2e9d6a3b86",
            description: 'Test Item',
            image: 'http://example.com/image.png',
            product_id: "21711360-1d51-41d4-8843-ee2e9d6a3b87",
            price: '10.99'
          ),
          ItemAddedEvent.new(
            cart_id: "cart123",
            item_id: "21711360-1d51-41d4-8843-ee2e9d6a3b87",
            description: 'Test Item',
            image: 'http://example.com/image.png',
            product_id: "21711360-1d51-41d4-8843-ee2e9d6a3b88",
            price: '10.99'
          ),
          ItemAddedEvent.new(
            cart_id: "cart123",
            item_id: "21711360-1d51-41d4-8843-ee2e9d6a3b89",
            description: 'Test Item',
            image: 'http://example.com/image.png',
            product_id: "21711360-1d51-41d4-8843-ee2e9d6a3b90",
            price: '10.99'
          )
        ]
      ).
      when(
        AddItemCommand.new(
          cart_id: "cart123",
          item_id: "21711360-1d51-41d4-8843-ee2e9d6a3b91",
          description: 'Test Item',
          image: 'http://example.com/image.png',
          product_id: "21711360-1d51-41d4-8843-ee2e9d6a3b92",
          price: '10.99'
        )
      ).
      then_raises(AddItemCommandHandler::TooManyItemsInCart)
  end
end
