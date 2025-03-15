class CleanupMessagesSchema < ActiveRecord::Migration[7.2]
  def change
    remove_index :messages, name: "index_messages_on_sender_and_receiver"
    remove_index :messages, name: "index_messages_on_receiver_and_sender"

    remove_reference :messages, :receiver, foreign_key: { to_table: :users }

    change_column_null :messages, :channel_id, false

    add_index :messages, [ :sender_id, :channel_id ], name: "index_messages_on_sender_and_channel"
  end
end
