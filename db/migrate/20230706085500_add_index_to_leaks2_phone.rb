# frozen_string_literal: true

class AddIndexToLeaks2Phone < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :sogaz, :phone, algorithm: :concurrently
  end
end
