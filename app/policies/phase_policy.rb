class PhasePolicy < FleetsuitePolicy
  attr_reader :user, :phase

  def initialize(user, phase)
    @user = user
    @phase = phase
  end

  def create?
    account_holder
  end

  def read?
    account_holder
  end

  def update?
    account_holder
  end

  def destroy?
    account_holder
  end

end