require 'minitest/autorun'
require 'eventstore_ruby'

require_relative 'remove_item'
require_relative '../../lib/command_handler_helper'

class RemoveItemTest < Minitest::Test
  include CommandHandlerHelper

  def test_remove_item_happy_path
    with_command_handler(RemoveItemCommandHandler).
      given([
        EventStoreRuby::Event.new(event_type: "CartCreated", payload: { cart_id: "cart123" }),
        EventStoreRuby::Event.new(event_type: "ItemAdded", payload: {
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
        EventStoreRuby::Event.new(event_type: "ItemRemoved", payload: {
          cart_id: "cart123",
          item_id: "item001"
        })
      ])
  end

  def test_remove_item_already_removed_raises_error
    with_command_handler(RemoveItemCommandHandler).
      given([
        EventStoreRuby::Event.new(event_type: "CartCreated", payload: { cart_id: "cart123" }),
        EventStoreRuby::Event.new(event_type: "ItemAdded", payload: {
          cart_id: "cart123",
          item_id: "item001",
          description: "Test Item",
          image: "http://example.com/image.png",
          product_id: "prod001",
          price: "10.99"
        }),
        EventStoreRuby::Event.new(event_type: "ItemRemoved", payload: {
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
