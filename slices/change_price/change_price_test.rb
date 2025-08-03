require 'minitest/autorun'
require 'eventstore_ruby'
require_relative 'change_price'
require_relative '../../lib/command_handler_helper'

module ChangePrice
  class ChangePriceTest < Minitest::Test
    include CommandHandlerHelper

    def test_change_price_happy_path
      with_command_handler(ChangePriceCommandHandler).
        given([]).
        when(
          ChangePriceCommand.new(
            product_id: 'prod001',
            old_price:  9.99,
            new_price:  12.49
          )
        ).
        then([
          PriceChanged.new(
            product_id: 'prod001',
            old_price:  9.99,
            new_price:  12.49
          )
        ])
    end
  end
end