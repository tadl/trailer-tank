desc "Expire and regenerate cache"
task :add_type_and_tracks => :environment do
  require 'open-uri'
  require 'json'
   
  record_list = Trailer.all
  record_list.each do |x|
    url = 'http://mr-v2.catalog.tadl.org/osrf-gateway-v1?service=open-ils.search&method=open-ils.search.biblio.record.mods_slim.retrieve&locale=en-US&param=' + x.record_id.to_s
    record_info = JSON.parse(open(url).read)
    details = Dish(record_info["payload"][0])
    x.track_list = details.__p[15].to_s
    x.item_type = details.__p[9][0].to_s
    x.save!
  end

end
