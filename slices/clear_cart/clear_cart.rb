require 'sinatra/base'

module ClearCart
  class CartCleared < EventStoreRuby::Event
    def initialize(cart_id:)
      super(event_type: 'CartCleared', payload: { cart_id: cart_id })
    end

    def cart_id; payload[:cart_id]; end
  end

  ClearCartCommand = Data.define(:cart_id)

  module ClearCartCommandHandler
    State = Data.define(:cart_exists)

    class CartDoesNotExist < StandardError; end

    def self.call(events, command)
      state = build_state(events)
      raise CartDoesNotExist if state.cart_exists == false
      
      [CartCleared.new(cart_id: command.cart_id)]
    end

    private

    def self.build_state(events)
      State.new(cart_exists: events.any? { |event| event.event_type == "CartCreated" })
    end
  end


  class API < Sinatra::Base
    configure do
      set :event_store, nil
    end

    post '/:cart_id/clear' do
      filter = EventStoreRuby.create_filter(
        ['CartCreated'], 
        [{cart_id: params[:cart_id]}]
      )
      query_result = settings.event_store.query(filter)
      events = query_result.events

      command = ClearCartCommand.new(cart_id: params[:cart_id])
      new_events = ClearCartCommandHandler.call(events, command)

      settings.event_store.append(
        new_events, 
        filter,
        expected_max_sequence_number: query_result.max_sequence_number
      )

      status 200
      { message: "Cart cleared" }.to_json
    rescue ClearCartCommandHandler::CartDoesNotExist
      status 404
      { error: "Cart does not exist" }.to_json
    end
  end
end
    