desc "Expire and regenerate cache"
task :remove_bad_trailers => :environment do
  require 'csv'
  require 'open-uri'
  require 'json'

  def check_video_rake(video_id)
    service_account_email = ENV['service_account_email']
    client = Google::APIClient.new(
      :application_name => 'tadl_gcal',
      :application_version => '1.0.0'
    )
    key = OpenSSL::PKey::RSA.new ENV["key"], 'notasecret'
    client.authorization = Signet::OAuth2::Client.new(
      :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
      :audience => 'https://accounts.google.com/o/oauth2/token',
      :scope => ['https://www.googleapis.com/auth/youtube'],
      :issuer => service_account_email,
      :signing_key => key
    )
    client.authorization.fetch_access_token!
    youtube_api = client.discovered_api('youtube', 'v3') rescue nil
    if youtube_api != nil
    	result = client.execute({
        	:api_method => youtube_api.videos.list,
        	:parameters => {
          		part: 'status',
          		id: video_id,
        	}
      	})
    	return result.data.items[0].status rescue 'bad'
    else
    	return check_video_rake(video_id)
    end
  end
  bad_ones = 0
  good_ones = 0
  Trailer.all.reverse.each do |t|
  	if t.youtube_url 
  		puts 'testing ' + t.title
  		puts t.youtube_url
  		test = check_video_rake(t.youtube_url)
  		if test == 'bad' || test["uploadStatus"] == 'rejected'
  			puts 'bad one'
  			t.youtube_url = nil
  			t.save
  			bad_ones += 1
  		else
  			puts 'good one'
  			good_ones += 1
  		end
  		puts 'so far we have had ' + good_ones.to_s + ' good ones and ' + bad_ones.to_s + ' bad ones'
  		sleep(1)
  	end
  end

end