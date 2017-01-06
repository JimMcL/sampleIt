class AddTaxonToSpecimens < ActiveRecord::Migration[5.0]
  def change
    add_reference :specimens, :taxon, foreign_key: true
  end
end
