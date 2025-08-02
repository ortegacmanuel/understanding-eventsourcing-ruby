# frozen_string_literal: true

require 'eventstore_ruby'

module Application
  # Simple service container exposing a lazily-initialised singleton
  # PostgresEventStore instance. All application components should obtain
  # their event-store via `EventStoreRuby::Container.event_store` so that
  # the same connection and notifier are shared.
  module Container
    module_function

    def event_store
      @event_store ||= begin
        conn = ENV.fetch('DATABASE_URL') do
          abort '❌ DATABASE_URL environment variable must be set to use EventStoreRuby::Container'
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