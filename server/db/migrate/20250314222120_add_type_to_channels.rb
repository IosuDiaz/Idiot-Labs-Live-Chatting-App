class AddTypeToChannels < ActiveRecord::Migration[7.2]
  def change
    add_column :channels, :public, :boolean, default: true

    change_column_null :channels, :name, true
  end
end
