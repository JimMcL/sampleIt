class RemoveSpeciesFromSpecimens < ActiveRecord::Migration[5.0]
  def change
    remove_reference :specimens, :species, foreign_key: true
  end
end
