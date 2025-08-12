# frozen_string_literal: true

module App
  # Minimal explicit DI container used for cross-slice collaboration
  class Container
    def initialize
      @store = {}
    end

    def register(key, value)
      raise ArgumentError, "Key already registered: #{key.inspect}" if @store.key?(key)
      @store[key] = value
    end

    def resolve(key)
      @store.fetch(key) { raise KeyError, "Missing dependency: #{key.inspect}" }
    end

    def key?(key)
      @store.key?(key)
    end
  end
end