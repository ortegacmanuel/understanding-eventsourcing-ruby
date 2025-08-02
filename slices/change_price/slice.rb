require_relative '../../lib/slice'
require_relative 'change_price'

module ChangePriceSlice
  extend Slice

  on_boot do |event_store:, app:, **_|
    ChangePrice.set :event_store, event_store
    app.use ChangePrice
  end
end 