class PoliciesTest < ActionController::TestCase

  protected

  def assert_not_authorized(action, options = {}, method = :get)
    assert_raises Pundit::NotAuthorizedError do
      process(action, options, nil, nil, method.to_s.upcase)
    end
  end

  def assert_authorized(action, options = {}, method = :get)
    assert_nothing_raised Pundit::NotAuthorizedError do
      process(action, options, nil, nil, method.to_s.upcase)
    end
  end

end