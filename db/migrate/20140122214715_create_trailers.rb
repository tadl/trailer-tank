class CreateTrailers < ActiveRecord::Migration
  def change
    create_table :trailers do |t|
      t.integer :record_id
      t.string :added_by
      t.string :youtube_url
      t.string :release_date
      t.string :tile
      t.string :artist

      t.timestamps
    end
  end
end
