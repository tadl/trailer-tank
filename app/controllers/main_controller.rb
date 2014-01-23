class MainController < ApplicationController
  respond_to :html, :json
  require 'mechanize'
  require 'nokogiri'
  require 'open-uri'
  require 'json'
  
  def index
   @trailers = Trailer.all
    

  def leaders
    t = Trailer.find_by_record_id(params[:id])
    t.youtube_url = params[:yt]
    t.save!
    
    embed_code = '<iframe width="400" height="225" src="//www.youtube.com/embed/'+ params[:yt] +'" frameborder="0" allowfullscreen></iframe>'
    
    respond_with do |format|
      format.json { render :json =>{message: embed_code}
        }
    end
  end

  def help
  end

  def about
    videos_new = JSON.parse(open("https://www.tadl.org/mobile/export/items/32/json").read)
    videos_hot = JSON.parse(open("https://www.tadl.org/mobile/export/items/34/json").read)
    videos_tcff = JSON.parse(open("https://www.tadl.org/mobile/export/items/165/all/json").read)
    record_ids = videos_tcff["nodes"].map {|z| z['node']['item'] } + videos_hot["nodes"].map {|z| z['node']['item'] } + videos_new["nodes"].map {|z| z['node']['item'] }
    @count = 0;
    @record_details = [];
    record_ids.each do |x|
    @count = @count + 1;
      url = 'http://catalog.tadl.org/osrf-gateway-v1?service=open-ils.search&method=open-ils.search.biblio.record.mods_slim.retrieve&locale=en-US&param=' + x
      record_info = JSON.parse(open(url).read)
      details = record_info["payload"].map do |z| 
        {
          :title => z['__p'][0],
          :artist => z['__p'][1],
          :record_id => z['__p'][2],
          :release_date => z['__p'][4],
          :abstract => z['__p'][13],
          :publisher => z['__p'][6],
        }
      end
      @record_details = @record_details + details
    end
    @record_ids = record_ids
    @records_id_count = @count
    @test = []
    @record_details.map do |x|
      
      bird = x[:artist].to_s
        @test.push(bird)
        
    end
    
    
    
    
   
    
    
    respond_with do |format|
      format.json { render :json =>{count: @test, videos:  @record_ids, images: @record_details,
        }}
    end
  end
  end

  def faq
  end
end
