require 'sequel'

module CartsWithProducts
  module Projector
    module_function

    def db(conn_str)
      @db ||= {}
      @db[conn_str] ||= Sequel.connect(conn_str)
    end

    def dataset(conn_str)
      db(conn_str)[:cart_products]
    end

    def create_table(conn_str)
      db(conn_str).create_table?(:cart_products) do
        column :cart_id, 'text', null: false
        column :product_id,  'text', null: false
        column :item_id,     'text', null: false
        primary_key [:cart_id, :item_id]
      end
    end

    def delete_table(conn_str)
      db(conn_str).drop_table?(:cart_products)
    end

    def process_event(conn_str, event)
      payload = event.payload
      cart_id     = payload[:cart_id]
      product_id  = payload[:product_id]
      item_id     = payload[:item_id]

      ds = dataset(conn_str)

      case event.event_type
      when 'ItemAdded'
        ds.insert_conflict(target: [:cart_id, :item_id], update: {product_id: Sequel[:excluded][:product_id]})
          .insert(cart_id: cart_id, product_id: product_id, item_id: item_id)
      when 'ItemRemoved', 'ItemArchived'
        puts "Removing item #{item_id} from cart #{cart_id}"
        ds.where(cart_id: cart_id, item_id: item_id).delete
      when 'CartCleared'
        ds.where(cart_id: cart_id).delete
      end
    end

    def rebuild(event_store, conn_str)
      create_table(conn_str)
      dataset(conn_str).delete

      filter = EventStoreRuby.create_filter(%w[ItemAdded ItemRemoved CartCleared ItemArchived])
      events = event_store.query(filter).events
      events.each { |ev| process_event(conn_str, ev) }
    end
  end
end