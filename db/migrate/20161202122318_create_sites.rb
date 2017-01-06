class CreateSites < ActiveRecord::Migration[5.0]
  def change
    create_table :sites do |t|
      t.text :notes
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
  end
end
