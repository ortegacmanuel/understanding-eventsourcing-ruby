require 'minitest/autorun'
require 'kroniko'

require_relative '../slices/change_inventory'
require_relative 'command_handler_helper'
require_relative '../events/inventory_changed'

class ChangeInventoryTest < Minitest::Test
  include CommandHandlerHelper

  def test_change_inventory_happy_path
    with_command_handler(ChangeInventoryCommandHandler).
      given([]).
      when(
        ChangeInventoryCommand.new(product_id: 'prod001', quantity: 42)
      ).
      then([
        InventoryChanged.new(data: { product_id: 'prod001', quantity: 42 })
      ])
  end
end 