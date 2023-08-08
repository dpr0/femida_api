# frozen_string_literal: true

class AddIndexToParsedUsersPassport < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :parsed_users, :passport, algorithm: :concurrently
  end
end
