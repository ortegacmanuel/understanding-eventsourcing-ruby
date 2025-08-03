require_relative 'handler'
require_relative 'commands'

module ArchiveItem
  module Processor    
    module_function

    def process_event(event, event_store, carts_with_products)
      return unless event.event_type == 'PriceChanged'

      carts_with_products.where(product_id: event.payload[:product_id]).each do |cart_product|
        cmd = ArchiveItemCommand.new( 
          cart_id: cart_product[:cart_id],
          product_id: cart_product[:product_id]
        )
        result = Handler.execute(event_store, cmd)
        puts result.inspect 
      end
    end    
  end
end