class AddExifToPhotos < ActiveRecord::Migration[5.0]
  def change
    add_column :photos, :exif_json, :text
  end
end
