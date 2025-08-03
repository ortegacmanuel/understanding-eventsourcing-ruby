require 'minitest/autorun'
require 'eventstore_ruby'
require_relative 'change_inventory'
require_relative '../../lib/command_handler_helper'

module ChangeInventory
  class ChangeInventoryTest < Minitest::Test
    include CommandHandlerHelper

    def test_change_inventory_happy_path
      with_command_handler(ChangeInventoryCommandHandler).
        given([]).
        when(
          ChangeInventory::ChangeInventoryCommand.new(product_id: 'prod001', quantity: 42)
        ).
        then([
          InventoryChanged.new(product_id: 'prod001', quantity: 42)
        ])
    end
  end
end