class TaskPolicy < FleetsuitePolicy
  attr_reader :user, :task

  def initialize(user, task)
    @user = user
    @task = task
  end

  def create?
    account_holder
  end

  def read?
    account_holder || administrator || leader
  end

  def update?
    account_holder
  end

  def destroy?
    account_holder
  end

end