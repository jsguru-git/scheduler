class QuotePolicy < FleetsuitePolicy
  attr_reader :user, :quote

  def initialize(user, quote)
    @user = user
    @quote = quote
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