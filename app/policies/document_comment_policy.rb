class DocumentCommentPolicy < FleetsuitePolicy
  attr_reader :user, :document_comment

  def initialize(user, document_comment)
    @user = user
    @document_comment = document_comment
  end

  def read?
    account_holder || administrator || leader
  end

  def create?
    account_holder || administrator || leader
  end

  def update?
    account_holder
  end

  def destroy?
    account_holder
  end

end