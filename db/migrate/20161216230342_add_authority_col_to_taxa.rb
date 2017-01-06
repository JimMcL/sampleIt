class AddAuthorityColToTaxa < ActiveRecord::Migration[5.0]
  def change
    add_column :taxa, :authority, :string
  end
end
