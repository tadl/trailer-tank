class Trailer < ActiveRecord::Base
  include PgSearch
  pg_search_scope :search_title, :against => [:title]
  belongs_to :user 
  validates_uniqueness_of :record_id
end
