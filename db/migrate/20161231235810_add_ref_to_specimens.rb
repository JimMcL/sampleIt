class AddRefToSpecimens < ActiveRecord::Migration[5.0]
  def change
    add_column :specimens, :ref, :string
  end
end
