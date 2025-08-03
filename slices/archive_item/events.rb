module ArchiveItem
  class ItemArchivedEvent < EventStoreRuby::Event
    def initialize(cart_id:, item_id:)
      payload = {
          cart_id: cart_id,
          item_id: item_id,
      }
      super(event_type: 'ItemArchived', payload: payload)
    end

    def cart_id; payload[:cart_id] end
    def item_id; payload[:item_id] end
  end
end 