module DomainTestHelper
  # Select the domain core module under test.
  # Example: with_core(Cart::Core)
  def with_domain(domain_mod)
    @domain = domain_mod
    self
  end

  # Seed past events (aggregate history)
  def given(events)
    @events = events
    self
  end

  # Provide the command to run against the core
  def when(command)
    @command = command
    self
  end

  # Expect the domain logic to succeed and emit exactly these events
  def then(expected_events)
    result = @domain.decide(@events, @command)

    assert result.success?, "Expected success but was failure"

    to_hash = ->(ev) { { type: ev.event_type, payload: ev.payload } }
    assert_equal expected_events.map(&to_hash), result.events.map(&to_hash)
  end

  # Expect the domain logic to fail with the given error type symbol/string
  def then_failure(expected_error_type)
    result = @domain.decide(@events, @command)

    refute result.success?, 'Expected failure but core returned success'
    assert_equal expected_error_type, result.error.type
  end
end 