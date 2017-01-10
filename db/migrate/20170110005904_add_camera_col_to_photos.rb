class AddCameraColToPhotos < ActiveRecord::Migration[5.0]
  def change
    add_column :photos, :camera, :string
  end
end
