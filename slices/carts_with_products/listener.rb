require_relative 'projector'

module CartsWithProducts
  module Listener
    module_function

    def start(event_store, conn_str)
      subscription = event_store.subscribe do |events|
        events.each { |ev| Projector.process_event(conn_str, ev) }
      end
      -> { subscription.unsubscribe }
    end
  end
end