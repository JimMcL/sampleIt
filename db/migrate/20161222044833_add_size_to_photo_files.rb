class AddSizeToPhotoFiles < ActiveRecord::Migration[5.0]
  def change
    add_column :photo_files, :width, :integer
    add_column :photo_files, :height, :integer
  end
end
