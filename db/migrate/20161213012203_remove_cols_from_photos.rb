class RemoveColsFromPhotos < ActiveRecord::Migration[5.0]
  def change
    remove_column :photos, :thumb
    remove_column :photos, :latitude
    remove_column :photos, :longitude
    remove_column :photos, :altitude
    remove_column :photos, :time
    remove_column :photos, :spatial_accuracy
    remove_column :photos, :macro_magnification
  end
end
