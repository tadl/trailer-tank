class AddColumncToTrailers < ActiveRecord::Migration
  def change
    add_column :trailers, :title, :string
  end
end
