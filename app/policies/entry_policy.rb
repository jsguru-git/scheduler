class EntryPolicy < FleetsuitePolicy
  attr_reader :user, :entry

  def initialize(user, entry)
    @user = user
    @entry = entry
  end

  def read?
    account_holder || administrator || leader || member
  end

  def report?
    account_holder || administrator || leader
  end

  def create?
    account_holder || administrator
  end

  def update?
    create?
  end

  def destroy?
    create?
  end
end