class TeamPolicy < FleetsuitePolicy
  attr_reader :user, :team

  def initialize(user, team)
    @user = user
    @team = team
  end

  def create?
    account_holder
  end

  def read?
    account_holder || administrator || leader || member
  end

  def update?
    account_holder
  end

  def destroy?
    account_holder
  end

end