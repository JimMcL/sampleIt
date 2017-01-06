class FixIndexOnPhotoFiles < ActiveRecord::Migration[5.0]
  def change
    remove_index :photo_files, name: :index_photo_files_on_photo_id_and_ftype
    add_index :photo_files, [:photo_id, :ftype], unique: true
  end
end
