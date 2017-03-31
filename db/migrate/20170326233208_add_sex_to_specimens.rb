class AddSexToSpecimens < ActiveRecord::Migration[5.0]
  def change
    add_column :specimens, :sex, :string
  end
end
