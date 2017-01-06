class CreatePhotos < ActiveRecord::Migration[5.0]
  def change
    create_table :photos do |t|
      t.integer :rating
      t.binary :thumb
      t.text :filename
      t.float :latitude
      t.float :longitude
      t.float :altitude
      t.datetime :time
      t.float :spatial_accuracy
      t.float :macro_magnification
      t.references :imageable, polymorphic: true, index: true

      t.timestamps
    end
  end
end
