class CreatePhotoFiles < ActiveRecord::Migration[5.0]
  def change
    create_table :photo_files do |t|
      t.string :ftype, null: false
      t.text :path, null: false
      t.references :photo, foreign_key: true

      t.timestamps
    end
    remove_column :photos, :filename, :text
    remove_column :photos, :thumb_path, :text
  end
end
