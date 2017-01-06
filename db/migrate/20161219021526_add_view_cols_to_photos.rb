class AddViewColsToPhotos < ActiveRecord::Migration[5.0]
  def change
    add_column :photos, :view_phi, :integer
    add_column :photos, :view_lambda, :integer
  end
end
