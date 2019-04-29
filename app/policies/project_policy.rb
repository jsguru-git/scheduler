class ProjectPolicy < FleetsuitePolicy
  attr_reader :user, :project

  def initialize(user, project)
    @user = user
    @project = project
  end

  def create?
    account_holder
  end

  def read?
    account_holder || administrator || leader || member
  end

  def update?
    account_holder || administrator
  end

  def destroy?
    account_holder
  end

end