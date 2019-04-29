require 'test_helper'

class TweetTest < ActiveSupport::TestCase

    test "check active named scope" do
       tweet_1 = Tweet.active.exists?(tweets(:one))
       assert_equal true, tweet_1

       tweet_2 = Tweet.active.exists?(tweets(:two))
       assert_equal false, tweet_2
    end

    test "check deactivate" do
        tweet = Tweet.find(tweets(:one))
        assert_equal true, tweet.active, 'tweets one should be active by default'

        tweet.deactivate
        assert_equal false, tweet.active, 'tweet has not been de-activated'
    end

    test "check activate" do
        tweet = Tweet.find(tweets(:two))
        assert_equal false, tweet.active, 'tweets two should be in-active by default'

        tweet.activate
        assert_equal true, tweet.active, 'tweet has not been activated'
    end

    test "check last tweet found returns 1 result" do
        assert_nothing_raised do
            tweet = Tweet.get_last_tweet_found
        end
    end

    test "check make_http_request" do
        assert_nothing_raised do
            query = "screen_name=testlodge&since_id=14105281911"
            body_response = Tweet.make_http_request(query)
        end
    end

    test "check white space is removed" do
        tweet = Tweet.find(tweets(:one).id)
        tweet.title = ' test test '
        tweet.save

        assert_equal 'test test', tweet.title, 'Whitespace at beigning and end is not bring removed'
    end

    test "tweet is created correctly" do
        assert_difference('Tweet.count', +1) do
            create_tweet
        end
    end

    test "check sanitize_content" do
        assert_difference('Tweet.count', +1) do
            tweet = create_tweet(:title => "<script> new title</script> new title")
            assert_equal 'new title', tweet.title
        end
    end

protected

    def create_tweet(options = {})
        Tweet.create({:tweet_id_ref => 1275117453,
                     :title => 'test',
                     :user_name => 'scottsherwood (Scott Sherwood)',
                     :published_at => Time.now}.merge(options))

    end
end
