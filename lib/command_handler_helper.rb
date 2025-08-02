module CommandHandlerHelper
  def with_command_handler(command_handler_class)
    @command_handler = command_handler_class
    self
  end

  def given(events)
    @events = events
    self
  end

  def when(command)
    @command = command
    self
  end

  def then(expected_events)
    actual_events = @command_handler.call(@events, @command)
    to_compare = ->(ev) { { type: ev.event_type, payload: ev.payload } }
    assert_equal expected_events.map(&to_compare),actual_events.map(&to_compare)
  end

  def then_raises(error)
    assert_raises(error) do
      @command_handler.call(@events, @command)
    end
  end
end
  