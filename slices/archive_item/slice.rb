require_relative '../../lib/slice'
require_relative 'listener'

module ArchiveItem
  extend Slice

  on_boot do |event_store:, app:, conn_str:, resolve:, **_|
    dataset_callable = resolve.call(:cart_products_dataset)
    raise '🚨 cart_products_dataset not registered' unless dataset_callable

    dataset = dataset_callable.call
    Listener.start(event_store, dataset)
  end
end 