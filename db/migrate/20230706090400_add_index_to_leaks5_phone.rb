# frozen_string_literal: true

class AddIndexToLeaks5Phone < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :one_more_lz2, :Telephone, algorithm: :concurrently
  end
end
