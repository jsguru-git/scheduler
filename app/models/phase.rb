class Phase < ActiveRecord::Base

  belongs_to :account
  has_many :projects, dependent: :nullify

  attr_accessible :name

end
