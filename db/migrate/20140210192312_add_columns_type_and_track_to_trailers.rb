class AddColumnsTypeAndTrackToTrailers < ActiveRecord::Migration
  def change
    add_column :trailers, :item_type, :string
    add_column :trailers, :track_list, :text
  end
end
