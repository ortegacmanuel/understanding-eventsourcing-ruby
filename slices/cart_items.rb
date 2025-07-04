require 'sinatra/base'

class CartItem
  attr_accessor :item_id, :cart_id, :description, :image, :price, :product_id

  def initialize(item_id:, cart_id:, description:, image:, price:, product_id:)
    @item_id = item_id
    @cart_id = cart_id
    @description = description
    @image = image
    @price = price
    @product_id = product_id
  end

  def to_hash
    {
      item_id: @item_id,
      cart_id: @cart_id,
      description: @description,
      image: @image,
      price: @price,
      product_id: @product_id
    }
  end
end

class CartItemsReadModel
  attr_accessor :cart_id, :total_price, :data

  def initialize
    @cart_id = nil
    @total_price = 0.0
    @data = []
  end

  def apply_event(events)
    events.each do |event|
      case event.type
      when "CartCreated"
        self.cart_id = event.data["cart_id"]
      when "ItemAdded"
        cart_item = CartItem.new(
          item_id: event.data["item_id"],
          cart_id: event.data["cart_id"],
          description: event.data["description"],
          image: event.data["image"],
          price: event.data["price"].to_f.round(2),
          product_id: event.data["product_id"]
        )
        self.data << cart_item
        self.total_price += event.data["price"].to_f
      when "ItemRemoved"
        self.data.delete_if { |item| item.item_id == event.data["item_id"] }
        self.total_price = self.data.sum {|item| item.price }
      when "CartCleared"
        self.data = []
        self.total_price = 0.0
      end
    end
    self
  end

  def to_hash
    {
      cart_id: self.cart_id,
      total_price: self.total_price.to_f.round(2),
      data: self.data.map(&:to_hash)
    }
  end
end


class CartItems < Sinatra::Base
  configure do
    set :event_store, nil
  end

  get '/:cart_id/items' do
    query = Kroniko::Query.new([
      Kroniko::QueryItem.new(
        types: %w[CartCreated ItemAdded ItemRemoved CartCleared], 
        properties: {"cart_id" => params[:cart_id]}
      )
    ])
  
    events = settings.event_store.read(query: query)
    cart_items = CartItemsReadModel.new.apply_event(events)
    JSON.pretty_generate(cart_items.to_hash)
  end
end
