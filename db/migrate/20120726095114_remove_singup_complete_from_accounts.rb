class RemoveSingupCompleteFromAccounts < ActiveRecord::Migration
    
  def change
      remove_column :accounts, :signup_complete
  end

end
