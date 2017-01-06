class AddDetailColsToPhotos < ActiveRecord::Migration[5.0]
  def change
    add_column :photos, :ptype, :string
    add_column :photos, :source, :string
  end
end
