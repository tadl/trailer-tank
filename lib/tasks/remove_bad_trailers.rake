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
    youtube_api = client.discovered_api('youtube', 'v3')
    result = client.execute({
        :api_method => youtube_api.videos.list,
        :parameters => {
          part: 'status',
          id: video_id,
        }
      })
    return result.data.items[0].status
  end

  Trailer.all.each do |t|
  	if t.youtube_url
  		puts 'testing ' + t.title
  		test = check_video_rake(t.youtube_url)
  		puts test["uploadStatus"]
  		if test["uploadStatus"] == 'rejected'
  			puts 'bad one'
  			t.youtube_url = nil
  			t.save
  		else
  			puts 'good one'
  		end
  		sleep(2)
  	end
  end

end