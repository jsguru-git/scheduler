class AccountPolicy < FleetsuitePolicy
  attr_reader :user, :account

  def initialize(user, account)
    @user = user
    @account = account
  end

  def read?
    account_holder
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