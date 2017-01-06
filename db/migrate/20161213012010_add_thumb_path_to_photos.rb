class AddThumbPathToPhotos < ActiveRecord::Migration[5.0]
  def change
    add_column :photos, :thumb_path, :text
  end
end
