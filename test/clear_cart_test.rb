require 'minitest/autorun'
require 'kroniko'

require_relative '../slices/clear_cart'
require_relative 'command_handler_helper'
require_relative '../events/cart_created'
require_relative '../events/cart_cleared'

class ClearCartTest < Minitest::Test
  include CommandHandlerHelper

  def test_clear_cart_happy_path
    with_command_handler(ClearCartCommandHandler).
      given([
        CartCreated.new(data: { cart_id: 'cart123' })
      ]).
      when(
        ClearCartCommand.new(cart_id: 'cart123')
      ).
      then([
        CartCleared.new(data: { cart_id: 'cart123' })
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