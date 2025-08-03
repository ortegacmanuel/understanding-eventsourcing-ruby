require_relative 'events'

module ArchiveItem
  module Core
    CartItem = Struct.new(:item_id, :product_id)
    ArchiveItemState = Struct.new(:cart_items)

    ArchiveItemError = Struct.new(:type, :message)
    ArchiveItemSuccess = Struct.new(:success, :events, keyword_init: true) do
      def success? = success
    end
    ArchiveItemFailure = Struct.new(:success, :error, keyword_init: true) do
      def success? = success
    end

    module_function

    def validate(cmd)
      return ArchiveItemError.new('InvalidProduct', 'Product ID is required') if cmd.product_id.nil?
      return ArchiveItemError.new('InvalidCart', 'Cart ID is required') if cmd.cart_id.nil?
      
      nil
    end

    def fold_state(events, cart_id)
      cart_items = []
      events.each do |e|
        case e.event_type
        when 'ItemAdded'
          cart_items << CartItem.new(e.payload[:item_id], e.payload[:product_id])
        when 'ItemRemoved'
          cart_items.delete_if { |item| item.item_id == e.payload[:item_id] }
        end
      end
      ArchiveItemState.new(cart_items)
    end

    def decide(cmd, state)
      cart_item = state.cart_items.find { |item| item.product_id == cmd.product_id }
      return ArchiveItemFailure.new(success: false, error: ArchiveItemError.new('ItemNotFound', 'Item not found in cart')) if cart_item.nil?

      event = ArchiveItem::ItemArchivedEvent.new(
        cart_id: cmd.cart_id,
        item_id: cart_item.item_id
      )
      ArchiveItemSuccess.new(success: true, events: [event])
    end
  end
end
