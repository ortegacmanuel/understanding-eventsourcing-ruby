module Slices
  module_function
  SLICE_ROOT = File.expand_path('slices', __dir__)

  # ---  Auto-load every slice -------------------------------------------------
  Dir[File.join(SLICE_ROOT, '*/slice.rb')].sort.each { |path| require path }

  # All modules that extended Slice during the requires above
  ALL_SLICES = Slice.registry.freeze

  # Developers can write: BOOT_ORDER = [Inventories, PaymentsSlice]
  # Any slice omitted from this list will be appended automatically.
  BOOT_ORDER = [] unless const_defined?(:BOOT_ORDER)

  # ---------------------------------------------------------------------------
  # Public: Boot every slice.
  #   Dependencies shared with slices are given as keyword arguments.  In
  #   addition we always pass `register:` / `resolve:` lambdas so slices can
  #   expose or consume optional services from other slices.
  # ---------------------------------------------------------------------------
  def boot_all(event_store:, app:, conn_str:, **extra)
    # Final order: whatever the developer requested, followed by the rest.
    ordered = BOOT_ORDER + (ALL_SLICES - BOOT_ORDER)

    # Simple container implemented with a Hash
    container = {}
    register  = ->(key, value) { container[key] = value }
    resolve   = ->(key)        { container[key] }

    common_kwargs = {
      event_store: event_store,
      app:         app,
      conn_str:    conn_str,
      register:    register,
      resolve:     resolve
    }.merge(extra)

    ordered.each { |slice_mod| slice_mod.boot!(**common_kwargs) }
  end
end 