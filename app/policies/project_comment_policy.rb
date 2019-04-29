class ProjectCommentPolicy < FleetsuitePolicy
  attr_reader :user, :project_comment

  def initialize(user, project_comment)
    @user = user
    @project_comment = project_comment
  end

  def read?
    account_holder || administrator
  end

  def create?
    account_holder || administrator
  end

  def update?
    account_holder
  end

  def destroy?
    account_holder
  end

end