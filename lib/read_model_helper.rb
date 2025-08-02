module ReadModelHelper
  def with_read_model(read_model_class)
    @read_model = read_model_class.new
    self
  end

  def given(events)
    @read_model.apply_event(events)
    self
  end

  def then(expected_state)
    assert_equal expected_state, @read_model.to_hash
  end
end
