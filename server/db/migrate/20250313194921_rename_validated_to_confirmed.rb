class RenameValidatedToConfirmed < ActiveRecord::Migration[7.2]
  def change
    rename_column :users, :validated, :confirmed
  end
end
