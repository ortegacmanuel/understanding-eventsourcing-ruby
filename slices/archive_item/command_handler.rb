require_relative 'domain'

module ArchiveItem
  module CommandHandler
    module_function

    def execute(event_store, command)
      if (err = Domain.validate(command))
        return Domain::ArchiveItemFailure.new(success: false, error: err)
      end

      filter = EventStoreRuby.create_filter(['ItemAdded', 'ItemRemoved', 'ItemArchived'], [{ cart_id: command.cart_id }])
      qr = event_store.query(filter)

      result = Domain.decide(qr.events, command)
      return result unless result.success?

      event_store.append(result.events, filter, expected_max_sequence_number: qr.max_sequence_number)
      result
    end
  end
end 