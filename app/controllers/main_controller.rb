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
    trailers_all_without = Trailer.where(:youtube_url => nil).count
    trailers_total = Trailer.count
    @trailers_count = trailers_total - trailers_all_without
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
  
  def change_role
    if current_user.role == 'admin' or current_user.email = 'smorey@tadl.org'
    role = params[:role]
    u = User.find_by_email(params[:email])
    u.role = role
    u.save
      @message = "done"
    else
      @message = "no rights"
    end
    respond_with do |format|
      format.json { render :json =>{message: @message}}
    end 
  end
  
  def add_record
      @trailers = Trailer.where(:record_id => params[:id])
      @record_number = params[:id]
      if @trailers.count != 0
        @message = 'Record Already Exisists'
        @state = 'solo'
        @current_page = 1
      else
        @message = 'Confirm Record Details'
        if params[:id]
          record_id = params[:id]
          url = 'http://catalog.tadl.org/osrf-gateway-v1?service=open-ils.search&method=open-ils.search.biblio.record.mods_slim.retrieve&locale=en-US&param=' + record_id.strip
          record_info = JSON.parse(open(url).read)
          @details = Dish(record_info["payload"][0])
          if record_info["payload"].size == 0
          else
            if record_info["payload"][0].size != 6 
              @valid = 'yes'
            end
          end
        end
      end
  end
  

  
  def manual_add
   if current_user.role == 'admin' or current_user.role == 'librarian'
      url = 'http://catalog.tadl.org/osrf-gateway-v1?service=open-ils.search&method=open-ils.search.biblio.record.mods_slim.retrieve&locale=en-US&param=' + params[:id]
      record_info = JSON.parse(open(url).read)
      details = record_info["payload"].map do |z| 
        {
          :title => z['__p'][0],
          :artist => z['__p'][1],
          :record_id => z['__p'][2],
          :release_date => z['__p'][4],
          :abstract => z['__p'][13],
          :publisher => z['__p'][6],
          :item_type => z['__p'][9][0],
          :track_list => z['__p'][15],
        }
      end
    
      details.each do |x|
        t = Trailer.new
        t.record_id = x[:record_id].to_s
        t.title = x[:title].to_s
        t.artist = x[:artist].to_s
        t.abstract = x[:abstract].to_s
        t.release_date = x[:release_date].to_s
        t.publisher = x[:publisher].to_s
        t.item_type = x[:item_type].to_s
        t.track_list = x[:track_list].to_s
        if t.valid? == true
          t.save!
          url = '/main/add_record?id=' + params[:id]
          redirect_to (url)
        end
     end
   end
  end
end  
