class AddUserIdToTrailers < ActiveRecord::Migration
  def change
    add_column :trailers, :user_id, :integer
  end
end
