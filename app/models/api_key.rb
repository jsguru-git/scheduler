class ApiKey < ActiveRecord::Base

  attr_accessible :access_token, :user_id

  belongs_to :user

  before_create :generate_access_token

  validates_presence_of :access_token, :user_id, :on => :save

private

  # Generate a random API token. Recur if the key is not unique
  def generate_access_token
    begin
      self.access_token = SecureRandom.hex
    end while self.class.exists?(access_token: access_token)
  end
end
