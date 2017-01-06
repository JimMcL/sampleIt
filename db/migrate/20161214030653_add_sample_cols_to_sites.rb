class AddSampleColsToSites < ActiveRecord::Migration[5.0]
  def change
    add_column :sites, :temperature, :float
    add_column :sites, :weather, :text
    add_column :sites, :collector, :text
    add_column :sites, :sample_type, :string
    add_column :sites, :transect, :string
  end
end
