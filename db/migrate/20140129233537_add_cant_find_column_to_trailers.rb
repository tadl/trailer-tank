class AddCantFindColumnToTrailers < ActiveRecord::Migration
  def change
    add_column :trailers, :cant_find, :boolean, :default => false
  end
end
