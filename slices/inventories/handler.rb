require 'time'
require 'pg'
require_relative 'types'

module Inventories
  module Handler
    module_function

    def call(conn_str, product_id)
      inventory = nil
      PG.connect(conn_str) do |conn|
        res = conn.exec('SELECT * FROM inventories WHERE id = $1', [product_id])
        inventory = Inventory.new(
          product_id: res.first['id'],
          quantity: res.first['quantity']
        )
      end
      QueryResult.new(inventory: inventory)
    end
  end
end