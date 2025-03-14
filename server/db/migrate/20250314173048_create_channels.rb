class CreateChannels < ActiveRecord::Migration[7.2]
  def change
    create_table :channels do |t|
      t.string :name, null: false
      t.text :description
      t.bigint :creator_id, null: false

      t.timestamps
    end

    add_foreign_key :channels, :users, column: :creator_id

    add_index :channels, :name, unique: true
    add_index :channels, :creator_id
  end
end
