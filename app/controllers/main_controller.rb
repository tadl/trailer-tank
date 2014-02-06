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
  
end  
