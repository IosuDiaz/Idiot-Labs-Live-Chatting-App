class AddLastMessageAtToChannels < ActiveRecord::Migration[7.2]
  def change
    add_column :channels, :last_message_at, :datetime
    add_index :channels, :last_message_at, order: { last_message_at: :desc }, name: 'index_channels_on_last_message_at_desc'
  end
end
