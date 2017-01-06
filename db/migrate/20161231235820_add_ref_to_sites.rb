class AddRefToSites < ActiveRecord::Migration[5.0]
  def change
    add_column :sites, :ref, :string
  end
end
