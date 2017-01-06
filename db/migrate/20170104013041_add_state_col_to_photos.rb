class AddStateColToPhotos < ActiveRecord::Migration[5.0]
  def change
    add_column :photos, :state, :string
  end
end
