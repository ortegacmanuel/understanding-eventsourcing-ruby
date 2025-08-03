require_relative 'processor'

module ArchiveItem
  module Listener
    module_function

    # Returns a proc to stop subscription
    def start(event_store, cart_products_dataset)
      subscription = event_store.subscribe do |events|
        events.each { |ev| Processor.process_event(ev, event_store, cart_products_dataset) }
      end
      -> { subscription.unsubscribe }
    end
  end
end