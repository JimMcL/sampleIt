class AddAltitudeToSites < ActiveRecord::Migration[5.0]
  def change
    add_column :sites, :altitude, :float
  end
end
