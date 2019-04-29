class FeaturePolicy < FleetsuitePolicy
  attr_reader :user, :feature

  def initialize(user, feature)
    @user = user
    @feature = feature
  end

  def read?
    account_holder || administrator || leader
  end

  def create?
    account_holder
  end

  def update?
    account_holder
  end

  def destroy?
    account_holder
  end
end