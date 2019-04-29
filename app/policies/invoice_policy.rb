class InvoicePolicy < FleetsuitePolicy
  attr_reader :user, :invoice

  def initialize(user, invoice)
    @user = user
    @invoice = invoice
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