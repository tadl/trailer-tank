class ChangeFormatsInTrailer < ActiveRecord::Migration
  def self.up
    change_column :trailers, :abstract, :text
  end

  def self.down
   change_column :trailers, :abstract, :string
  end
end
