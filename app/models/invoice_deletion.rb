class InvoiceDeletion < ActiveRecord::Base
  
  
  # External libs
  

  # Relationships
  belongs_to :user
  belongs_to :project
  belongs_to :account


  # Validation
  validates :account_id, :default_currency_total_amount_cents_exc_vat, :invoice_number, :invoice_date, :presence => true
  validate :check_associated
  

  # Callbacks


  # Mass assignment protection
  attr_accessible :project_id, :user_id, :default_currency_total_amount_cents_exc_vat, :invoice_number, :invoice_date


  # Plugins


#
# Extract functions
#


  # Named scopes



#
# Save functions
#


#
# Create functions
#


  # create an entry for the provided invoice
  def self.create_entry_for(invoice, current_user)
    invocie_deletion = InvoiceDeletion.new(
      :project_id => invoice.project_id, 
      :user_id => current_user.id, 
      :default_currency_total_amount_cents_exc_vat => invoice.default_currency_total_amount_cents_exc_vat, 
      :invoice_number => invoice.invoice_number, 
      :invoice_date => invoice.invoice_date)
    invocie_deletion.account_id = invoice.project.account_id
    invocie_deletion.save!
  end


#
# Update functions
#


#
# General functions
#

  
  # Remove invoice and create audit
  def self.destroy_invoice(invoice, current_user)
    invoice.destroy
    InvoiceDeletion.create_entry_for(invoice, current_user)
  end
  

protected
  
  
  
  # Check to see that eveyerthing belongs ot the same account
  def check_associated
    if self.account_id.present?
      if self.project_id.present?
        self.errors.add(:project_id, 'must belong to the same account as the invoice') if self.account_id != self.project.account_id
      end
      
      if self.user_id.present?
        self.errors.add(:user_id, 'must belong to the same account as the invoice') if self.account_id != self.user.account_id
      end
    end
  end
  
  
end
