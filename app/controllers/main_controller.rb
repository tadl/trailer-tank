class MainController < ApplicationController
  respond_to :html, :json
  require 'mechanize'
  require 'nokogiri'
  require 'open-uri'
  require 'json'
  require 'uri'
  
  def index
    @trailers = Trailer.where(:youtube_url => nil).paginate(:page => params[:page], :per_page => 20)
    @page_title = "Videos that Need Trailers"
  end
  
  def search_by_title
    @search = URI.unescape(params[:title])
    @trailers = Trailer.search_title(params[:title]).paginate(:page => params[:page], :per_page => 20)
  end
  
  def have_trailers
    @trailers = Trailer.where.not(:youtube_url => nil).paginate(:page => params[:page], :per_page => 20)
    @page_title = "Videos that Have Trailers"
  end  
  
  def leaders
  end

  def help
  end

  def about
  end

  def faq
  end
  
  def update_trailer
    t = Trailer.find_by_record_id(params[:id])
    t.youtube_url = params[:yt]
    t.save!
    
    embed_code = '<iframe width="400" height="225" src="http://www.youtube.com/embed/'+ params[:yt] +'" frameborder="0" allowfullscreen></iframe>'
    
    respond_with do |format|
      format.json { render :json =>{message: embed_code}
        }
    end
  end
  
  def delete_trailer  
    t = Trailer.find_by_record_id(params[:id])
    t.youtube_url = nil
    t.save!
    respond_with do |format|
      format.json { render :json =>{message: "done"}}
    end 
  end  

end
