require 'minitest/autorun'
require 'kroniko'
require_relative 'command_handler_helper'

require_relative '../events/cart_created'
require_relative '../events/item_added'
require_relative '../events/item_removed'

require_relative '../slices/remove_item/remove_item_command_handler'
require_relative '../slices/remove_item/remove_item_command'


class RemoveItemTest < Minitest::Test
  include CommandHandlerHelper

  def test_remove_item_happy_path
    with_command_handler(RemoveItemCommandHandler).
      given([
        CartCreated.new(data: { cart_id: "cart123" }),
        ItemAdded.new(data: {
          cart_id: "cart123",
          item_id: "item001",
          description: "Test Item",
          image: "http://example.com/image.png",
          product_id: "prod001",
          price: "10.99"
        })
      ]).
      when(
        RemoveItemCommand.new(
          cart_id: "cart123",
          item_id: "item001"
        )
      ).
      then([
        ItemRemoved.new(data: {
          cart_id: "cart123",
          item_id: "item001"
        })
      ])
  end

  def test_remove_item_already_removed_raises_error
    with_command_handler(RemoveItemCommandHandler).
      given([
        CartCreated.new(data: { cart_id: "cart123" }),
        ItemAdded.new(data: {
          cart_id: "cart123",
          item_id: "item001",
          description: "Test Item",
          image: "http://example.com/image.png",
          product_id: "prod001",
          price: "10.99"
        }),
        ItemRemoved.new(data: {
          cart_id: "cart123",
          item_id: "item001"
        })
      ]).
      when(
        RemoveItemCommand.new(
          cart_id: "cart123",
          item_id: "item001"
        )
      ).
      then_raises(RemoveItemCommandHandler::ItemNotInCart)
  end
end
