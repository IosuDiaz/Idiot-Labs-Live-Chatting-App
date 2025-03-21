class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string :email, null: false, index: { unique: true }
      t.string :password_digest, null: false
      t.string :nickname, null: false, limit: 20, index: { unique: true }
      t.boolean :validated, null: false, default: false

      t.timestamps
    end
  end
end
