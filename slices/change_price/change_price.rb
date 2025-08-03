require 'sinatra/base'

module ChangePrice
  class PriceChanged < EventStoreRuby::Event
    def initialize(product_id:, old_price:, new_price:)
      payload = {
        product_id: product_id,
        old_price: old_price,
        new_price: new_price
      }
      super(event_type: 'PriceChanged', payload: payload)
    end

    def product_id; payload[:product_id]; end
    def old_price;  payload[:old_price];  end
    def new_price;  payload[:new_price];  end
  end

  ChangePriceCommand = Data.define(:product_id, :old_price, :new_price)

  module ChangePriceCommandHandler
    module_function

    def call(events, command)
      [PriceChanged.new(product_id: command.product_id,
                        old_price:  command.old_price,
                        new_price:  command.new_price)]
    end
  end

  class API < Sinatra::Base
    configure do
      set :event_store, nil
    end

    post '/price_changed' do
      data = JSON.parse(request.body.read)

      command = ChangePriceCommand.new(
        product_id: data['product_id'],
        old_price:  data['old_price'],
        new_price:  data['new_price']
      )

      new_events = ChangePriceCommandHandler.call([], command)
      settings.event_store.append(new_events)

      status 200
      { message: 'OK' }.to_json
    end
  end
end