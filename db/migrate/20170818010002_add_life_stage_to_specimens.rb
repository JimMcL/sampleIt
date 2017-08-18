class AddLifeStageToSpecimens < ActiveRecord::Migration[5.0]
  def change
    add_column :specimens, :life_stage, :string
  end
end
