require_relative 'core'

module ArchiveItem
  module Handler
    module_function

    def execute(event_store, command)
      if (err = Core.validate(command))
        return Core::ArchiveItemFailure.new(success: false, error: err)
      end

      filter = EventStoreRuby.create_filter(['ItemAdded', 'ItemRemoved'], [{cart_id: command.cart_id}])
      qr = event_store.query(filter)
      state = Core.fold_state(qr.events, command.cart_id)
      result = Core.decide(command, state)
      return result unless result.success?

      event_store.append(result.events, filter, expected_max_sequence_number: qr.max_sequence_number)
      result
    end
  end
end