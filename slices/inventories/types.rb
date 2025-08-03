module Inventories
  Inventory = Struct.new(:product_id, :quantity, keyword_init: true)
  QueryResult = Struct.new(:inventory, keyword_init: true)
end 