require 'minitest/autorun'
require 'eventstore_ruby'

require_relative 'clear_cart'
require_relative '../../lib/command_handler_helper'

module ClearCart
  class ClearCartTest < Minitest::Test
    include CommandHandlerHelper

    def test_clear_cart_happy_path
      with_command_handler(ClearCartCommandHandler).
        given([
          EventStoreRuby::Event.new(event_type: "CartCreated", payload: { cart_id: 'cart123' })
        ]).
        when(
          ClearCartCommand.new(cart_id: 'cart123')
        ).
        then([
          EventStoreRuby::Event.new(event_type: "CartCleared", payload: { cart_id: 'cart123' })
        ])
    end

    def test_clear_cart_when_cart_does_not_exist
      with_command_handler(ClearCartCommandHandler).
        given([]).
        when(
          ClearCartCommand.new(cart_id: 'cart123')
        ).
        then_raises(ClearCartCommandHandler::CartDoesNotExist)
    end
  end
end