class PaymentProfilePolicy < FleetsuitePolicy
  attr_reader :user, :payment_profile

  def initialize(user, payment_profile)
    @user = user
    @payment_profile = payment_profile
  end

  def read?
    account_holder || administrator
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