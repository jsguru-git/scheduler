class Tweet < ActiveRecord::Base

  # External libs
  include SharedMethods
  include HTTParty
  
  format :xml


  # Validation
  validates_presence_of     :tweet_id_ref, :title, :user_name, :published_at
  validates_numericality_of :tweet_id_ref, :allow_blank => true
  validates_uniqueness_of   :tweet_id_ref, :allow_blank => true


  # Mass assignment protection
  attr_accessible :tweet_id_ref, :title, :user_name, :published_at


  # Callbacks
  before_validation :sanitize_content
  before_validation :remove_whitespace


  # Scope
  default_scope :order => 'tweets.published_at DESC'


  #
  # Provide easy access to helpers
  def helpers
    ActionController::Base.helpers
  end


  # Named scopes
  scope :active, :conditions => { :active => true }, :order => 'top_priority DESC, tweets.published_at DESC'


  #
  # Get unfound tweets from twitter
  def self.get_tweets
    # Get last tweet found
    last_tweet = Tweet.get_last_tweet_found
    last_tweet_id = last_tweet.blank? ? 1 : last_tweet.tweet_id_ref

    # Get tweets from twitter
    Tweet.get_and_save_new_tweets_user(last_tweet_id)
  end


  #
  # Set a job to active
  def activate
    self.active = true
    self.save(:validate => false)
  end


  #
  # Set a job to be de active
  def deactivate
    self.active = false
    self.save(:validate => false)
  end


  protected


  #
  # Clean up values before we save
  def sanitize_content
    self.title              = helpers.sanitize(self.title)
    self.user_name          = helpers.sanitize(self.user_name)
  end


  #
  # returns the id of the lsat tweet found
  def self.get_last_tweet_found
    Tweet.find(:first)
  end

  
  # Get and save new tweets from twtter
  def self.get_and_save_new_tweets_user(last_tweet_id_ref, number_results = 100)
    query = "screen_name=#{APP_CONFIG['twitter']['user']}"
    response_body = Tweet.make_http_request(query)
    Tweet.save_tweet_from_twitter(response_body)
  end


  # Make http reest to get a users timeline
  def self.make_http_request(query)
    begin
      full_url = "http://tweet-2-rss.appspot.com/feed/fleet_suite/QMywjDEV/statuses/user_timeline.json?#{query}"
      response = get(full_url)

      return response
    rescue Exception => e
      # Output exception
      puts "Problem in Tweet.make_http_request. error message: " + e.message
    end # end rescue
  end


  # Save each tweet found (will fail validaiton if already saved)
  def self.save_tweet_from_twitter(response_body)
    if response_body.present? && response_body['rss'].present? && response_body['rss']['channel'].present? && response_body['rss']['channel']['item'].present?
      response_body['rss']['channel']['item'].each do |item|
        tweet = self.new
        tweet.tweet_id_ref      = item['id']
        tweet.title             = item["text"]
        tweet.user_name         = item["user"]["screen_name"]
        tweet.published_at      = item["created_at"]
        # Check doesnt begin with @
        tweet.active            = false if tweet.title[0] == '@'
        tweet.save
      end
    end

  end

end
