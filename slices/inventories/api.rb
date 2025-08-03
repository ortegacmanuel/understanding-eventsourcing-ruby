require 'sinatra/base'
require_relative 'handler'

module Inventories
  class API < Sinatra::Base
    configure do
      set :event_store, nil
      set :conn_str, nil
    end
  
    get '/inventories/:product_id' do
      content_type :json
      
      inventory = Handler.call(settings.conn_str, params[:product_id]).inventory
      halt 404, { error: 'Inventory not found' }.to_json unless inventory

      inventory.to_h.to_json
    end
  end
end
