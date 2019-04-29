class DocumentPolicy < FleetsuitePolicy
  attr_reader :user, :document

  def initialize(user, document)
    @user = user
    @document = document
  end

  def read?
    account_holder || administrator
  end

  def create?
    account_holder || administrator
  end

  def update?
    account_holder || administrator
  end

  def destroy?
    account_holder
  end
end