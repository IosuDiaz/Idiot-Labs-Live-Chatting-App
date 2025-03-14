class CreateMessages < ActiveRecord::Migration[7.2]
  def change
    create_table :messages do |t|
      t.text :content, null: false
      t.references :sender, null: false, foreign_key: { to_table: :users }
      t.references :receiver, foreign_key: { to_table: :users }
      t.references :channel, foreign_key: true

      t.timestamps
    end

    add_index :messages, [ :sender_id, :receiver_id ], name: "index_messages_on_sender_and_receiver"
    add_index :messages, [ :receiver_id, :sender_id ], name: "index_messages_on_receiver_and_sender"
  end
end
