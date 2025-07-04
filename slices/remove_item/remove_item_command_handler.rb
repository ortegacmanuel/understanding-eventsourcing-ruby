require_relative '../../events/item_removed'

module RemoveItemCommandHandler
  State = Data.define(:item_count)

  class ItemNotInCart < StandardError; end
  class ItemAlreadyRemoved < StandardError; end

  def self.call(events, command)
    state = build_state(events)
    raise ItemNotInCart if state.item_count.zero?
    
    [ItemRemoved.new(
      data: {
        cart_id: command.cart_id,
        item_id: command.item_id
      }
    )]
  end

  private

  def self.build_state(events)
    events.reduce(State.new(item_count: 0)) do |state, event|
      case event.type
      when "ItemAdded" then State.new(item_count: state.item_count + 1)
      when "ItemRemoved" then State.new(item_count: state.item_count - 1)
      when "CartCleared" then State.new(item_count: 0)
      else state
      end
    end
  end
end