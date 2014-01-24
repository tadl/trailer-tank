class Trailer < ActiveRecord::Base
  include PgSearch
  pg_search_scope :search_title, :against => [:title]
  
  validates_uniqueness_of :record_id
end
