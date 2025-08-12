require_relative '../../lib/slice'
require_relative 'change_price'

module ChangePrice
  extend Slice

  on_boot do |event_store:, app:, container:, **_|
    ChangePrice::API.set :event_store, event_store
    app.use ChangePrice::API
  end
end 