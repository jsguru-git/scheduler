class Document < ActiveRecord::Base
  
  
  # External libs
  include SharedMethods
  
  
  # Relationships
  belongs_to :user
  belongs_to :project
  has_many :document_comments, :dependent => :destroy
  
  
  # Validation
  validates :project_id, :user_id, :title, :provider, :presence => true
  validates :provider, :inclusion => { :in => %w(google dropbox local) }, :allow_blank => true
  validate  :check_associated
  
  validates :provider_document_ref, :mime_type, :view_link, :presence => true, :if => Proc.new { |doc| !doc.is_local? }
  validates :provider_document_ref, :uniqueness => {:scope => :project_id, :message => 'has already been attached to this project'}, :if => Proc.new { |doc| !doc.is_local? }
  
  validates_with AttachmentPresenceValidator, :attributes => :attachment, :if => Proc.new { |doc| doc.is_local? }
  validates_with AttachmentContentTypeValidator, :attributes => :attachment, :content_type => ["image/jpeg", "image/jpg", "image/pjpeg", "image/png", "image/x-png", "image/gif", "application/msword", "ms-excel", "application/pdf", "application/postscript", "application/rtf", "application/vnd.ms-excel", "application/vnd.ms-powerpoint", "application/vnd.ms-project", "audio/mpeg", "audio/x-wav", "video/avi", "audio/avi", "video/quicktime", "text/html", "text/plain", "application/vnd.openxmlformats-officedocument.wordprocessingml.document", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "application/vnd.openxmlformats-officedocument.presentationml.presentation"], :message => 'is not supported', :if => Proc.new { |doc| doc.is_local? }
  validates_with AttachmentSizeValidator, :attributes => :attachment, :less_than => 3.megabyte, :message => 'must be less than 3 megabytes', :if => Proc.new { |doc| doc.is_local? }

  
  # Callbacks
  before_validation :remove_whitespace
  before_create :set_file_type
  
  
  # Mass assignment protection
  attr_accessible :title, :provider, :provider_document_ref, :provider_owner_names, :mime_type, :view_link, :file_created_at, :file_type, :attachment
  
  
  # Plugins
  has_attached_file :attachment,
    :styles => {
      :thumbnail => "100x100#",
      :medium => "708x415>" },
    :s3_permissions => :private,
    #:s3_protocol => 'http',
    :path => "/:attachment/:id_partition/:hash/:style/:filename",
    :hash_secret => "FDDfdg4asdf6sdhgfjdf7iasdhflsdajhflksdahfiehfohsdaolajoi48485479234mghfDSIULUIGDFGJfoehoiheKFJ5vGRfSAD8doe3asdkfilsa"
  before_post_process :check_if_image? # Must be after the has_attached_file
  

#
# Extract functions
#


  # Named scopes
  scope :name_ordered, order('documents.title')
  

#
# Save functions
#


#
# Create functions
#


  # Public: Attach the given document ids
  def self.attach_from_provider(project, user, provider, document_ids)
    response = {:docs => [], :error => nil}
    if document_ids.blank? || APP_CONFIG['oauth'][provider].blank?
      response[:error] = 'Please select at least one document to attach'
      return response
    end
    
    storage = CloudStorage::Base.start(provider.to_sym, user)
    new_docs = []
    
    document_ids.each do |dcoument_id|
      item = storage.get_file_details(dcoument_id)

      document = project.documents.new(:provider => item[:provider], 
        :title => item[:title], 
        :provider_document_ref => item[:id], 
        :provider_owner_names => item[:owner_names], 
        :mime_type => item[:mime_type], 
        :view_link => item[:view_link], 
        :file_created_at => item[:created_at],
        :file_type => item[:file_type]
      )
      document.user_id = user.id
      
      if document.save
        response[:docs] << document
      else
        response[:error] = document.errors.full_messages.first
      end
    end
    response
  end


#
# Update functions
#


#
# General functions
#
  
  
  # Check to see if the file is a locally uploaded one
  def is_local?
    if self.provider.present? && self.provider == 'local'
      true
    else
      false
    end
  end


protected
  
  
  # Prevent imagemagick check on non image files (which throws an identiy error in error messages)
  def check_if_image?
    !(attachment_content_type =~ /^image.*/).nil?
  end
  

  # Check to see that the given project and user belong to the same account
  def check_associated
    if self.project_id.present? && self.user_id.present?
      self.errors.add(:project_id, 'must belong to the same account as the user') if self.project.account_id != self.user.account_id
    end
  end
  
  
  # Set the file type for local file uploads
  def set_file_type
    if self.is_local?
      if self.attachment_content_type.blank?
        self.file_type = "misc"
      elsif self.attachment_content_type == 'application/pdf'
        self.file_type = "pdf"
      elsif self.attachment_content_type.include?('powerpoint')
        self.file_type = "presentation"
      elsif self.attachment_content_type == 'application/zip'
        self.file_type = "zip"
      elsif self.attachment_content_type == "application/rtf" || self.attachment_content_type == 'text/plain' || self.attachment_content_type == 'application/msword' || self.attachment_content_type.include?('wordprocessing')
        self.file_type = "document"
      elsif self.attachment_content_type.include?('spreadsheet') || self.attachment_content_type == 'ms-excel'
        self.file_type = "spreadsheet"
      elsif self.attachment_content_type.include?('image')
        self.file_type = "image"
      else
        self.file_type = "misc"
      end
    end
  end
  
  
end
