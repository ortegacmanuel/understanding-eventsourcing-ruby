module Slices
  module_function
  SLICE_ROOT = File.expand_path('slices', __dir__)

  # ---  Auto-load every slice -------------------------------------------------
  Dir[File.join(SLICE_ROOT, '*/slice.rb')].sort.each { |path| require path }

  # All modules that extended Slice during the requires above
  ALL_SLICES = Slice.registry.freeze

  BOOT_ORDER = [CartsWithProducts] unless const_defined?(:BOOT_ORDER)

  def boot_all(event_store:, app:, conn_str:, **extra)
    ordered = BOOT_ORDER + (ALL_SLICES - BOOT_ORDER)

    require_relative 'lib/container'
    container = App::Container.new

    # Pre-register common shared dependencies explicitly
    container.register(:event_store, event_store)
    container.register(:conn_str,    conn_str)
    container.register(:app,         app)

    common_kwargs = {
      event_store: event_store,
      app:         app,
      conn_str:    conn_str,
      container:   container
    }.merge(extra)

    ordered.each { |slice_mod| slice_mod.boot!(**common_kwargs) }

    container
  end
end 