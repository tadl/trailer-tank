desc "Expire and regenerate cache"
task :records_from_txt => :environment do
  require 'csv'
  require 'open-uri'
  require 'json'
   record_list = [];
    record_ids = CSV.foreach("#{Rails.root}/db/records.txt") do |row|    
      record = row.join
      record_list = record_list.push(record)
    end
    record_details = [];
    
    record_list.each do |x|
      url = 'http://mr-v2.catalog.tadl.org/osrf-gateway-v1?service=open-ils.search&method=open-ils.search.biblio.record.mods_slim.retrieve&locale=en-US&param=' + x.strip
      record_info = JSON.parse(open(url).read)
      details = record_info["payload"].map do |z| 
        {
          :title => z['__p'][0],
          :artist => z['__p'][1],
          :record_id => z['__p'][2],
          :release_date => z['__p'][4],
          :abstract => z['__p'][13],
          :publisher => z['__p'][6],
          :track_list => z['__p'][15],
          :item_type => z['__p'][9][0]
        }
      end
      record_details = record_details + details
    end

    
  record_details.each do |x|
    t = Trailer.new
    t.record_id = x[:record_id].to_s
    t.title = x[:title].to_s
    t.artist = x[:artist].to_s
    t.abstract = x[:abstract].to_s
    t.release_date = x[:release_date].to_s
    t.publisher = x[:publisher].to_s
    t.track_list = x[:track_list].to_s
    t.item_type = x[:item_type].to_s
    if t.valid? == true
    t.save!
    end
  end
  
end
