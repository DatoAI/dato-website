class CreateInvitations < ActiveRecord::Migration[5.0]
  def change
    create_table :invitations do |t|
      t.string :name
      t.text :description
      t.references :competition, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
