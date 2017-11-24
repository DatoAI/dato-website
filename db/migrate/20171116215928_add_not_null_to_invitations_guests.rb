class AddNotNullToInvitationsGuests < ActiveRecord::Migration[5.0]
  def change
    ### Table Invitations
    change_column_null :invitations, :name, false
    change_column_null :invitations, :competition_id, false
    change_column_null :invitations, :user_id, false

    ### Table Guests
    change_column_null :guests, :invitation_id, false
    change_column_null :guests, :user_id, false
    change_column_null :guests, :secret_hash, false

  end
end
