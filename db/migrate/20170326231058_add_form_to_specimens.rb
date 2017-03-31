class AddFormToSpecimens < ActiveRecord::Migration[5.0]
  def change
    add_column :specimens, :form, :string
  end
end
