class AddConfidenceColToSpecimens < ActiveRecord::Migration[5.0]
  def change
    add_column :specimens, :id_confidence, :string
    add_column :specimens, :other, :string
  end
end
