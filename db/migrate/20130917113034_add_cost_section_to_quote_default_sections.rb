class AddCostSectionToQuoteDefaultSections < ActiveRecord::Migration
  def change
    add_column :quote_default_sections, :cost_section, :boolean, default: false
  end
end
