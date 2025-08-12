require_relative '../../lib/slice'
require_relative 'projector'
require_relative 'listener'
require_relative 'api'

module CartsWithProducts
  extend Slice

  on_boot do |event_store:, app:, conn_str:, container:, **_|
    Projector.create_table(conn_str)
    Listener.start(event_store, conn_str)

    container.register(:cart_products_dataset, -> (cs = conn_str) { Projector.dataset(cs) })

    API.set :conn_str, conn_str
    app.use API
  end
end 