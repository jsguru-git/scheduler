class ClientPolicy < FleetsuitePolicy
  attr_reader :user, :client

  def initialize(user, client)
    @user = user
    @client = client
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