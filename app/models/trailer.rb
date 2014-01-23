class Trailer < ActiveRecord::Base
  validates_uniqueness_of :record_id
end
