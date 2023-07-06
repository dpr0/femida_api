# frozen_string_literal: true

class AddIndexToLeaks8Phone < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :xfit_users, :phone, algorithm: :concurrently
  end
end
