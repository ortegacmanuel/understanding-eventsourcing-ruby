require 'minitest/autorun'
require 'eventstore_ruby'

require_relative 'commands'
require_relative 'events'
require_relative 'domain'
require_relative '../../lib/domain_test_helper'

module ArchiveItem
  class ArchiveItemCoreTest < Minitest::Test
    include DomainTestHelper

    def test_archive_item_success
      with_domain(ArchiveItem::Domain).
        given([
          EventStoreRuby::Event.new(event_type: 'CartCreated', payload: {cart_id: 'c1'}),
          EventStoreRuby::Event.new(event_type: 'ItemAdded', payload: {cart_id: 'c1', item_id: 'i1', description: 'x', image: 'img', product_id: 'p1', price: 10.0})
        ]).
        when(
          ArchiveItem::ArchiveItemCommand.new(cart_id: 'c1', product_id: 'p1')
        ).
        then([
          EventStoreRuby::Event.new(event_type: 'ItemArchived', payload: {cart_id: 'c1', item_id: 'i1'})
        ])
    end

    def test_archive_item_not_found
      with_domain(ArchiveItem::Domain).
        given([
          EventStoreRuby::Event.new(event_type: 'CartCreated', payload: {cart_id: 'c1'}),
          EventStoreRuby::Event.new(event_type: 'ItemAdded', payload: {cart_id: 'c1', item_id: 'i1', description: 'x', image: 'img', product_id: 'p2', price: 10.0})
        ]).
        when(
          ArchiveItem::ArchiveItemCommand.new(cart_id: 'c1', product_id: 'p1')
        ).
        then_failure('ItemNotFound')
    end
  end
end