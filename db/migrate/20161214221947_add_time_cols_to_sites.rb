class AddTimeColsToSites < ActiveRecord::Migration[5.0]
  def change
    add_column :sites, :duration, :integer
    add_column :sites, :started_at, :datetime
    add_column :sites, :description, :text
  end
end
