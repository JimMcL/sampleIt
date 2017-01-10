class AddDispositionColToSpecimens < ActiveRecord::Migration[5.0]
  def change
    add_column :specimens, :disposition, :string
  end
end
