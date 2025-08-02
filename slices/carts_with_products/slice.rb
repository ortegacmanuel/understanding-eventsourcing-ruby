require_relative '../../lib/slice'
require_relative 'projector'
require_relative 'listener'
require_relative 'api'

module CartsWithProducts
  extend Slice

  on_boot do |event_store:, app:, conn_str:, **_|
    Projector.create_table(conn_str)
    Listener.start(event_store, conn_str)
    API.set :conn_str, conn_str
    app.use API
  end
end 