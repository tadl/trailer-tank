class MainController < ApplicationController
  require 'mechanize'
  require 'nokogiri'
  require 'open-uri'
  require 'json'
  require 'uri' 
  require 'csv'
  before_action :authenticate_user!, :except => [:index, :get_trailer]
  respond_to :html, :json
  
  def index
    if current_user != nil
      redirect_to action: 'queue'
    end 
  end
  
  def queue
    @trailers = Trailer.where(:youtube_url => nil, :cant_find => false).paginate(:page => params[:page], :per_page => 10)
    @trailers_count = @trailers.count.to_s
    @state = 'queue'
    @page_title = @trailers_count +' Videos Need Trailers'
    if params[:page] == nil
    @current_page = 1
    else
    @current_page = params[:page]
    end
    respond_with do |format|
      format.js {}
      format.html {}
    end
  end  
  
  def cant_find
    @trailers = Trailer.where(:youtube_url => nil, :cant_find => true).paginate(:page => params[:page], :per_page => 10)
    @trailers_count = @trailers.count.to_s
    @state = 'cant_find'
    @page_title = @trailers_count +' Videos Need Trailers'
    if params[:page] == nil
    @current_page = 1
    else
    @current_page = params[:page]
    end
      respond_with do |format|
      format.js {}
      format.html {}
    end 
  end
  
  def search_by_title
    @search = URI.unescape(params[:title])
    @trailers = Trailer.search_title(params[:title]).paginate(:page => params[:page], :per_page => 10)
    @state = 'search'
    if params[:page] == nil
    @current_page = 1
    else
    @current_page = params[:page]
    end
  end
  
  def leaders
    @users = User.all.order("score DESC")
  end

  def get_trailer
    headers['Access-Control-Allow-Origin'] = "*"
    t = Trailer.find_by_record_id(params[:id])
    if t && t.youtube_url
      @message = t.youtube_url
    else
      @message = "error"
    end
    respond_to do |format|
      format.json { render :json => { :message => @message }}
    end 
  end
  
  def update_trailer
    t = Trailer.find_by_record_id(params[:id])
    t.youtube_url = params[:yt]
    t.user_id = current_user.id
    if t.cant_find == true
      current_user.score += 1
      current_user.save
      t.cant_find = false
    else
      current_user.score += 1
      current_user.save
    end
    t.save!
    @score = current_user.score
    respond_with do |format|
      format.json { render :json =>{message: @score}
        }
    end
  end
  
  def delete_trailer  
    t = Trailer.find_by_record_id(params[:id])
    t.user_id = nil
    t.youtube_url = nil
    t.save!
    current_user.score -= 1
    current_user.save
    respond_with do |format|
      format.json { render :json =>{message: "done"}}
    end 
  end
  
  def mark_cant_find
    t = Trailer.find_by_record_id(params[:id])
    t.cant_find = true
    t.user_id = current_user.id
    t.save
    respond_with do |format|
      format.json { render :json =>{message: "done"}}
    end 
  end
  
  def from_txt_test
    record_list = [];
    record_ids = CSV.foreach("#{Rails.root}/db/records.txt") do |row|    
      record = row.join
      record_list = record_list.push(record)
    end
    record_details = [];
    
    record_list.each do |x|
      url = 'http://catalog.tadl.org/osrf-gateway-v1?service=open-ils.search&method=open-ils.search.biblio.record.mods_slim.retrieve&locale=en-US&param=' + x.strip
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
      record_details = record_details + details
    end
    
    
    
    respond_to do |format|
      format.json { render :json => { :message => record_details }}
    end 
  end
  
  
end  
