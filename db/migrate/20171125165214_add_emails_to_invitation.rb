class AddEmailsToInvitation < ActiveRecord::Migration[5.0]
  def change
    add_column :invitations, :emails, :string
  end
end
