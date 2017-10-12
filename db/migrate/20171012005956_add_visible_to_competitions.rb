class AddVisibleToCompetitions < ActiveRecord::Migration[5.0]
  def change
    add_column :competitions, :visible, :integer, default: 0
  end
end
