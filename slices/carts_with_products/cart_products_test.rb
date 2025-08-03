require 'minitest/autorun'
require 'eventstore_ruby'
require 'sequel'
require 'pg'
require_relative '../../lib/projector_helper'
require_relative 'projector'


class CartProductsReadModelTest < Minitest::Test
  include ProjectorHelper

  TEST_DB_URL = ENV.fetch('TEST_DATABASE_URL', 'postgres://localhost:5432/cart_products_test')

  def test_cart_with_products
    with_projector(CartsWithProducts::Projector, TEST_DB_URL).
      given([
        EventStoreRuby::Event.new(event_type: 'CartCreated', payload: { cart_id: 'c1' }),
        EventStoreRuby::Event.new(event_type: 'ItemAdded', payload: { cart_id: 'c1', item_id: 'i1', description: 'd', image: 'img', product_id: 'p1', price: 1.0 }),
        EventStoreRuby::Event.new(event_type: 'ItemAdded', payload: { cart_id: 'c1', item_id: 'i2', description: 'd', image: 'img', product_id: 'p2', price: 1.0 }),
        EventStoreRuby::Event.new(event_type: 'ItemRemoved', payload: { cart_id: 'c1', item_id: 'i1' })
      ]).
      then { |dataset|
        assert_equal [
          { cart_id: 'c1', item_id: 'i2', product_id: 'p2' }
        ], dataset.all.map { |r| { cart_id: r[:cart_id], item_id: r[:item_id], product_id: r[:product_id] } }
      }
  end
end 