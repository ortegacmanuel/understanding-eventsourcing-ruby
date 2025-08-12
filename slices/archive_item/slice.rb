require_relative '../../lib/slice'
require_relative 'listener'

module ArchiveItem
  extend Slice

  on_boot do |event_store:, app:, conn_str:, container:, **_|
    dataset_callable = container.resolve(:cart_products_dataset)
    dataset = dataset_callable.call
    Listener.start(event_store, dataset)
  end
end 