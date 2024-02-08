class AddMessageUid < ActiveRecord::Migration[7.0]
  def change
    add_column :messages, :email_uid, :text
    add_index :messages, :email_uid
  end
end
