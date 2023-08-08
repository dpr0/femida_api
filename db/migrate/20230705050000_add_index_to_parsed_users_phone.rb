# frozen_string_literal: true

class AddIndexToParsedUsersPhone < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :parsed_users, :phone, algorithm: :concurrently
  end
end
