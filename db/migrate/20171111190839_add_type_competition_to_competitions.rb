class AddTypeCompetitionToCompetitions < ActiveRecord::Migration[5.0]
  def change
    add_column :competitions, :type_competition, :integer, default: 0
  end
end
