module Slice
  # Called when the module extends `Slice`.
  # Stores the boot callback so we can call it later.
  def self.extended(base)
    base.instance_variable_set(:@__boot_proc, nil)
    registry << base
  end

  # Returns array collecting all modules that extended Slice.
  def self.registry
    @registry ||= []
  end

  # Slice calls this to define what should happen at boot time.
  def on_boot(&blk)
    @__boot_proc = blk
  end

  # Framework calls this to boot the slice. Any keyword arguments
  # are forwarded to the slice's boot block. A slice simply ignores
  # the keywords it doesn't care about.
  def boot!(**kwargs)
    @__boot_proc&.call(**kwargs)
  end
end 