class TimingPolicy < FleetsuitePolicy
  attr_reader :user, :timing

  def initialize(user, timing)
    @user = user
    @timing = timing
  end

  def create?
    account_holder || administrator || leader || member
  end

  def read?
    account_holder || administrator || leader || member
  end

  def update?
    account_holder || administrator || leader || member
  end

  def destroy?
    account_holder || administrator || leader || member
  end

end