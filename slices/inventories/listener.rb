require_relative 'projector'

module Inventories
  module Listener
    module_function

    # Returns a proc to stop subscription
    def start(event_store, conn_str)
      subscription = event_store.subscribe do |events|
        events.each { |ev| Projector.process_event(conn_str, ev) }
      end
      -> { subscription.unsubscribe }
    end
  end
end