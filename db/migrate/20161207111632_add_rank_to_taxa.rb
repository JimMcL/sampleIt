class AddRankToTaxa < ActiveRecord::Migration[5.0]
  def change
    add_column :taxa, :rank, :text
  end
end
