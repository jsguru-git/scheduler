class UserPolicy < FleetsuitePolicy
  attr_reader :user, :user_object

  def initialize(user, user_object)
    @user = user
    @user_object = user_object
  end

  def create?
    account_holder || administrator
  end

  def read?
    account_holder || administrator || leader || member
  end

  def update?
    if account_holder
      true
    elsif @user_object.id == @user.id
      true
    else
      false
    end
  end

  def destroy?
    account_holder || administrator
  end

end