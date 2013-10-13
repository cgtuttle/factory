class AddInvitationCreatedAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :invitaton_created_at, :date
  end
end
