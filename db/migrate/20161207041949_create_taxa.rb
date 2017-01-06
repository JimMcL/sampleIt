class CreateTaxa < ActiveRecord::Migration[5.0]
  def change
    create_table :taxa do |t|
      t.text :description
      t.text :scientific_name
      t.text :common_name
      t.references :parent_taxon, foreign_key: true

      t.timestamps
    end
  end
end
