# frozen_string_literal: true

class AddIndexToLeaks4Phone < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :skyeng_full_csv, :phone, algorithm: :concurrently
  end
end
