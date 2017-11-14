class CreateGuests < ActiveRecord::Migration[5.0]
  def change
    create_table :guests do |t|
      t.references :invitation, foreign_key: true
      t.references :user, foreign_key: true
      t.string :secret_hash

      t.timestamps
    end
  end
end
