require 'sinatra/base'
require 'json'
require_relative 'projector'

module CartsWithProducts
  class API < Sinatra::Base
    configure do
      set :conn_str, nil
    end

    get '/carts/:cart_id/products' do
      content_type :json
      ds = CartsWithProducts::Projector.dataset(settings.conn_str)
      products = ds.where(cart_id: params[:cart_id]).all
      {
        cart_id: params[:cart_id],
        products: products
      }.to_json
    end
  end
end 