class AddProjectToSites < ActiveRecord::Migration[5.0]
  def change
    add_reference :sites, :project, foreign_key: true
  end
end
