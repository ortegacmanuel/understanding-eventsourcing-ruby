# frozen_string_literal: true

require 'eventstore_ruby'

module App
  # Registry responsible for constructing and owning the singleton
  # Event Store instance. Other parts of the app should obtain the
  # canonical event store from here.
  module Registry
    module_function

    def event_store
      @event_store ||= begin
        conn = ENV.fetch('DATABASE_URL') do
          abort '❌ DATABASE_URL must be set to start the event store'
        end

        store = EventStoreRuby::PostgresEventStore.new(connection_string: conn)
        store.initialize_database
        store
      end
    end

    # Optional helper to shut down the shared store gracefully
    def close!
      return unless defined?(@event_store) && @event_store

      @event_store.close if @event_store.respond_to?(:close)
      @event_store = nil
    end
  end
end 