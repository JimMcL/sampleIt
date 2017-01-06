class AddErrorToSites < ActiveRecord::Migration[5.0]
  def change
    add_column :sites, :horizontal_error, :float
  end
end
