class AddColumncToTracks < ActiveRecord::Migration
  def change
    add_column :trailers, :publisher, :string
    add_column :trailers, :abstract, :string
  end
end
