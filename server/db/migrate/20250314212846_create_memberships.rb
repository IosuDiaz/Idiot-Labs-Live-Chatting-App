class CreateMemberships < ActiveRecord::Migration[7.2]
  def change
    create_table :memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :channel, null: false, foreign_key: true
      t.integer :role, default: 0
      t.integer :status, default: 0

      t.timestamps
    end

    add_index :memberships, [ :user_id, :channel_id ], unique: true, name: 'index_memberships_on_user_and_channel'
    add_index :memberships, :status
  end
end
