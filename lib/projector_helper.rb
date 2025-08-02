module ProjectorHelper
  def with_projector(projector_class, conn_str)
    @projector = projector_class
    @conn_str = conn_str
    CartsWithProducts::Projector.delete_table(@conn_str)
    CartsWithProducts::Projector.create_table(@conn_str)
    self
  end

  def given(events)
    events.each do |ev|
      @projector.process_event(@conn_str, ev)
    end
    self
  end

  def then(&block)
    block.call(@projector.dataset(@conn_str))
    @projector.delete_table(@conn_str) rescue nil
  end
end
