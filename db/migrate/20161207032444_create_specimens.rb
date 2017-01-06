class CreateSpecimens < ActiveRecord::Migration[5.0]
  def change
    create_table :specimens do |t|
      t.text :description
      t.text :species
      t.references :site, foreign_key: true
      t.integer :quantity
      t.float :body_length
      t.text :notes

      t.timestamps
    end
  end
end
